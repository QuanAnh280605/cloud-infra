#!/usr/bin/env bash
# ==============================================================================
# Script Bootstrap chuẩn hóa VPS Oracle Cloud (Ubuntu ARM64) chạy K3s & Helm
# ==============================================================================

set -e

echo "🚀 [1/4] Cập nhật hệ điều hành..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y curl wget git jq ufw htop

echo "☸️ [2/4] Cài đặt K3s (Lightweight Kubernetes)..."
if ! command -v k3s &> /dev/null; then
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -
    echo "K3s đã được cài đặt thành công!"
else
    echo "K3s đã tồn tại, bỏ qua."
fi

echo "📦 [3/4] Cài đặt Helm CLI..."
if ! command -v helm &> /dev/null; then
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
    echo "Helm đã được cài đặt thành công!"
else
    echo "Helm đã tồn tại, bỏ qua."
fi

echo "🛡️ [4/4] Cấu hình Firewall (Mở port Web & K3s)..."
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT || true
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT || true
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 6443 -j ACCEPT || true
sudo netfilter-persistent save || true

echo "✅ Hoàn tất bootstrap cụm VPS K3s!"
