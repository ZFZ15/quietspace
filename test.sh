#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if [ -x "/Library/Developer/CommandLineTools/usr/bin/swiftc" ] && [ -d "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk" ]; then
  SWIFTC="/Library/Developer/CommandLineTools/usr/bin/swiftc"
  SDK="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
else
  SWIFTC="$(xcrun --find swiftc)"
  SDK="$(xcrun --sdk macosx --show-sdk-path)"
fi
CACHE="$ROOT/.build/modulecache"
mkdir -p "$CACHE"

"$SWIFTC" -sdk "$SDK" -O -parse-as-library -module-cache-path "$CACHE" \
  "$ROOT/Sources/Theme.swift" \
  "$ROOT/Sources/Companion.swift" \
  "$ROOT/Sources/Models.swift" \
  "$ROOT/Sources/AdviceEngine.swift" \
  "$ROOT/Sources/AccountStore.swift" \
  "$ROOT/Sources/SessionStore.swift" \
  "$ROOT/Tools/StoreTest.swift" \
  -o "$ROOT/.build/storetest" \
  -framework SwiftUI -framework AppKit -framework Foundation

"$ROOT/.build/storetest"
