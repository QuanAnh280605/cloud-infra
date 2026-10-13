# 🔒 Hướng Dẫn Tự Động Cấp SSL/HTTPS (Cert-Manager & Let's Encrypt)

Cert-manager cho phép cấp và tự động gia hạn chứng chỉ SSL miễn phí từ **Let's Encrypt** cho toàn bộ ứng dụng web chạy trên cụm K3s.

---

## 1. 🚀 Cài Đặt Cert-Manager Trong 1 Click

Chạy script cài đặt trên VPS:

```bash
cd ~/cloud-infra/cluster/cert-manager
chmod +x install.sh
./install.sh
```

Kiểm tra trạng thái sau khi cài đặt:
```bash
kubectl get pods -n cert-manager
kubectl get clusterissuer
```

---

## 2. 🌐 Cách Bật HTTPS Cho Bất Kỳ Ứng Dụng Nào

Để một ứng dụng có chứng chỉ SSL HTTPS hợp lệ:

1. **Trỏ tên miền (DNS):**
   Tạo bản ghi `A` trỏ tên miền (ví dụ: `app.yourdomain.com`) về IP VPS `140.245.58.162`.

2. **Cập nhật Ingress của ứng dụng:**
   Thêm annotation `cert-manager.io/cluster-issuer: letsencrypt-prod` và khối `tls:` vào file `ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
spec:
  tls:
    - hosts:
        - app.yourdomain.com
      secretName: my-app-tls # Cert-manager sẽ tự động tạo secret này
  rules:
    - host: app.yourdomain.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app-service
                port:
                  number: 80
```

3. **Kiểm tra chứng chỉ SSL:**
```bash
# Xem quá trình cấp chứng chỉ
kubectl get certificate -A
kubectl describe certificate my-app-tls -n <namespace>
```

Chứng chỉ sẽ được tự động gia hạn trước khi hết hạn 30 ngày mà không cần can thiệp thủ công.
