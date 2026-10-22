# 🔭 LGTM Observability Stack (K3s ARM64)

Hệ thống giám sát và truy vết hợp nhất 3 chiều (**Metrics - Logs - Traces**) được tối ưu hóa cho VPS Oracle Cloud ARM64 (2 OCPU, 12GB RAM, 47GB Storage).

---

## 🏗️ Thành Phần Kiến Trúc

| Thành phần | Vai trò | Chế độ chạy | Lưu trữ & Retention | Port nội bộ K8s |
|---|---|---|---|---|
| **Loki** | Thu thập & tìm kiếm Log tập trung | SingleBinary (Monolithic) | PVC 6GB, retention 5 ngày (120h) | `loki-gateway:80` |
| **Tempo** | Phân tích phân tán Distributed Tracing | SingleBinary | PVC 4GB, retention 48 giờ | OTLP `4317` (gRPC), `4318` (HTTP) |
| **Prometheus** | Thu thập & lưu trữ chỉ số hiệu năng (Metrics) | Single Server + Node Exporter | PVC 6GB, retention 15 ngày | `prometheus-server:80` |
| **Grafana** | Bảng điều khiển trực quan tương quan (Correlated UI) | Standalone (SQLite) | PVC 2GB (Dashboards/Alerts) | `grafana:80` |
| **Grafana Alloy** | Bộ thu thập viễn trắc hợp nhất (Unified Collector) | DaemonSet | Đệm bộ nhớ / không dùng PVC | OTLP `4317` & `4318` |

---

## 🌐 Đường Dẫn Truy Cập Web UI

- **Grafana Dashboard**: [http://grafana.140.245.58.162.nip.io](http://grafana.140.245.58.162.nip.io)
  - **Tài khoản mặc định**: `admin`
  - **Mật khẩu**: `admin`

---

## 🔗 Liên Kết Tương Quan 3 Chiều (Correlation)

Trong Grafana, 3 nguồn dữ liệu đã được cấu hình tự động liên kết:
1. **Từ Trace sang Log**: Trong giao diện Tempo Trace view, click biểu tượng **Logs** để tự động lọc toàn bộ Log của container trong cùng khung thời gian của Trace.
2. **Từ Log sang Trace**: Trong giao diện Loki Log view, bất kỳ dòng log nào chứa chuỗi `trace_id` sẽ tự động hiển thị link chuyển thẳng sang Tempo để xem biểu đồ flamegraph.
3. **Từ Metric sang Trace**: Service map liên kết giữa Prometheus và Tempo.

---

## 🛠️ Hướng Dẫn Cài Đặt & Cập Nhật

```bash
# Đăng nhập vào VPS
ssh ubuntu@140.245.58.162

# Chạy script cài đặt tự động
cd ~/cloud-infra/cluster/observability
chmod +x install.sh
./install.sh
```
