#!/usr/bin/env bash
# Build file .ipa để upload lên TestFlight, có dọn cache native assets trước để
# không đóng nhầm thư viện `objective_c` của simulator vào bản cho iPhone thật
# (xem giải thích trong tool/run_ios.sh).
#
# Cách dùng:  tool/build_ipa.sh [tham số khác của flutter build ipa]
#   Nhớ tăng số build trong pubspec.yaml (version: x.y.z+N) trước khi build.
set -euo pipefail
cd "$(dirname "$0")/.."

rm -rf build/native_assets/ios .dart_tool/flutter_build
exec flutter build ipa "$@"
