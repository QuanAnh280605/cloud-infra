#!/usr/bin/env bash
# ==============================================================================
# Script triển khai hoặc cập nhật Expense Tracker Bot lên K3s VPS
# ==============================================================================

set -e

NAMESPACE="expense-tracker"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 [1/4] Tạo namespace $NAMESPACE nếu chưa có..."
kubectl apply -f "$SCRIPT_DIR/namespace.yaml"

echo "💾 [2/4] Cấu hình PVC lưu trữ SQLite và ConfigMap..."
kubectl apply -f "$SCRIPT_DIR/pvc.yaml"
kubectl apply -f "$SCRIPT_DIR/configmap.yaml"

echo "🔑 [3/4] Kiểm tra Secret..."
if ! kubectl get secret expense-bot-secret -n "$NAMESPACE" &> /dev/null; then
    if [ -f "$SCRIPT_DIR/.env" ]; then
        echo "Tạo secret từ file $SCRIPT_DIR/.env..."
        BOT_TOKEN=$(grep -E '^TELEGRAM_BOT_TOKEN=' "$SCRIPT_DIR/.env" | cut -d '=' -f2- | tr -d '"' | tr -d "'" || true)
        GROQ_KEY=$(grep -E '^GROQ_API_KEY=' "$SCRIPT_DIR/.env" | cut -d '=' -f2- | tr -d '"' | tr -d "'" || true)
        if [ -n "$BOT_TOKEN" ] && [ -n "$GROQ_KEY" ]; then
            kubectl create secret generic expense-bot-secret \
                --from-literal=TELEGRAM_BOT_TOKEN="$BOT_TOKEN" \
                --from-literal=GROQ_API_KEY="$GROQ_KEY" \
                -n "$NAMESPACE"
        else
            kubectl create secret generic expense-bot-secret --from-env-file="$SCRIPT_DIR/.env" -n "$NAMESPACE"
        fi
    elif [ -f "$SCRIPT_DIR/secret.yaml" ]; then
        echo "Tạo secret từ file $SCRIPT_DIR/secret.yaml..."
        kubectl apply -f "$SCRIPT_DIR/secret.yaml"
    else
        echo "❌ Lỗi: Chưa tìm thấy secret.yaml hoặc .env chứa TELEGRAM_BOT_TOKEN và GROQ_API_KEY!"
        echo "Hãy tạo file secret.yaml (dựa trên secret.example.yaml) hoặc .env trong thư mục này rồi chạy lại."
        exit 1
    fi
else
    echo "Secret expense-bot-secret đã tồn tại, tiếp tục."
fi

echo "🤖 [4/4] Áp dụng Deployment..."
kubectl apply -f "$SCRIPT_DIR/deployment.yaml"

# Restart deployment để kéo image mới nhất nếu đang cập nhật
echo "🔄 Đang cập nhật Pod với image mới nhất..."
kubectl rollout restart deployment/expense-bot -n "$NAMESPACE"
kubectl rollout status deployment/expense-bot -n "$NAMESPACE" --timeout=60s

echo "✅ Triển khai thành công! Kiểm tra logs bằng lệnh:"
echo "kubectl logs -f -n $NAMESPACE -l app=expense-bot"
