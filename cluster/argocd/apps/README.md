# 📦 ArgoCD Applications Directory

Thư mục này lưu trữ các manifest Kubernetes định nghĩa **ArgoCD Application** (chuẩn GitOps).

## Cách thêm Application mới:

Tạo một file YAML theo định dạng: `app-<ten-ung-dung>.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <ten-ung-dung>
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: git@github.com:QuanAnh280605/cloud-infra.git
    targetRevision: main
    path: apps/<ten-thu-muc-app>
  destination:
    server: https://kubernetes.default.svc
    namespace: <ten-namespace>
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```
