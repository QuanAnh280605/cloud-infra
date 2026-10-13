#!/usr/bin/env bash
# ==============================================================================
# Script Tự Động Dọn Dẹp Định Kỳ VPS & K3s (Bảo vệ ổ đĩa SSD 47GB của Oracle Cloud)
# ==============================================================================

set -e

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
NC="\033[0m"

echo -e "${BOLD}${CYAN}==================================================================${NC}"
echo -e "${BOLD}${CYAN}   🧹 BẮT ĐẦU QUY TRÌNH DỌN DẸP & BẢO TRÌ VPS K3S               ${NC}"
echo -e "${BOLD}${CYAN}==================================================================${NC}"

# 1. BÁO CÁO DUNG LƯỢNG TRƯỚC KHI DỌN DẸP
echo -e "\n${BOLD}${YELLOW}[1/5] Dung lượng ổ đĩa TRƯỚC khi dọn dẹp:${NC}"
df -h / | awk 'NR==1 || NR==2'

# 2. XÓA CÁC POD BỊ LỖI, CRASH HOẶC HOÀN THÀNH (Completed / Evicted / Error)
echo -e "\n${BOLD}${GREEN}[2/5] Dọn dẹp Pods ở trạng thái rác (Completed / Evicted / Error)...${NC}"
FAILED_PODS=$(kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Pending -o jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}' 2>/dev/null || true)

if [ -n "$FAILED_PODS" ]; then
    echo "$FAILED_PODS" | while read -r ns pod; do
        if [ -n "$pod" ]; then
            echo "  -> Đang xóa Pod $ns/$pod..."
            kubectl delete pod "$pod" -n "$ns" --grace-period=0 --force 2>/dev/null || true
        fi
    done
else
    echo "  -> Không có Pod rác cần dọn dẹp."
fi

# 3. DỌN DẸP DOCKER / CONTAINERD IMAGES KHÔNG DÙNG (K3s crictl)
echo -e "\n${BOLD}${GREEN}[3/5] Dọn dẹp Container Images không còn sử dụng trong containerd...${NC}"
if command -v k3s &>/dev/null; then
    echo "  -> Thu hồi không gian từ K3s containerd..."
    sudo k3s crictl rmi --prune 2>/dev/null || true
fi

if command -v docker &>/dev/null; then
    echo "  -> Thu hồi không gian từ Docker..."
    docker image prune -af --filter "until=72h" 2>/dev/null || true
fi

# 4. THU GỌN LOG HỆ THỐNG SYSTEMD JOURNALD
echo -e "\n${BOLD}${GREEN}[4/5] Cắt tỉa System Logs (chỉ giữ tối đa 3 ngày / 500MB)...${NC}"
sudo journalctl --vacuum-time=3d 2>/dev/null || true
sudo journalctl --vacuum-size=500M 2>/dev/null || true

# 5. DỌN DẸP APT CACHE VÀ GÓI CÀI ĐẶT THỪA
echo -e "\n${BOLD}${GREEN}[5/5] Dọn dẹp bộ nhớ đệm APT và file tạm hệ thống...${NC}"
sudo apt-get autoremove -y 2>/dev/null || true
sudo apt-get clean 2>/dev/null || true
sudo rm -rf /tmp/* /var/tmp/* 2>/dev/null || true

# 6. BÁO CÁO DUNG LƯỢNG SAU KHI DỌN DẸP
echo -e "\n${BOLD}${CYAN}==================================================================${NC}"
echo -e "${BOLD}${GREEN}✅ Dung lượng ổ đĩa SAU khi dọn dẹp:${NC}"
df -h / | awk 'NR==1 || NR==2'
echo -e "${BOLD}${CYAN}==================================================================${NC}"
echo -e "💡 Gợi ý: Bạn có thể thêm script này vào crontab hàng tuần:"
echo -e "   0 3 * * 0 /home/ubuntu/cloud-infra/cluster/scripts/maintenance.sh > /dev/null 2>&1"
