#!/usr/bin/env zsh

# This script compiles OpenSSL from source for macOS, creating a universal xcframework that works for Intel (x86_64) and Apple Silicon (arm64).
# Based on https://gist.github.com/mbernson/8e09fa53de0fa1c942b0a26f6f0e8c7c

if [[ "$PWD" != *Shout ]]; then
    echo "The script should be run from the project folder with ./Scripts/openssl-generate-framework.sh"
    exit 0
fi

set -e

export CC="$PWD/Scripts/openssl-cc.sh -mmacosx-version-min=12.0"

CROSS_COMPILE=`xcode-select --print-path`/Toolchains/XcodeDefault.xctoolchain/usr/bin/
CROSS_TOP=`xcode-select --print-path`/Platforms/MacOSX.platform/Developer
CROSS_SDK=MacOSX.sdk
ARCH="x86_64" # The x86_64 architecture preset also includes the ARM64 architecture, with the cc script.

# Set up a build directory
RUN_PATH="$(pwd)"
BASE_PATH="$(pwd)/tmp"
SOURCE_ROOT="$(pwd)/tmp/openssl"
BUILD_ROOT="$(pwd)/tmp/build/openssl"

rm -rf $BASE_PATH

mkdir -p $SOURCE_ROOT
git clone https://github.com/openssl/openssl.git $SOURCE_ROOT

cd $SOURCE_ROOT

# Compile OpenSSL
perl "./Configure" no-asm no-apps no-docs no-shared no-dso no-quic darwin64-$ARCH --prefix="$BUILD_ROOT"
make -j8
make install

# Merge libssl and libcrypto into a single static library
libtool -static -o "$BUILD_ROOT/lib/openssl.a" "$BUILD_ROOT/lib/libssl.a" "$BUILD_ROOT/lib/libcrypto.a"

# Create the xcframework
cd $BUILD_ROOT
OUTPUT_FRAMEWORK="openssl.xcframework"
rm -rf $OUTPUT_FRAMEWORK
xcodebuild -create-xcframework \
    -library $BUILD_ROOT/lib/openssl.a \
    -headers $BUILD_ROOT/include \
    -output $OUTPUT_FRAMEWORK

# Copy framework to libs folder
FRAMEWORK_PATH="$RUN_PATH/Libs/$OUTPUT_FRAMEWORK"
rm -rf $FRAMEWORK_PATH
cp -r "$BUILD_ROOT/$OUTPUT_FRAMEWORK" "$FRAMEWORK_PATH"

# Cleanup
rm -rf $BASE_PATH

echo "Success! The openssl xcframework is copied to $FRAMEWORK_PATH"
