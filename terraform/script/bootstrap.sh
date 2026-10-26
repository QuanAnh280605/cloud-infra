#!/usr/bin/env bash
ADMIN_EMAIL="${1:-admin@example.com}"
VPS_IP="${2:-$(curl -s https://api.ipify.org)}"
set -e
echo "=========================================================="
echo "🚀 [1/3] Đang cài đặt K3s (Lightweight Kubernetes)..."
echo "=========================================================="
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -
echo "=========================================================="
echo "⏳ [2/3] Chờ cụm K3s chuyển sang trạng thái Ready..."
echo "=========================================================="
until kubectl get nodes | grep -w "Ready" > /dev/null 2>&1; do
    echo "  -> Đang chờ K3s khởi động..."
    sleep 3
done
echo "  -> K3s Node đã Ready!"
echo "=========================================================="
echo "📦 [3/3] Đang tải và cài đặt Helm Package Manager..."
echo "=========================================================="
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
echo "=========================================================="
echo "🎉 HOÀN TẤT SETUP K3S VÀ HELM QUA TERRAFORM!"
echo "=========================================================="
kubectl get nodes -o wide
helm version --short

echo "=========================================================="
echo "🔒 [4/5] Đang cài đặt Cert-Manager v1.16.2..."
echo "=========================================================="
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
echo "=========================================================="
echo "⏳ Chờ Cert-Manager Webhook sẵn sàng..."
echo "=========================================================="
# Bắt buộc phải chờ Webhook chạy xong thì mới tạo được ClusterIssuer phía dưới
kubectl rollout status deployment/cert-manager-webhook -n cert-manager --timeout=120s
echo "=========================================================="
echo "📜 [5/5] Đang tạo ClusterIssuer (Let's Encrypt Production)..."
echo "=========================================================="
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${ADMIN_EMAIL} 
    privateKeySecretRef:
      name: letsencrypt-prod-key
    solvers:
      - http01:
          ingress:
            class: traefik
EOF
echo "=========================================================="
echo "🎉 HOÀN TẤT TOÀN BỘ CỤM K3S + HELM + CERT-MANAGER!"
echo "=========================================================="
kubectl get clusterissuer

echo "=========================================================="
echo "🐙 [6/6] Đang cài đặt ArgoCD GitOps Engine..."
echo "=========================================================="
# 1. Tạo namespace và cài ArgoCD
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# 2. Cấu hình để Ingress Traefik và Cert-Manager xử lý SSL
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'

kubectl rollout restart deployment argocd-server -n argocd

echo "=========================================================="
echo "⏳ Chờ ArgoCD Server sẵn sàng..."
echo "=========================================================="
kubectl rollout status deployment/argocd-server -n argocd --timeout=180s
echo "=========================================================="
echo "🌐 Đang tạo Ingress & SSL HTTPS cho ArgoCD Web UI..."
echo "=========================================================="
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
spec:
  ingressClassName: traefik
  rules:
    - host: argocd.${VPS_IP}.nip.io
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  number: 80
  tls:
    - hosts:
        - argocd.${VPS_IP}.nip.io
      secretName: argocd-server-tls
EOF
echo "=========================================================="
echo "🔑 LẤY THÔNG TIN ĐĂNG NHẬP ARGOCD"
echo "=========================================================="
echo "URL Truy cập: https://argocd.${VPS_IP}.nip.io"
echo "Tài khoản   : admin"
echo -n "Mật khẩu    : "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
echo "=========================================================="