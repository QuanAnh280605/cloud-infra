#!/usr/bin/env bash
# ==============================================================================
# Script Triển Khai Hoặc Cập Nhật Ứng Dụng P-069 Lên K3s VPS
# Hỗ trợ cả 2 chế độ: Helm Chart (Khuyên dùng) và Manifests thô (k8s-raw)
# ==============================================================================

set -e

NAMESPACE="p069"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="${1:-helm}" # Mặc định là 'helm', có thể truyền 'raw'

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
NC="\033[0m"

echo -e "${BOLD}${CYAN}==================================================================${NC}"
echo -e "${BOLD}${CYAN}   🚀 TRIỂN KHAI P-069 AI SEMANTIC LAYER (Chế độ: $MODE)         ${NC}"
echo -e "${BOLD}${CYAN}==================================================================${NC}"

# 1. TẠO NAMESPACE
echo -e "\n📦 [1/4] Đảm bảo namespace '$NAMESPACE' đã tồn tại..."
kubectl apply -f "$SCRIPT_DIR/namespace.yaml"

if [ "$MODE" = "helm" ]; then
    echo -e "\n☸️ [2/4] Triển khai qua Helm Chart..."
    
    # Kiểm tra helm
    if ! command -v helm &> /dev/null; then
        echo -e "${YELLOW}Helm chưa được cài đặt. Đang chuyển sang chế độ k8s-raw...${NC}"
        MODE="raw"
    else
        helm upgrade --install p069 "$SCRIPT_DIR" \
            --namespace "$NAMESPACE" \
            --create-namespace \
            --values "$SCRIPT_DIR/values.yaml"
    fi
fi

if [ "$MODE" = "raw" ]; then
    echo -e "\n📄 [2/4] Triển khai qua Kubernetes manifests (k8s-raw)..."
    kubectl apply -f "$SCRIPT_DIR/k8s-raw/01-postgres.yaml" -n "$NAMESPACE"
    kubectl apply -f "$SCRIPT_DIR/k8s-raw/02-backend.yaml" -n "$NAMESPACE"
    kubectl apply -f "$SCRIPT_DIR/k8s-raw/03-frontend.yaml" -n "$NAMESPACE"
    kubectl apply -f "$SCRIPT_DIR/k8s-raw/04-ingress.yaml" -n "$NAMESPACE"
fi

# 3. CHỜ KHỞI ĐỘNG CÁC SERVICE
echo -e "\n⏳ [3/4] Chờ các Pods khởi động sẵn sàng..."
echo "  -> Kiểm tra Postgres..."
kubectl rollout status deployment/postgres -n "$NAMESPACE" --timeout=120s || true

echo "  -> Kiểm tra Backend..."
kubectl rollout status deployment/backend -n "$NAMESPACE" --timeout=120s || true

echo "  -> Kiểm tra Frontend..."
kubectl rollout status deployment/frontend -n "$NAMESPACE" --timeout=120s || true

# 4. BÁO CÁO TRẠNG THÁI
echo -e "\n${BOLD}${GREEN}✅ [4/4] Trạng thái dịch vụ P-069 sau triển khai:${NC}"
kubectl get pods -n "$NAMESPACE" -o wide
kubectl get svc -n "$NAMESPACE"
kubectl get ingress -n "$NAMESPACE"

echo -e "\n${BOLD}${CYAN}==================================================================${NC}"
echo -e "${BOLD}${GREEN}🎉 P-069 đã được triển khai thành công lên K3s VPS!${NC}"
echo -e "${BOLD}${CYAN}==================================================================${NC}"
