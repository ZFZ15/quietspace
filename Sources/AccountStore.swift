import Foundation
import Combine
import CryptoKit

/// 仅用于原型的本地账号存储：账号存在 UserDefaults，密码只保存 SHA-256 摘要。
final class AccountStore: ObservableObject {
    @Published private(set) var accounts: [String: String] = [:]

    private let defaults = UserDefaults.standard
    private let storageKey = "quietspace.accounts.v1"

    init() {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            accounts = decoded
        }
        // 预置演示账号，方便现场直接登录
        if accounts["demo"] == nil {
            accounts["demo"] = Self.hash("123456")
            persist()
        }
    }

    func login(account: String, password: String) -> Bool {
        let key = account.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let stored = accounts[key] else { return false }
        return stored == Self.hash(password)
    }

    /// 返回 nil 表示注册成功，否则返回给用户看的错误文案。
    @discardableResult
    func register(account: String, password: String, confirm: String) -> String? {
        let key = account.trimmingCharacters(in: .whitespacesAndNewlines)
        if key.count < 2 { return "账号至少需要 2 个字符" }
        if key.count > 20 { return "账号最多 20 个字符" }
        if password.count < 6 { return "密码至少需要 6 位" }
        if password != confirm { return "两次输入的密码不一致" }
        if accounts[key] != nil { return "这个账号已经注册过了" }
        accounts[key] = Self.hash(password)
        persist()
        return nil
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(accounts) {
            defaults.set(data, forKey: storageKey)
        }
    }

    static func hash(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// 展示用的稳定 ID，例如 QS-8D96EE。
    static func publicID(for account: String) -> String {
        let digest = SHA256.hash(data: Data(account.utf8))
        let hex = digest.prefix(3).map { String(format: "%02X", $0) }.joined()
        return "QS-\(hex)"
    }
}
