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

# 2. SAO LƯU DỮ LIỆU CÁC DATABASE (Tùy chỉnh theo ứng dụng của bạn)
echo -e "\n${BOLD}${GREEN}ℹ️ Kiểm tra sao lưu cơ sở dữ liệu ứng dụng...${NC}"
# Bạn có thể thêm lệnh backup database (PostgreSQL, MySQL, SQLite, MongoDB...) cho ứng dụng mới tại đây:
# Ví dụ:
# PG_POD=$(kubectl get pod -n <namespace> -l app=<db-name> -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
# if [ -n "$PG_POD" ]; then
#     kubectl exec -n <namespace> "$PG_POD" -- pg_dump -U postgres <dbname> > "${BACKUP_DIR}/database.sql" 2>/dev/null || true
# fi
echo "  -> Chưa có database nào được chỉ định để sao lưu. Bỏ qua bước này."

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
