#!/usr/bin/env bash
# ==============================================================================
# Script đăng ký các Applications vào ArgoCD
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="${SCRIPT_DIR}/apps"

echo "🐙 Đang đăng ký các Applications vào ArgoCD..."

if [ -d "${APPS_DIR}" ]; then
  kubectl apply -f "${APPS_DIR}/" -n argocd
  echo "✅ Đã đăng ký thành công các ứng dụng:"
  kubectl get applications -n argocd
else
  echo "❌ Không tìm thấy thư mục ${APPS_DIR}"
  exit 1
fi
