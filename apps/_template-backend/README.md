# 🚀 Hướng Dẫn Deploy Backend Mới Lên VPS Trong 3 Phút

Mẫu template này giúp bạn cắm bất kỳ Backend mới nào (FastAPI, Express/NestJS, Golang, Spring Boot...) lên con VPS Oracle mà không làm ảnh hưởng đến các ứng dụng khác đang chạy.

---

## 3 Bước Triển Khai:

### Bước 1: Chuẩn bị Docker Image
Build Docker image cho dự án của bạn và đẩy lên GitHub Container Registry (GHCR) hoặc Docker Hub.
> ⚠️ **Lưu ý quan trọng:** VPS Oracle sử dụng chip **ARM64 (Ampere A1)**.
> Khi build, hãy đảm bảo hỗ trợ nền tảng `linux/arm64`:
> ```bash
> docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/<username>/<my-backend>:latest --push .
> ```

---

### Bước 2: Tùy chỉnh cấu hình trong thư mục này
1. Nhân bản thư mục `_template-backend/` thành tên dự án mới (ví dụ: `apps/my-new-app/`).
2. Mở file `deployment.yaml`:
   - Đổi `namespace: my-app` thành tên dự án của bạn (ví dụ: `project-b`).
   - Đổi `image:` thành link Docker image vừa push ở Bước 1.
3. Mở file `ingress.yaml`:
   - Đổi `host: api2.yourdomain.com` thành domain bạn muốn trỏ về backend mới.
4. Mở file `configmap-secret.yaml`:
   - Điền các biến môi trường và secret cần thiết.

---

### Bước 3: Áp dụng lên VPS K3s
Mở terminal và chạy lệnh:
```bash
# 1. Tạo namespace mới cho dự án
kubectl create namespace project-b --dry-run=client -o yaml | kubectl apply -f -

# 2. Deploy toàn bộ cấu hình
kubectl apply -f apps/my-new-app/
```

Kiểm tra trạng thái:
```bash
kubectl get pods -n project-b
```
Chỉ sau vài giây, Pod của backend mới sẽ `Running (1/1)` và sẵn sàng nhận traffic từ Internet qua Ingress!
