# Devpost 提交清单（程序部分）

## 1. 必须先准备的链接

- [ ] 公开 GitHub 仓库（Apache License 2.0）：`https://github.com/ZFZ15/quietspace`
- [ ] GitHub Release 里的 Mac 安装包：`https://cdn.jsdelivr.net/gh/ZFZ15/quietspace@main/download/QuietSpace-0.1-macOS.zip`
- [ ] 演示视频链接（YouTube / Vimeo 不公开链接，或 Devpost 视频上传）
- [ ] 项目海报 PDF（AMD API 生成，另见第 3 节）

## 2. 源码仓库

- [ ] 根目录包含 `LICENSE`（Apache License 2.0）
- [ ] 根目录包含 `README.md`，写明：
  - macOS 14+、Command Line Tools / Xcode
  - `./build.sh`、`open dist/静界.app`
  - 演示账号 `demo` / `123456`
  - 58 项测试 `./test.sh`
  - ad-hoc 签名与 Gatekeeper 打开方式
- [ ] 不提交 `.build/`、`dist/`、个人数据、`.DS_Store`
- [ ] 仓库公开，Devpost 的 Source code 字段填仓库链接

推仓库：

```bash
cd quietspace-source
git remote add origin https://github.com/<账号>/<仓库>.git
git branch -M main
git push -u origin main
```

## 3. 海报（强制，代码之外）

- [ ] 用 **AMD 的 image-generation API**（AMD Creative Factory → Image）生成海报
- [ ] 保存**原始未编辑图**
- [ ] 截图 AMD Creative Factory → Image → My work → Gallery
- [ ] 海报可做轻度调色、裁剪、排版和文字叠加；不能换模型重绘核心视觉
- [ ] 海报 PDF 上传到 Devpost 的 File Upload
- [ ] 原始 AMD 图片 + Gallery 截图的公开链接填到对应必填项
- [ ] 海报同时作为 Devpost 项目图片

> 缺少海报、原始 AMD 图或 Gallery 证明，作品可能被判定为不完整。

## 4. Devpost 项目描述（可直接改写）

**Project name**  
静界 QuietSpace

**Tagline**  
A low-stimulation daily support app for sensory-sensitive people.

**Problem**  
感官敏感人群（HSP、ADHD、自闭谱系、感官过载者）每天要面对噪音、人群、强光和密集安排。现有日程工具只告诉用户“做什么”，很少帮助用户判断“这件事对我的感官负荷有多大”，也缺少低刺激、可退出的交互。

**Target users**  
高校学生与年轻职场人中的感官敏感者；需要提前规划、实时记录感受、事后复盘的人。

**Solution**  
静界把感官负荷作为核心指标：自测 → 每日计划 → 单事件评分 → 三区间感官报告。界面低饱和、无强制动效、可关闭动画，并提供中式书签作为报告反馈。

**Core features**
- 10 题感官自测与初步方案
- 每日计划、时间滚轮、场景建议
- 完成事件记录：平稳 / 紧绷 / 过载
- 单事件 100 分感官负荷：基础刺激分 × 调节系数
- 平稳 / 紧张 / 过载三区间，中式书签报告，不显示分数
- 近 7 天感官负荷趋势
- 5 套低饱和配色、6 张小伙伴贴纸
- 中英文界面、Mac 桌面自适应布局

**Tech stack**  
Swift, SwiftUI, AppKit, AVFoundation, CoreText, UserDefaults, Swift Package-free build via swiftc, universal binary (arm64 + x86_64), macOS 14+.

**Team roles（正好 4 人，按实际名字填）**
- Member 1 — 产品与用户研究：需求、自测题目、场景建议、答辩
- Member 2 — SwiftUI 开发：计划、报告、评分、书签
- Member 3 — 设计与视觉：配色、贴纸、海报、演示视频
- Member 4 — 测试与演示：测试、英文、现场演示、Devpost 提交

## 5. 视频与现场演示

- [ ] 上传 `静界-完整功能演示.mp4`（约 2 分 54 秒，中文配音）
- [ ] Devpost Video 字段填链接
- [ ] 现场带自己的 Mac、充电器、离线演示数据
- [ ] 备份视频放在本机，不依赖现场网络
- [ ] 3–5 分钟演示：注册 → 自测 → 计划 → 感受 → 书签报告 → 配色/贴纸 → 英文/桌面

## 6. 团队与截止时间

- [ ] 队伍**正好 4 人**，每个人都加入 Devpost 项目
- [ ] 每人只能参加一个队，每队只能提交一个项目
- [ ] 提交截止：**2026-11-22 13:00 北京时间**，逾期不接受
- [ ] 关闭前再次点开所有链接测试：仓库、Release 下载、视频、海报原图、Gallery 截图

## 7. AI / 第三方披露

- [ ] Devpost 描述里写明：使用 AI 编程助手辅助开发；使用 macOS `say` 生成视频配音；海报由 AMD API 生成
- [ ] 确认六张贴纸由团队提供并拥有使用权
- [ ] 仓库里保留 `THIRD_PARTY.md`
