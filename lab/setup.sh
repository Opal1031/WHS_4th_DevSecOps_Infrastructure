#!/usr/bin/env bash
# ============================================================
#  준비 스크립트 — 한 번 실행하면 실습 준비가 끝납니다.
#  사용법:  bash setup.sh
#  (Windows는 Git Bash 또는 WSL에서 실행합니다)
# ============================================================
set -uo pipefail
cd "$(dirname "$0")"

echo "▶ 1/4  Docker 실행 확인..."
if ! docker info >/dev/null 2>&1; then
  echo "   ❌ Docker가 실행 중이 아닙니다. Docker Desktop을 실행한 뒤 다시 시도합니다."
  exit 1
fi
echo "   ✓ Docker 실행 중"

echo "▶ 2/4  scan.sh 실행 권한..."
chmod +x scan.sh && echo "   ✓ 완료"

echo "▶ 3/4  스캐너 이미지 받기 (처음이면 몇 분 걸릴 수 있습니다)..."
docker pull -q aquasec/tfsec      >/dev/null 2>&1 && echo "   ✓ tfsec"      || { echo "   ❌ tfsec 이미지 받기 실패 (네트워크 확인)"; exit 1; }
docker pull -q bridgecrew/checkov >/dev/null 2>&1 && echo "   ✓ checkov"    || { echo "   ❌ checkov 이미지 받기 실패 (네트워크 확인)"; exit 1; }

echo "▶ 4/4  자체 점검 스캔..."
selftest="$(./scan.sh tfsec 01-terraform/vulnerable 2>&1)"
if echo "$selftest" | grep -q "problem"; then
  echo "   ✓ 스캔 동작 확인 (문제를 정상적으로 탐지)"
else
  echo "   ⚠ 스캔 출력이 예상과 다릅니다. README를 확인합니다."
fi

echo ""
echo "준비가 완료되었습니다. 이제 실습을 시작합니다:"
echo "     ./scan.sh tfsec   01-terraform/vulnerable"
echo "     ./scan.sh checkov 02-kubernetes/vulnerable"
echo "   자세한 순서는 README.md 를 참고합니다."
