#!/bin/bash
# Fix du linker manquant dans le snap Flutter
SNAP_VER=$(readlink /snap/flutter/current)
LLVM_BIN="/snap/flutter/${SNAP_VER}/usr/lib/llvm-10/bin"

# Vérifie si le fix est déjà appliqué
if [ ! -f "$LLVM_BIN/ld.lld" ]; then
  echo "Application du fix linker..."
  mkdir -p /tmp/flutter-llvm-bin
  cp "$LLVM_BIN"/* /tmp/flutter-llvm-bin/ 2>/dev/null
  ln -sf /usr/bin/ld.lld /tmp/flutter-llvm-bin/ld.lld
  ln -sf /usr/bin/ld /tmp/flutter-llvm-bin/ld
  ln -sf /usr/bin/llvm-ar /tmp/flutter-llvm-bin/llvm-ar
  ln -sf /usr/bin/ar /tmp/flutter-llvm-bin/ar
  sudo mount --bind /tmp/flutter-llvm-bin "$LLVM_BIN"
fi

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME=/home/mael/android-sdk
flutter run -d linux
