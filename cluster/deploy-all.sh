#!/usr/bin/env bash
# ==============================================================================
# Script Triển Khai Toàn Bộ Ứng Dụng Trên Cụm VPS K3s
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$SCRIPT_DIR/../apps"

BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
NC="\033[0m"

echo -e "${BOLD}${CYAN}==================================================================${NC}"
echo -e "${BOLD}${CYAN}   🚀 TRIỂN KHAI TOÀN BỘ ỨNG DỤNG LÊN NỀN TẢNG K3S VPS          ${NC}"
echo -e "${BOLD}${CYAN}==================================================================${NC}"

# Triển khai tất cả các ứng dụng có trong thư mục apps/
APP_COUNT=0
for app_dir in "$APPS_DIR"/*; do
    if [ -d "$app_dir" ] && [ -f "$app_dir/deploy.sh" ]; then
        APP_NAME=$(basename "$app_dir")
        echo -e "\n${BOLD}${GREEN}📦 Triển khai ứng dụng: $APP_NAME...${NC}"
        chmod +x "$app_dir/deploy.sh"
        "$app_dir/deploy.sh" || true
        APP_COUNT=$((APP_COUNT + 1))
    fi
done

if [ $APP_COUNT -eq 0 ]; then
    echo -e "\n${BOLD}${GREEN}ℹ️ Chưa có ứng dụng nào được cấu hình trong apps/. Sẵn sàng cho dự án mới!${NC}"
fi

echo -e "\n${BOLD}${CYAN}==================================================================${NC}"
echo -e "${BOLD}${GREEN}🎉 Hoàn tất quy trình triển khai toàn bộ ứng dụng!${NC}"
echo -e "${BOLD}${CYAN}==================================================================${NC}"
"$SCRIPT_DIR/scripts/status.sh"
