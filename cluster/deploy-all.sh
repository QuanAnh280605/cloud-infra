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

# 1. Triển khai P-069 AI Semantic Layer
if [ -d "$APPS_DIR/p069" ] && [ -f "$APPS_DIR/p069/deploy.sh" ]; then
    echo -e "\n${BOLD}${GREEN}📦 [1/2] Triển khai ứng dụng P-069...${NC}"
    chmod +x "$APPS_DIR/p069/deploy.sh"
    "$APPS_DIR/p069/deploy.sh" helm
fi

# 2. Triển khai Expense Tracker Bot
if [ -d "$APPS_DIR/expense-tracker-bot" ] && [ -f "$APPS_DIR/expense-tracker-bot/deploy.sh" ]; then
    echo -e "\n${BOLD}${GREEN}🤖 [2/2] Triển khai Expense Tracker Bot...${NC}"
    chmod +x "$APPS_DIR/expense-tracker-bot/deploy.sh"
    "$APPS_DIR/expense-tracker-bot/deploy.sh" || true
fi

echo -e "\n${BOLD}${CYAN}==================================================================${NC}"
echo -e "${BOLD}${GREEN}🎉 Hoàn tất quy trình triển khai toàn bộ ứng dụng!${NC}"
echo -e "${BOLD}${CYAN}==================================================================${NC}"
"$SCRIPT_DIR/scripts/status.sh"
