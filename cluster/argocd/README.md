# 🐙 ArgoCD GitOps Engine

Hệ thống GitOps Continuous Delivery tự động hóa triển khai ứng dụng trên cụm K3s Oracle Cloud.

---

## 🚀 Triển Khai Nhanh

Đăng nhập SSH vào VPS và chạy lệnh:

```bash
cd /home/ubuntu/cloud-infra/cluster/argocd
chmod +x install.sh
./install.sh
```

---

## 🌐 Truy Cập Giao Diện (Web UI)

- **URL:** [http://argocd.140.245.58.162.nip.io](http://argocd.140.245.58.162.nip.io)
- **Tài khoản:** `admin`
- **Lấy mật khẩu ban đầu:**
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
  ```

---

## ⚙️ Cấu Hình Tối Ưu (Resource Sizing)

Được cấu hình chế độ **Non-HA** dành riêng cho cụm đơn 1 node (ARM64 12GB RAM):
- Tắt Dex SSO & Notifications để tiết kiệm ~200MB RAM.
- Giới hạn tổng RAM yêu cầu: ~320 MB (tối đa ~1.1 GB).
- Sử dụng Redis standalone có healthcheck.
