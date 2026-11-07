#!/usr/bin/env bash
# Chạy app iOS trên iPhone thật hoặc simulator mà không bị lỗi
# "Couldn't resolve native function 'DOBJC_initializeApi' ... objective_c".
#
# Nguyên nhân: Flutter dùng chung thư mục build/native_assets/ios cho cả iPhone
# thật và simulator; chuyển qua lại giữa hai loại thiết bị làm app dính nhầm
# thư viện `objective_c` của loại kia. Script xóa cache đó trước khi chạy.
#
# Cách dùng:  tool/run_ios.sh <id-hoặc-tên-thiết-bị> [tham số khác của flutter run]
#   tool/run_ios.sh C00EEE86-038A-4753-A3CF-77686BC88F5F      # simulator
#   tool/run_ios.sh 00008020-000A6C603A21002E                # iPhone thật
set -euo pipefail
cd "$(dirname "$0")/.."

if [ $# -lt 1 ]; then
  echo "Thiếu id thiết bị. Xem danh sách bằng: flutter devices" >&2
  exit 1
fi

rm -rf build/native_assets/ios .dart_tool/flutter_build
exec flutter run -d "$@"
