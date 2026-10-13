# 🌐 Cloud Infra & Multi-App VPS Platform

Hệ thống quản lý tập trung toàn bộ hạ tầng đám mây (Oracle Cloud Infrastructure) và cụm Kubernetes (K3s) trên con VPS `140.245.58.162`. 

Kho lưu trữ này cho phép bạn **quản lý, giám sát và triển khai bất kỳ ứng dụng nào** (Backend, Frontend, Microservices, Bot...) lên VPS một cách độc lập, bảo mật và an toàn dữ liệu.

---

## 🏗️ Cấu Trúc Thư Mục

```text
cloud-infra/
├── .github/workflows/        # CI/CD tự động kiểm tra cú pháp Terraform & K8s
│   └── ci.yml
│
├── terraform/                # Infrastructure as Code (IaC) - Quản lý VCN, Subnet, Firewall, VPS
│   ├── main.tf
│   ├── versions.tf
│   ├── outputs.tf
│   └── modules/vpc/          # Module mạng phân tầng Public & Private
│
├── cluster/                  # Quản lý & Vận hành Cụm K3s
│   ├── init-vps.sh           # Bootstrap VPS mới trong 1 click (K3s + Helm + Firewall)
│   ├── deploy-all.sh         # Triển khai toàn bộ ứng dụng theo thứ tự
│   │
│   ├── cert-manager/         # Tự động cấp phát SSL/HTTPS (Let's Encrypt)
│   │   ├── install.sh        # Cài đặt cert-manager ARM64
│   │   ├── cluster-issuer.yaml # ClusterIssuer Staging & Prod
│   │   └── README.md
│   │
│   └── scripts/              # Bộ công cụ vận hành hàng ngày (Ops Tools)
│       ├── status.sh         # Kiểm tra chi tiết RAM, CPU, SSD 47GB, Nodes & Pods
│       ├── maintenance.sh    # Dọn dẹp images rác & logs cũ chống đầy đĩa
│       └── backup.sh         # Tự động sao lưu PostgreSQL (p069) & SQLite (bot)
│
└── apps/                     # Quản lý các dự án triển khai trên VPS
    ├── p069/                 # Ứng dụng P-069 AI Semantic Layer (Helm Chart & k8s-raw)
    │   ├── Chart.yaml
    │   ├── values.yaml
    │   ├── deploy.sh         # Script deploy 1-click cho p069
    │   ├── namespace.yaml
    │   ├── templates/        # Helm templates
    │   └── k8s-raw/          # Manifests thuần cho học tập & debug
    │
    ├── expense-tracker-bot/  # Bot Telegram Quản Lý Thu Chi Cá Nhân
    │   ├── deployment.yaml   # Strategy Recreate (Bảo vệ SQLite)
    │   ├── pvc.yaml          # Local-path volume 1GB
    │   ├── deploy.sh         # Script deploy 1-click cho Bot
    │   └── README.md
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
- **Tài nguyên còn trống khả dụng:** **~9.5 GB RAM (80%)** và **95% CPU**.

---

## 🛠️ Bộ Lệnh Vận Hành Cụm Hàng Ngày (Quick Ops)

Đăng nhập SSH vào VPS: `ssh ubuntu@140.245.58.162`

| Tác vụ | Lệnh thực thi | Ghi chú |
|---|---|---|
| **Kiểm tra sức khỏe hệ thống** | `./cluster/scripts/status.sh` | Xem RAM, CPU, ổ đĩa 47GB, Pods & PVC |
| **Dọn dẹp ổ đĩa định kỳ** | `./cluster/scripts/maintenance.sh` | Xóa container image rác & journal log cũ |
| **Sao lưu dữ liệu (Backup)** | `./cluster/scripts/backup.sh` | Dump Postgres & SQLite thành `.tar.gz` |
| **Bật SSL HTTPS tự động** | `cd cluster/cert-manager && ./install.sh` | Kích hoạt Cert-Manager & Let's Encrypt |
| **Deploy toàn bộ ứng dụng** | `./cluster/deploy-all.sh` | Cập nhật p069 và expense-tracker-bot |

---

## 🚀 Cách Cắm Thêm Dự Án Mới Lên VPS Trong 3 Bước

1. **Chuẩn bị Docker Image:** Build image hỗ trợ đa kiến trúc `linux/arm64` và push lên GitHub Container Registry (GHCR).
2. **Khai báo App mới:** 
   - Nhân bản thư mục `apps/_template-backend/` thành `apps/<ten-du-an-moi>/`.
   - Cập nhật link image và domain trong `deployment.yaml` & `ingress.yaml`.
3. **Triển khai:** Chạy `kubectl apply -f apps/<ten-du-an-moi>/` trên VPS.

Chi tiết xem tại [`apps/_template-backend/README.md`](apps/_template-backend/README.md).
