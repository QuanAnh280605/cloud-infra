#!/usr/bin/env bash
# ==============================================================================
# Script Cài đặt & Cập nhật ArgoCD trên Cụm K3s (Ubuntu ARM64)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="${SCRIPT_DIR}/values.yaml"
NAMESPACE="argocd"

echo "☸️ [1/4] Chuẩn bị namespace: ${NAMESPACE}..."
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

echo "📦 [2/4] Cập nhật Helm repository cho ArgoCD..."
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
helm repo update argo

echo "🚀 [3/4] Cài đặt / Nâng cấp ArgoCD (Non-HA Mode)..."
helm upgrade --install argocd argo/argo-cd \
  --namespace ${NAMESPACE} \
  --values "${VALUES_FILE}" \
  --wait \
  --timeout 5m

echo "⏳ [4/4] Đợi các pods ArgoCD sẵn sàng..."
kubectl rollout status deployment/argocd-server -n ${NAMESPACE} --timeout=120s
kubectl rollout status deployment/argocd-repo-server -n ${NAMESPACE} --timeout=120s
kubectl rollout status statefulset/argocd-application-controller -n ${NAMESPACE} --timeout=120s

echo ""
echo "=============================================================================="
echo "✅ ArgoCD đã được cài đặt và vận hành thành công!"
echo "=============================================================================="
echo "🌐 URL truy cập Web UI:"
echo "   http://argocd.140.245.58.162.nip.io"
echo ""
echo "🔑 Mật khẩu Admin ban đầu:"
ADMIN_PASS=$(kubectl -n ${NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "Không tìm thấy hoặc đã đổi mật khẩu")
echo "   Username: admin"
echo "   Password: ${ADMIN_PASS}"
echo "=============================================================================="
