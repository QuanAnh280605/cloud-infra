#!/usr/bin/env bash
# ==============================================================================
# Script Tự Động Sao Lưu Dữ Liệu Các Ứng Dụng (PostgreSQL & SQLite)
# ==============================================================================

set -e

BACKUP_ROOT="/var/backups/cloud-infra"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
RETENTION_DAYS=7

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
NC="\033[0m"

echo -e "${BOLD}${CYAN}==================================================================${NC}"
echo -e "${BOLD}${CYAN}   💾 BẮT ĐẦU QUY TRÌNH SAO LƯU DỮ LIỆU TỰ ĐỘNG                 ${NC}"
echo -e "${BOLD}${CYAN}==================================================================${NC}"

# 1. TẠO THƯ MỤC CHỨA BACKUP
sudo mkdir -p "${BACKUP_DIR}"
echo -e "\n📁 Thư mục lưu trữ: ${BACKUP_DIR}"

# 2. SAO LƯU SQLITE DATABASE CHO EXPENSE TRACKER BOT
echo -e "\n${BOLD}${GREEN}[1/3] Sao lưu SQLite Database (Expense Tracker Bot)...${NC}"
EXPENSE_POD=$(kubectl get pod -n expense-tracker -l app=expense-bot -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

if [ -n "$EXPENSE_POD" ]; then
    echo "  -> Tìm thấy Pod: expense-tracker/$EXPENSE_POD"
    if kubectl exec -n expense-tracker "$EXPENSE_POD" -- test -f /app/data/expense_tracker.db 2>/dev/null; then
        kubectl exec -n expense-tracker "$EXPENSE_POD" -- sqlite3 /app/data/expense_tracker.db ".backup '/tmp/expense_backup.db'" 2>/dev/null || true
        kubectl cp "expense-tracker/${EXPENSE_POD}:/tmp/expense_backup.db" "${BACKUP_DIR}/expense_tracker.db" 2>/dev/null || true
        kubectl exec -n expense-tracker "$EXPENSE_POD" -- rm -f /tmp/expense_backup.db 2>/dev/null || true
        echo "  -> Đã sao lưu SQLite database thành công."
    else
        echo "  -> File database chưa được tạo trong pod, bỏ qua."
    fi
else
    echo "  -> Pod expense-tracker không chạy, bỏ qua."
fi

# 3. SAO LƯU POSTGRESQL CHO P-069
echo -e "\n${BOLD}${GREEN}[2/3] Sao lưu PostgreSQL Database (P-069 Semantic Layer)...${NC}"
# Tìm pod postgres ở namespace p069 hoặc default
PG_POD=$(kubectl get pod -n p069 -l app=postgres -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
PG_NS="p069"

if [ -z "$PG_POD" ]; then
    PG_POD=$(kubectl get pod -n default -l app=postgres -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
    PG_NS="default"
fi

if [ -n "$PG_POD" ]; then
    echo "  -> Tìm thấy PostgreSQL Pod: $PG_NS/$PG_POD"
    kubectl exec -n "$PG_NS" "$PG_POD" -- pg_dump -U postgres semantic_layer > "${BACKUP_DIR}/p069_postgres.sql" 2>/dev/null || true
    echo "  -> Đã xuất pg_dump thành công vào ${BACKUP_DIR}/p069_postgres.sql"
else
    echo "  -> Pod postgres không hoạt động, bỏ qua."
fi

# 4. ĐÓNG GÓI & NÉN THÀNH FILE TAR.GZ
echo -e "\n${BOLD}${GREEN}[3/3] Nén toàn bộ dữ liệu sao lưu...${NC}"
ARCHIVE_FILE="${BACKUP_ROOT}/backup_${TIMESTAMP}.tar.gz"
sudo tar -czf "${ARCHIVE_FILE}" -C "${BACKUP_ROOT}" "${TIMESTAMP}"
sudo rm -rf "${BACKUP_DIR}"

echo -e "📦 Đã tạo file lưu trữ: ${BOLD}${ARCHIVE_FILE}${NC} ($(ls -lh "${ARCHIVE_FILE}" | awk '{print $5}'))"

# 5. DỌN DẸP BẢN SAO LƯU CŨ HƠN 7 NGÀY
echo -e "\n🧹 Dọn dẹp các file sao lưu cũ hơn ${RETENTION_DAYS} ngày..."
sudo find "${BACKUP_ROOT}" -type f -name "backup_*.tar.gz" -mtime +${RETENTION_DAYS} -exec rm -f {} \;

echo -e "\n${BOLD}${CYAN}==================================================================${NC}"
echo -e "${BOLD}${GREEN}✅ Quy trình sao lưu hoàn tất lúc: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${BOLD}${CYAN}==================================================================${NC}"
echo -e "💡 Gợi ý: Thêm vào crontab để tự động sao lưu mỗi ngày lúc 2h sáng:"
echo -e "   0 2 * * * /home/ubuntu/cloud-infra/cluster/scripts/backup.sh > /dev/null 2>&1"
