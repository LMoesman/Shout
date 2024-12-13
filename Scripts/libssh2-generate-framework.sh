#!/usr/bin/env zsh

# This script compiles libssh2 from source for macOS, creating a universal xcframework that works for Intel (x86_64) and Apple Silicon (arm64).
# Based on https://gist.github.com/mbernson/e830f34d1bcd88b8e7a97d21ca9dce24

if [[ "$PWD" != *Shout ]]; then
    echo "The script should be run from the project folder with ./Scripts/libssh2-generate-framework.sh"
    exit 0
fi

set -e

SDK=macosx
SDK_VERSION="12.0"

# Set up a build directory
RUN_PATH="$(pwd)"
BASE_PATH="$(pwd)/tmp"
SOURCE_ROOT="$(pwd)/tmp/libssh2"
BUILD_ROOT="$(pwd)/tmp/build/libssh2"

rm -rf $BASE_PATH

mkdir -p $SOURCE_ROOT
git clone https://github.com/libssh2/libssh2.git $SOURCE_ROOT

mkdir -p $BUILD_ROOT
cd $BUILD_ROOT

 # Generate an Xcode project using cmake
 cmake -S "$SOURCE_ROOT" -B "$BUILD_ROOT" \
     -G Xcode \
     -DBUILD_STATIC_LIBS=ON \
     -DCMAKE_OSX_SYSROOT=$(xcrun --sdk $SDK --show-sdk-path) \
     -DCMAKE_OSX_DEPLOYMENT_TARGET=$SDK_VERSION \
     -DBUILD_SHARED_LIBS=OFF \
     -DCRYPTO_BACKEND=OpenSSL

 # Build the static library
 xcodebuild archive \
     -project libssh2.xcodeproj \
     -scheme libssh2_static \
     -destination "generic/platform=macOS" \
     -archivePath "$BUILD_ROOT/libssh2-macOS.xcarchive" \
     INSTALL_PATH="/" \
     SKIP_INSTALL=NO \
     BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
     ARCHS='$(ARCHS_STANDARD)'

 # Copy module map to include folder
 cp "$RUN_PATH/Resources/libssh2/module.modulemap" "$SOURCE_ROOT/include/module.modulemap"

# Create the xcframework
OUTPUT_FRAMEWORK="libssh2.xcframework"
xcodebuild -create-xcframework \
    -library "$BUILD_ROOT/libssh2-macOS.xcarchive/Products/libssh2.a" \
    -headers "$SOURCE_ROOT/include" \
    -output "$OUTPUT_FRAMEWORK"

# Copy framework to libs folder
FRAMEWORK_PATH="$RUN_PATH/Libs/$OUTPUT_FRAMEWORK"
rm -rf $FRAMEWORK_PATH
cp -r "$BUILD_ROOT/$OUTPUT_FRAMEWORK" "$FRAMEWORK_PATH"

# Cleanup
rm -rf $BASE_PATH

echo "Success! The libssh2 xcframework is copied to $FRAMEWORK_PATH"

