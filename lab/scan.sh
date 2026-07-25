#!/usr/bin/env bash
# ============================================================
#  IaC 보안 스캔 — 설치 없이 Docker로 한 번에 실행합니다.
#  사용법:
#     ./scan.sh tfsec   01-terraform/vulnerable
#     ./scan.sh checkov 01-terraform/vulnerable
#     ./scan.sh checkov 02-kubernetes/vulnerable
#  ※ Windows는 Git Bash 또는 WSL에서 실행합니다 (cmd/PowerShell ✗)
# ============================================================
set -uo pipefail   # -e 는 뺐습니다: 스캐너가 문제를 찾으면 종료코드가 0이 아니어도 끝 메시지를 보여주려고

TOOL="${1:-tfsec}"
TARGET="${2:-01-terraform/vulnerable}"

# 도구 이름 검증 (첫 번째 인자). 폴더 경로를 첫 자리에 넣는 실수를 바로 잡아줌
case "$TOOL" in
  tfsec|checkov) ;;
  *)
    echo "❌ 사용법:  ./scan.sh <tfsec|checkov> <폴더>"
    echo "   예)    ./scan.sh tfsec   01-terraform/fixed"
    echo "          ./scan.sh checkov 02-kubernetes/vulnerable"
    echo "   (입력한 '$TOOL' 은(는) 도구 이름이 아닙니다. 폴더 경로는 두 번째 자리입니다.)"
    exit 1 ;;
esac

# Docker 켜져 있는지 확인
if ! docker info >/dev/null 2>&1; then
  echo "❌ Docker가 실행 중이 아닙니다. Docker Desktop을 먼저 실행합니다."
  exit 1
fi

# 대상 폴더 확인
ABS="$(cd "$(dirname "$0")/$TARGET" 2>/dev/null && pwd)"
if [ -z "$ABS" ]; then
  echo "❌ 대상 폴더를 찾을 수 없습니다: $TARGET"
  echo "   예) ./scan.sh tfsec 01-terraform/vulnerable"
  exit 1
fi

echo "▶ 도구: $TOOL    ▶ 대상: $TARGET"
echo "  (처음 실행하면 스캐너 이미지를 내려받아 시간이 걸릴 수 있습니다)"
echo "------------------------------------------------------------"

# 아래 docker 명령이 하는 일:
#   docker run --rm -v "폴더:/src" <도구> /src
#   --rm  = 끝나면 컨테이너 자동 삭제(잔여물 없음)
#   -v    = 내 폴더를 컨테이너 안 /src 에 연결(마운트) → 도구가 내 파일을 읽음
#   /src  = 도구에게 이 폴더를 검사하라고 지정
# → 이 방식으로 tfsec/checkov 를 직접 설치하지 않고도 검사가 됩니다.
case "$TOOL" in
  tfsec)
    # tfsec: Terraform 전용 스캐너
    docker run --rm -v "$ABS:/src" aquasec/tfsec /src
    ;;
  checkov)
    # checkov: Terraform / K8s / Dockerfile 등 멀티 프레임워크 스캐너
    # --compact: 결과를 한 줄씩 간결하게 (초급자용)
    docker run --rm -v "$ABS:/src" bridgecrew/checkov -d /src --compact
    ;;
  *)
    echo "알 수 없는 도구: $TOOL  (tfsec 또는 checkov 를 사용합니다)"
    exit 1
    ;;
esac

echo "------------------------------------------------------------"
echo "✅ 스캔 완료. 위에서 빨간 항목(FAILED · CRITICAL · HIGH)을 확인합니다."
