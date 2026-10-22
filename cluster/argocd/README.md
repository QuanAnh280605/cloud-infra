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

---

## 📖 Hướng Dẫn Tạo Dự Án / Ứng Dụng Mới Trên ArgoCD

Trong ArgoCD có 2 khái niệm bạn cần phân biệt:
1. **Application (Ứng dụng)**: Đơn vị triển khai phần mềm (Backend, Frontend, Bot, Database...). Đây là cái bạn sẽ tạo thường xuyên nhất.
2. **Project (AppProject)**: Ranh giới phân quyền / phân nhóm logic (mặc định luôn có sẵn project tên là `default` để bạn sử dụng ngay).

---

### 👉 Cách 1: Tạo bằng Giao Diện Web UI (Trực quan & Nhanh nhất)

1. Đăng nhập vào [http://argocd.140.245.58.162.nip.io](http://argocd.140.245.58.162.nip.io).
2. Tại màn hình **Applications**, nhấn nút **`+ NEW APP`** ở góc trên bên trái.
3. Điền các thông tin trong form:

#### 1. Mục GENERAL:
- **Application Name**: Tên ứng dụng của bạn (chữ thường, gạch nối, ví dụ: `my-api`).
- **Project Name**: Chọn `default`.
- **Sync Policy**:
  - `Manual`: Đồng bộ bằng tay khi bạn bấm nút Sync (an toàn cho người mới).
  - `Automatic`: Tự động kéo và cập nhật lên cụm K8s mỗi khi có commit mới trên Git (khuyên dùng tick thêm `AUTO-PRUNE` và `SELF-HEAL`).

#### 2. Mục SOURCE (Kho lưu trữ mã nguồn):
- **Repository URL**: Chọn link Git repo của bạn (ví dụ: `git@github.com:QuanAnh280605/cloud-infra.git`).
- **Revision**: Nhánh Git cần theo dõi (ví dụ: `main` hoặc `production`).
- **Path**: Đường dẫn thư mục chứa YAML / Helm Chart trong repo (ví dụ: `apps/_template-backend` hoặc `apps/p069`).

#### 3. Mục DESTINATION (Cụm K8s đích):
- **Cluster URL**: Chọn `https://kubernetes.default.svc` (cụm K3s hiện tại của bạn).
- **Namespace**: Tên namespace trên K8s muốn chạy ứng dụng (ví dụ: `my-api-ns` hoặc `default`).

4. Nhấn nút **`CREATE`** ở góc trên cùng bên trái.
5. Card ứng dụng mới sẽ xuất hiện! Nhấn vào ứng dụng và bấm nút **`SYNC`** để ArgoCD kéo code và tạo Pods trên K8s.

---

### 👉 Cách 2: Tạo chuẩn GitOps bằng File YAML (Khuyên dùng cho DevOps)

Cách này lưu toàn bộ định nghĩa ứng dụng vào Git để quản lý phiên bản.

1. Tạo file mới: `cluster/argocd/apps/app-<ten-du-an>.yaml`:
   ```yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: my-new-app
     namespace: argocd
     finalizers:
       - resources-finalizer.argocd.argoproj.io
   spec:
     project: default
     source:
       repoURL: git@github.com:QuanAnh280605/cloud-infra.git
       targetRevision: main
       path: apps/my-new-app           # Thư mục chứa YAML hoặc Helm chart
     destination:
       server: https://kubernetes.default.svc
       namespace: my-new-app-ns        # Namespace chạy ứng dụng
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
       syncOptions:
         - CreateNamespace=true        # Tự tạo namespace nếu chưa có
   ```

2. Đăng ký lên K3s:
   ```bash
   ./cluster/argocd/apply-apps.sh
   # hoặc: kubectl apply -f cluster/argocd/apps/app-my-new-app.yaml -n argocd
   ```

---

### 👉 Cách 3: Tạo một Project mới (AppProject) để phân nhóm

Nếu bạn có nhiều nhóm dịch vụ (ví dụ: nhóm `ai-platform`, nhóm `tools`, nhóm `internal`) và muốn chia riêng:
1. Trên Web UI ArgoCD: Nhấp biểu tượng **Settings** (bánh răng ở thanh menu bên trái) → chọn **Projects**.
2. Nhấn **`+ NEW PROJECT`**.
3. Đặt tên Project (ví dụ: `production-apps`).
4. Tại mục **Source Repositories**: Thêm `git@github.com:QuanAnh280605/cloud-infra.git` (hoặc `*`).
5. Tại mục **Destinations**: Thêm Server `https://kubernetes.default.svc` và Namespace `*`.
6. Nhấn **SAVE**. Từ lúc này, khi tạo Application mới bạn có thể chọn Project này thay vì `default`.
