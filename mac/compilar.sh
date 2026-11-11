#!/bin/bash
# Compila o Mindmap para o Mac como app Universal (Intel + Apple Silicon).
# Precisa de um Mac com as ferramentas de linha de comandos do Xcode (xcode-select --install).
# Uso: mac/compilar.sh   →   dist/Mindmap.app e dist/Mindmap-Mac-Universal.zip
set -euo pipefail
cd "$(dirname "$0")/.."

MINIMO=11.3                       # macOS mínimo (as descargas do WKWebView precisam do 11.3)
VERSAO=$(sed -n "s/^const APP_VERSAO = '\(.*\)';.*/\1/p" index.html)
APP=dist/Mindmap.app

rm -rf dist build-mac
mkdir -p build-mac "$APP/Contents/MacOS" "$APP/Contents/Resources"

for ARQ in x86_64 arm64; do
  swiftc -O -target "$ARQ-apple-macos$MINIMO" mac/main.swift -o "build-mac/Mindmap-$ARQ"
done
lipo -create build-mac/Mindmap-x86_64 build-mac/Mindmap-arm64 -output "$APP/Contents/MacOS/Mindmap"

cp index.html "$APP/Contents/Resources/index.html"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Mindmap</string>
  <key>CFBundleDisplayName</key><string>Mindmap</string>
  <key>CFBundleIdentifier</key><string>app.mindmap.mac</string>
  <key>CFBundleExecutable</key><string>Mindmap</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>${VERSAO:-1.0}</string>
  <key>CFBundleVersion</key><string>${VERSAO:-1.0}</string>
  <key>LSMinimumSystemVersion</key><string>$MINIMO</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSPrincipalClass</key><string>NSApplication</string>
  <key>CFBundleDevelopmentRegion</key><string>pt-PT</string>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP"          # assinatura ad-hoc, para uso pessoal (sem sandbox)
lipo -archs "$APP/Contents/MacOS/Mindmap"        # tem de dizer: x86_64 arm64
ditto -c -k --keepParent "$APP" dist/Mindmap-Mac-Universal.zip
rm -rf build-mac
echo "Feito: $APP (versão ${VERSAO:-?})"
