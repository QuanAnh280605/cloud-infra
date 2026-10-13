#!/usr/bin/env bash
# ==============================================================================
# Script Cài Đặt Cert-Manager & Cấu Hình ClusterIssuer Trên K3s VPS (ARM64)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_MANAGER_VERSION="v1.16.2"

echo "🔒 [1/3] Đang tải và cài đặt cert-manager $CERT_MANAGER_VERSION..."
kubectl apply -f "https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml"

echo "⏳ [2/3] Chờ cert-manager pods khởi động hoàn tất..."
kubectl rollout status deployment/cert-manager -n cert-manager --timeout=120s
kubectl rollout status deployment/cert-manager-webhook -n cert-manager --timeout=120s
kubectl rollout status deployment/cert-manager-cainjector -n cert-manager --timeout=120s

echo "📜 [3/3] Áp dụng ClusterIssuer (Let's Encrypt Staging & Prod)..."
kubectl apply -f "$SCRIPT_DIR/cluster-issuer.yaml"

echo "✅ Hoàn tất cài đặt cert-manager!"
echo "Kiểm tra ClusterIssuer bằng lệnh:"
echo "kubectl get clusterissuer"
