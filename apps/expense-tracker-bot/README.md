# 🤖 Triển Khai Telegram Expense Tracker Bot Lên K3s VPS

Hướng dẫn triển khai bot Telegram quản lý thu chi tự động lên cụm K3s trên VPS Oracle Cloud (`140.245.58.162`).

---

## 🏗️ Kiến Trúc Triển Khai

- **Chế độ hoạt động:** Telegram Long Polling (Bot tự động kết nối ra ngoài tới `api.telegram.org` nên **không cần mở port, không cần Ingress / Domain / SSL**).
- **Lưu trữ dữ liệu:** Dùng `PersistentVolumeClaim` (K3s `local-path`, 1GB) mount vào thư mục `/app/data` trong container để bảo vệ file `expense_tracker.db` không bị mất khi restart pod.
- **Chiến lược triển khai:** `strategy.type: Recreate` (đảm bảo chỉ duy nhất 1 Pod bot hoạt động tại một thời điểm, tránh lỗi Telegram 409 Conflict).
- **Tài nguyên sử dụng:** Cực kỳ nhẹ (~50m CPU, ~100MB RAM).

---

## 🚀 Các Bước Triển Khai Lên VPS

### Cách 1: Chạy Script Tự Động (Khuyên Dùng)

1. SSH vào VPS:
   ```bash
   ssh ubuntu@140.245.58.162
   ```

2. Di chuyển vào thư mục repo `cloud-infra`:
   ```bash
   cd ~/cloud-infra # hoặc đường dẫn thư mục cloud-infra trên VPS của bạn
   git pull origin main
   ```

3. Tạo file secret hoặc `.env`:
   ```bash
   cd apps/expense-tracker-bot
   cp secret.example.yaml secret.yaml
   # Điền TELEGRAM_BOT_TOKEN và GROQ_API_KEY vào secret.yaml
   nano secret.yaml
   ```

4. Chạy script deploy:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

---

### Cách 2: Triển Khai Thủ Công Bằng `kubectl`

```bash
# 1. Tạo namespace
kubectl apply -f apps/expense-tracker-bot/namespace.yaml

# 2. Tạo Secret từ file .env hoặc yaml
kubectl create secret generic expense-bot-secret \
  --from-literal=TELEGRAM_BOT_TOKEN="token_cua_ban" \
  --from-literal=GROQ_API_KEY="key_cua_ban" \
  -n expense-tracker

# 3. Tạo PVC lưu dữ liệu SQLite và ConfigMap
kubectl apply -f apps/expense-tracker-bot/pvc.yaml
kubectl apply -f apps/expense-tracker-bot/configmap.yaml

# 4. Triển khai Bot
kubectl apply -f apps/expense-tracker-bot/deployment.yaml
```

---

## 🔍 Kiểm Tra Trạng Thái & Xem Logs

- Xem trạng thái Pod:
  ```bash
  kubectl get pods -n expense-tracker
  ```
- Xem log thời gian thực của bot:
  ```bash
  kubectl logs -f -n expense-tracker -l app=expense-bot
  ```
- Khởi động lại Bot (để kéo code/image mới nhất):
  ```bash
  kubectl rollout restart deployment/expense-bot -n expense-tracker
  ```
