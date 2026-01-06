#!/bin/bash
set -e

echo "Setting up Flutter..."
git config --global --add safe.directory /vercel/path0

# Download and extract Flutter
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz -o flutter.tar.xz
tar xf flutter.tar.xz
rm flutter.tar.xz

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Configure Flutter
flutter config --enable-web --no-analytics
flutter doctor -v

# Build the app
flutter pub get
flutter build web --release --no-tree-shake-icons

echo "Build complete!"