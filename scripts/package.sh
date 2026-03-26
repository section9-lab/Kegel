#!/bin/bash

# 设置变量
APP_NAME="KegelTimer"
BUILD_DIR=".build/apple/Products/Release"
DIST_DIR="dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"

# 清理
rm -rf "$DIST_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 构建通用二进制 (Intel + Apple Silicon)
echo "Building for Release..."
swift build -c release --arch arm64 --arch x86_64

# 拷贝二进制
echo "Packaging..."
cp "$BUILD_DIR/Kegel" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# 拷贝资源
cp App/Info.plist "$APP_BUNDLE/Contents/Info.plist"

if [ -f "App/KegelTimer.icns" ]; then
    cp App/KegelTimer.icns "$APP_BUNDLE/Contents/Resources/KegelTimer.icns"
fi

# 修正权限 (确保二进制可执行)
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# 打包
cd "$DIST_DIR"
zip -r "../$APP_NAME.app.zip" "$APP_NAME.app"

echo "Build Completed: $APP_NAME.app.zip"
