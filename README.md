# 🌐 Cloud Infra & Multi-App VPS Platform

Hệ thống quản lý tập trung toàn bộ hạ tầng đám mây (Oracle Cloud Infrastructure) và cụm Kubernetes (K3s) trên con VPS `140.245.58.162`. 

Kho lưu trữ này cho phép bạn **quản lý, giám sát và triển khai bất kỳ ứng dụng nào** (Backend, Frontend, Microservices, Bot...) lên VPS một cách độc lập và an toàn.

---

## 🏗️ Cấu Trúc Thư Mục

```text
cloud-infra/
├── terraform/                # Infrastructure as Code (IaC) - Quản lý VCN, Subnet, Firewall, VPS
│   ├── main.tf
│   ├── versions.tf
│   ├── outputs.tf
│   └── modules/vpc/          # Module mạng phân tầng Public & Private
│
├── cluster/                  # Script cài đặt & cấu hình nền tảng K3s
│   └── init-vps.sh           # Bootstrap VPS mới trong 1 click
│
└── apps/                     # Quản lý các dự án triển khai trên VPS
    ├── p069/                 # Ứng dụng P-069 AI Semantic Layer (Helm Chart)
    │   ├── Chart.yaml
    │   ├── values.yaml
    │   └── templates/
    │
    └── _template-backend/    # ⚡ MẪU CẮM BACKEND MỚI (Copy thư mục này để tạo app mới)
        ├── deployment.yaml
        ├── service.yaml
        ├── ingress.yaml
        ├── configmap-secret.yaml
        └── README.md
```

---

## 🖥️ Thông Số Hạ Tầng VPS Hiện Tại

- **Nhà cung cấp:** Oracle Cloud Infrastructure (Region `ap-singapore-2`).
- **Cấu hình phần cứng:** `VM.Standard.A1.Flex` (2 OCPU Ampere ARM, 12 GB RAM, 47 GB Storage).
- **Hạn mức chi phí:** **0 USD / tháng (Always Free trọn đời)**.
- **Tài nguyên còn trống khả dụng:** **~9.8 GB RAM (84%)** và **96% CPU**.

---

## 🚀 Cách Cắm Thêm Dự Án Mới Lên VPS Trong 3 Bước

1. **Chuẩn bị Docker Image:** Build image cho dự án mới hỗ trợ `linux/arm64` và push lên GitHub Container Registry (GHCR).
2. **Khai báo App mới:** 
   - Nhân bản thư mục `apps/_template-backend/` thành `apps/<ten-du-an-moi>/`.
   - Cập nhật link image và domain trong `deployment.yaml` & `ingress.yaml`.
3. **Triển khai:** Chạy `kubectl apply -f apps/<ten-du-an-moi>/` trên VPS.

Chi tiết xem tại [`apps/_template-backend/README.md`](apps/_template-backend/README.md).
