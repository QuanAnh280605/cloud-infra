#!/usr/bin/env bash
# ==============================================================================
# Script Kiểm Tra Trạng Thái Toàn Diện Cụm VPS K3s & Các Ứng Dụng
# ==============================================================================

set -e

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${BOLD}${CYAN}==================================================================${NC}"
echo -e "${BOLD}${CYAN}   🌐 BÁO CÁO TRẠNG THÁI HẠ TẦNG VPS & KUBERNETES (K3S)          ${NC}"
echo -e "${BOLD}${CYAN}==================================================================${NC}"

# 1. THÔNG SỐ PHẦN CỨNG VPS
echo -e "\n${BOLD}${GREEN}1. 🖥️  Tài Nguyên Máy Chủ VPS${NC}"
echo "--------------------------------------------------"
UPTIME_INFO=$(uptime -p 2>/dev/null || uptime)
echo -e "⏱️  Uptime: ${UPTIME_INFO}"

echo -e "\n💾 Dung lượng Ổ đĩa (SSD 47GB):"
df -h / | awk 'NR==1 || NR==2 {printf "   %-20s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5}'

echo -e "\n🧠 Bộ nhớ RAM (12GB ARM64):"
free -h | awk 'NR==1 || NR==2 {printf "   %-10s %-10s %-10s %-10s %-10s\n", $1, $2, $3, $4, $7}'

# 2. TRẠNG THÁI K3S NODE
echo -e "\n${BOLD}${GREEN}2. ☸️  Trạng Thái K3s Node & Service${NC}"
echo "--------------------------------------------------"
if systemctl is-active --quiet k3s; then
    echo -e "K3s Service: ${GREEN}Active (Running)${NC}"
else
    echo -e "K3s Service: ${RED}Inactive / Stopped${NC}"
fi

kubectl get nodes -o wide 2>/dev/null || echo -e "${RED}Không thể kết nối tới K3s API server!${NC}"

# 3. DANH SÁCH NAMESPACE VÀ ỨNG DỤNG
echo -e "\n${BOLD}${GREEN}3. 📦 Danh Sách Namespace Đang Hoạt Động${NC}"
echo "--------------------------------------------------"
kubectl get namespaces

# 4. TRẠNG THÁI CÁC POD TRÊN TOÀN BỘ CỤM
echo -e "\n${BOLD}${GREEN}4. 🚀 Trạng Thái Toàn Bộ Pods (Tất Cả Namespaces)${NC}"
echo "--------------------------------------------------"
kubectl get pods -A -o wide

# 5. LƯU TRỮ DỮ LIỆU PERSISTENT VOLUMES (PVC)
echo -e "\n${BOLD}${GREEN}5. 💽 Persistent Volume Claims (PVC) Đang Gắn${NC}"
echo "--------------------------------------------------"
kubectl get pvc -A 2>/dev/null || echo "Chưa có PVC nào."

# 6. INGRESS VÀ CỔNG TRUY CẬP NGOÀI
echo -e "\n${BOLD}${GREEN}6. 🌐 Ingress & Routing${NC}"
echo "--------------------------------------------------"
kubectl get ingress -A 2>/dev/null || echo "Chưa có Ingress nào."

# 7. TRẠNG THÁI GITOPS ARGOCD
if kubectl get applications -n argocd &>/dev/null; then
    echo -e "\n${BOLD}${GREEN}7. 🐙 Ứng Dụng Quản Lý Bởi ArgoCD (GitOps)${NC}"
    echo "--------------------------------------------------"
    kubectl get applications -n argocd
fi

# 8. METRICS TIÊU THỤ TÀI NGUYÊN (NẾU METRICS-SERVER KHẢ DỤNG)
echo -e "\n${BOLD}${GREEN}8. 📊 Tiêu Thụ Tài Nguyên Pod (CPU / RAM)${NC}"
echo "--------------------------------------------------"
if kubectl top pods -A &>/dev/null; then
    kubectl top pods -A
else
    echo -e "${YELLOW}Ghi chú: metrics-server chưa bật hoặc đang khởi tạo số liệu.${NC}"
fi

echo -e "\n${BOLD}${CYAN}==================================================================${NC}"
echo -e "${GREEN}✅ Hoàn tất kiểm tra trạng thái lúc: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${BOLD}${CYAN}==================================================================${NC}"
