#!/bin/bash
# 静界 QuietSpace — 构建脚本
# 使用已安装的 Command Line Tools 直接编译 SwiftUI macOS App，不依赖完整 Xcode。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

# 优先使用 Command Line Tools；如果机器上只有完整 Xcode，则通过 xcrun 查找。
if [ -x "/Library/Developer/CommandLineTools/usr/bin/swiftc" ] && [ -d "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk" ]; then
  SWIFTC="/Library/Developer/CommandLineTools/usr/bin/swiftc"
  SDK="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
else
  SWIFTC="$(xcrun --find swiftc)"
  SDK="$(xcrun --sdk macosx --show-sdk-path)"
fi
CACHE="$ROOT/.build/modulecache"
APP="$ROOT/dist/静界.app"
BIN="$APP/Contents/MacOS/QuietSpace"

mkdir -p "$CACHE" "$APP/Contents/MacOS" "$APP/Contents/Resources"

SOURCES=(
  "$ROOT/Sources/Theme.swift"
  "$ROOT/Sources/Models.swift"
  "$ROOT/Sources/AdviceEngine.swift"
  "$ROOT/Sources/Localization.swift"
  "$ROOT/Sources/AccountStore.swift"
  "$ROOT/Sources/SessionStore.swift"
  "$ROOT/Sources/Components.swift"
  "$ROOT/Sources/IMEPlatformTextField.swift"
  "$ROOT/Sources/LoginView.swift"
  "$ROOT/Sources/RegisterView.swift"
  "$ROOT/Sources/HomeView.swift"
  "$ROOT/Sources/AccountView.swift"
  "$ROOT/Sources/SettingsView.swift"
  "$ROOT/Sources/DesktopSidebar.swift"
  "$ROOT/Sources/OnboardingFlowView.swift"
  "$ROOT/Sources/SolutionReportView.swift"
  "$ROOT/Sources/RuleView.swift"
  "$ROOT/Sources/WearableView.swift"
  "$ROOT/Sources/DailyPlanView.swift"
  "$ROOT/Sources/DailyReportView.swift"
  "$ROOT/Sources/MoodTrendView.swift"
  "$ROOT/Sources/BookmarkView.swift"
  "$ROOT/Sources/Companion.swift"
  "$ROOT/Sources/DailyMoodChart.swift"
  "$ROOT/Sources/RootView.swift"
  "$ROOT/Sources/DebugCapture.swift"
  "$ROOT/Sources/AppDelegate.swift"
  "$ROOT/Sources/QuietSpaceApp.swift"
)

echo "==> 编译 App（Universal：arm64 + x86_64，最低 macOS 14）"
for ARCH in arm64 x86_64; do
  "$SWIFTC" -sdk "$SDK" -target "${ARCH}-apple-macosx14.0" -O -parse-as-library \
    -module-cache-path "$CACHE" \
    "${SOURCES[@]}" \
    -o "$ROOT/.build/QuietSpace-$ARCH" \
    -framework SwiftUI -framework AppKit
done
lipo -create "$ROOT/.build/QuietSpace-arm64" "$ROOT/.build/QuietSpace-x86_64" -output "$BIN"

cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"
mkdir -p "$APP/Contents/Resources"
cp -R "$ROOT/Resources/." "$APP/Contents/Resources/"

echo "==> 生成 App 图标"
"$SWIFTC" -sdk "$SDK" -O -parse-as-library -module-cache-path "$CACHE" \
  "$ROOT/Sources/Theme.swift" \
  "$ROOT/Tools/Icon.swift" \
  -o "$ROOT/.build/icontool" \
  -framework SwiftUI -framework AppKit

"$ROOT/.build/icontool" "$ROOT/.build/icon-1024.png"
ICONSET="$ROOT/.build/AppIcon.iconset"
rm -rf "$ICONSET"
mkdir -p "$ICONSET"
while read -r size name; do
  sips -z "$size" "$size" "$ROOT/.build/icon-1024.png" --out "$ICONSET/$name.png" >/dev/null
done <<'SIZES'
16 icon_16x16
32 icon_16x16@2x
32 icon_32x32
64 icon_32x32@2x
128 icon_128x128
256 icon_128x128@2x
256 icon_256x256
512 icon_256x256@2x
512 icon_512x512
1024 icon_512x512@2x
SIZES
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"

codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || true
echo "==> 已生成 $APP"

echo "==> 导出界面预览"
"$SWIFTC" -sdk "$SDK" -O -parse-as-library -module-cache-path "$CACHE" \
  "$ROOT/Sources/Theme.swift" \
  "$ROOT/Sources/Models.swift" \
  "$ROOT/Sources/AdviceEngine.swift" \
  "$ROOT/Sources/Localization.swift" \
  "$ROOT/Sources/AccountStore.swift" \
  "$ROOT/Sources/SessionStore.swift" \
  "$ROOT/Sources/Components.swift" \
  "$ROOT/Sources/IMEPlatformTextField.swift" \
  "$ROOT/Sources/LoginView.swift" \
  "$ROOT/Sources/RegisterView.swift" \
  "$ROOT/Sources/HomeView.swift" \
  "$ROOT/Sources/AccountView.swift" \
  "$ROOT/Sources/SettingsView.swift" \
  "$ROOT/Sources/DesktopSidebar.swift" \
  "$ROOT/Sources/OnboardingFlowView.swift" \
  "$ROOT/Sources/SolutionReportView.swift" \
  "$ROOT/Sources/RuleView.swift" \
  "$ROOT/Sources/WearableView.swift" \
  "$ROOT/Sources/DailyPlanView.swift" \
  "$ROOT/Sources/DailyReportView.swift" \
  "$ROOT/Sources/MoodTrendView.swift" \
  "$ROOT/Sources/BookmarkView.swift" \
  "$ROOT/Sources/Companion.swift" \
  "$ROOT/Sources/DailyMoodChart.swift" \
  "$ROOT/Tools/Snapshot.swift" \
  -o "$ROOT/.build/snapshot" \
  -framework SwiftUI -framework AppKit

mkdir -p "$ROOT/.build/en.lproj" "$ROOT/.build/zh-Hans.lproj"
cp "$ROOT/Resources/en.lproj/Localizable.strings" "$ROOT/.build/en.lproj/"
cp "$ROOT/Resources/zh-Hans.lproj/Localizable.strings" "$ROOT/.build/zh-Hans.lproj/"
"$ROOT/.build/snapshot" "$ROOT/screenshots"
echo "==> 完成。运行：open \"$APP\""
