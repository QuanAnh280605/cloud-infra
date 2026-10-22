#!/usr/bin/env bash
# ==============================================================================
# Script Cài đặt & Cập nhật LGTM Stack (Observability) trên Cụm K3s ARM64
# Components: Loki, Tempo, Prometheus, Grafana, Alloy
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="monitoring"

echo "☸️ [1/6] Chuẩn bị namespace: ${NAMESPACE}..."
kubectl apply -f "${SCRIPT_DIR}/namespace.yaml"

echo "📦 [2/6] Cập nhật Helm Repositories..."
helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo update grafana prometheus-community

echo "🪵 [3/6] Cài đặt / Nâng cấp Loki (SingleBinary, 5d Retention)..."
helm upgrade --install loki grafana/loki \
  --namespace ${NAMESPACE} \
  --values "${SCRIPT_DIR}/values-loki.yaml" \
  --wait --timeout 5m

echo "⏱️ [4/6] Cài đặt / Nâng cấp Tempo (SingleBinary, 48h Retention)..."
helm upgrade --install tempo grafana/tempo \
  --namespace ${NAMESPACE} \
  --values "${SCRIPT_DIR}/values-tempo.yaml" \
  --wait --timeout 5m

echo "📈 [5/6] Cài đặt / Nâng cấp Prometheus (Metrics Engine)..."
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace ${NAMESPACE} \
  --values "${SCRIPT_DIR}/values-prometheus.yaml" \
  --wait --timeout 5m

echo "📊 [6/6] Cài đặt / Nâng cấp Grafana (UI & Correlated Dashboards)..."
helm upgrade --install grafana grafana/grafana \
  --namespace ${NAMESPACE} \
  --values "${SCRIPT_DIR}/values-grafana.yaml" \
  --wait --timeout 5m

echo "🔄 [Bonus] Cài đặt / Nâng cấp Grafana Alloy (Unified Telemetry Collector)..."
helm upgrade --install alloy grafana/alloy \
  --namespace ${NAMESPACE} \
  --values "${SCRIPT_DIR}/values-alloy.yaml" \
  --wait --timeout 5m

echo ""
echo "=============================================================================="
echo "✅ LGTM Observability Stack đã được triển khai thành công!"
echo "=============================================================================="
echo "🌐 URL truy cập Grafana UI:"
echo "   http://grafana.140.245.58.162.nip.io"
echo ""
echo "🔑 Mật khẩu Admin Grafana:"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "🩺 Kiểm tra trạng thái Pods:"
kubectl get pods -n ${NAMESPACE}
echo "=============================================================================="
