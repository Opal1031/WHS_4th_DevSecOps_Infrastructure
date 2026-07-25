# DevSecOps(Infrastructure): 실습 가이드 (Whitehat School 4기)

> 이 폴더는 **직접 손으로 따라 하는 실습**입니다. 슬라이드와 함께 보시기 바랍니다.
> 스캐너는 전부 **Docker로 실행**하므로 별도로 설치할 것이 없습니다. (Docker와 git만 있으면 됩니다.)
> **Windows** 사용자는 **Git Bash** 또는 **WSL**에서 명령을 실행합니다. (cmd/PowerShell에서는 `./scan.sh`가 실행되지 않습니다.)

## 0. 준비 (5분)

> **필요 설치:** git · Docker (이 둘이면 실습 1~5, 보너스, 과제가 모두 됩니다). 실습 6(pre-commit)만 **Python 3**을 추가로 필요로 하며, 없으면 강사 데모로 대체합니다.


```bash
# 1) 실습 파일 받기 (이미 폴더가 있으면 생략)
git clone https://github.com/Opal1031/WHS_4th_DevSecOps_Infrastructure.git && cd WHS_4th_DevSecOps_Infrastructure/lab

# 2) 한 번에 준비 (Docker 확인 · 권한 · 이미지 받기 · 자체 점검)
bash setup.sh
```

> **`bash setup.sh` 한 번으로 준비가 완료됩니다.** '준비 완료' 메시지가 표시되면 성공입니다.
> (수동으로 진행하려면: `docker --version` → `chmod +x scan.sh` → `docker pull aquasec/tfsec bridgecrew/checkov`)

폴더 구조:

```
lab/
├── 01-terraform/
│   ├── vulnerable/main.tf   ← 일부러 취약하게 작성한 코드
│   └── fixed/main.tf        ← 정답 예시 (핵심 위험 제거)
├── 02-kubernetes/
│   ├── vulnerable/pod.yaml
│   └── fixed/pod.yaml
├── setup.sh                 ← 준비 한 번에 (bash setup.sh)
├── scan.sh                  ← Docker로 tfsec/checkov 실행
├── .pre-commit-config.yaml  ← 커밋 전 자동 스캔
└── .github/workflows/       ← CI 스캔 예시
```

---


## 이 명령어가 하는 일

명령을 그대로 따라 치기 전에, 각 명령이 무엇을 하는지 먼저 확인합니다.

**`bash setup.sh`**: 준비를 한 번에 수행합니다. 열어 보면 4단계입니다. Docker가 켜졌는지 확인 → `scan.sh`에 실행 권한 부여 → 스캐너 이미지 내려받기 → 시험 삼아 한 번 스캔.

**`./scan.sh tfsec 01-terraform/vulnerable`**: `scan.sh`가 내부에서 아래 도커 명령을 대신 실행합니다.
```
docker run --rm -v "그_폴더:/src" aquasec/tfsec /src
```
한 조각씩 살펴보면 다음과 같습니다.
- `docker run`: 도구(컨테이너)를 한 번 실행합니다.
- `--rm`: 끝나면 컨테이너를 자동으로 삭제합니다. 내 PC에 잔여물이 남지 않습니다.
- `-v "그_폴더:/src"`: **내 폴더를 컨테이너 안 `/src`에 연결**합니다. 그래야 도구가 내 파일을 읽습니다.
- `aquasec/tfsec`: 실행할 도구(이미지)의 이름.
- `/src`: 도구에게 이 폴더를 검사하라고 지정합니다.

→ 이 방식으로 내 PC에 tfsec을 **직접 설치하지 않고도** 검사가 진행됩니다.

**`diff vulnerable/main.tf fixed/main.tf`**: 두 파일에서 **다른 줄만** 표시합니다 (무엇을 고쳤는지 확인).

**`git commit -m "..."`**: 커밋할 때 pre-commit 훅이 **자동으로 스캔**을 실행합니다(실습 6). 문제가 있으면 커밋이 차단됩니다.

---

## 함께 보는 자료
- `GLOSSARY.md`: 용어 사전 (모르는 단어가 나오면 참고)
- `RESOURCES.md`: 더 배우기 링크 모음
- `복습핸드아웃.md`: 집에서 5분 복습 (자가 점검 + 복습 문제)
- `homework/ASSIGNMENT.md`: 과제

---

## 실습 1: 취약점 눈으로 찾기 (10분)

`01-terraform/vulnerable/main.tf`를 열고, **위험해 보이는 곳 3개**를 찾아봅니다.
(힌트: 누가 접근할 수 있는가, 암호화는 되어 있는가, 비밀번호는 어디에 있는가.)

> 스캐너를 실행하기 전에 몇 개나 탐지될지 먼저 예측해 봅니다. 1~2개 3~4개 5개+

---

## 실습 2: tfsec 로 첫 스캔 (15분)

```bash
./scan.sh tfsec 01-terraform/vulnerable
```

- 결과 맨 아래 요약을 확인합니다 → **critical 3, high 9, medium 5, low 4 (총 21개)**.
- 각 항목에는 **규칙 ID**(예: `aws-s3-no-public-buckets`), **파일:줄번호**, **문서 링크**가 있습니다.
- 눈으로 찾은 3개와 비교해 봅니다. 스캐너가 더 많이 탐지합니다.

---

## 실습 3: 고치고 다시 스캔 (10분)

```bash
./scan.sh tfsec 01-terraform/fixed
```

- 이번에는 **critical 0, high 0**입니다 (총 21개 → 6개).
- '문제 0'이 아니라 **'심각한 문제 0'**입니다. 남은 6개는 전부 `medium/low`로, 버저닝·백업 보존기간 같은 **하드닝 권고**입니다.
- `fixed/main.tf`에서 **무엇이 달라졌는지**(private, 암호화, 사내망만 허용, 변수 주입) 확인합니다.

> 이번 실습의 사이클은 취약 → 스캔 → 수정 → 재스캔이며, 이 과정에서 심각도가 크게 낮아집니다.

---

## 실습 4: Checkov 로 넓게 보기 (10분)

```bash
./scan.sh checkov 01-terraform/vulnerable
```

- 결과: **Passed 14, Failed 21**. tfsec과 **개수·규칙 이름이 다릅니다**. 도구마다 보는 관점이 달라 정상입니다.
- Checkov는 통과(PASS)한 개수까지 보여주므로 무엇이 안전한지도 알 수 있습니다.

---

## 실습 5: 쿠버네티스 워크로드 스캔 (15분)

```bash
./scan.sh checkov 02-kubernetes/vulnerable
```

찾게 되는 문제들 (**Failed 20**):
- `privileged: true`: 컨테이너에 사실상 root 권한
- `runAsUser: 0`: root로 실행
- `resources` 없음: 자원 무제한
- `hostPath: /`: 호스트 전체 마운트

고친 버전과 비교합니다.

```bash
./scan.sh checkov 02-kubernetes/fixed
```

- **Failed 20 → 8** (Passed 81). 핵심 위험 4가지는 전부 PASS입니다.
- 남은 8개는 checkov가 더 엄격하게 권하는 항목들(liveness/readiness probe, 이미지 digest 고정, default 네임스페이스 등)입니다. 핵심을 먼저 잡고, 나머지는 심각도로 우선순위를 정합니다.

---

## 실습 6: 커밋 전에 자동으로 차단하기 (15분)

```bash
# pre-commit 설치
python3 -m pip install pre-commit
#   ↳ 'externally-managed-environment'(PEP 668) 오류가 나면 아래 중 하나로 설치합니다.
#      macOS(Homebrew): brew install pipx && pipx install pre-commit
#      그 외:           python3 -m pip install --user --break-system-packages pre-commit
python3 -m pre_commit install     # 'pre-commit: command not found' 가 뜨면 이렇게 실행

# 취약한 파일을 커밋해 차단되는 것을 확인
cp 01-terraform/vulnerable/main.tf demo.tf
git add demo.tf
git commit -m "add s3"            # ← tfsec 훅이 취약점을 잡아 커밋이 차단됩니다

# 확인 후 정리
git reset demo.tf && rm demo.tf
```

> 커밋이 **차단되는 것이 정상**입니다. 도구가 취약점을 배포 전에 막은 것입니다.
> (`lab/`이 git 저장소여야 합니다. zip으로 받았으면 `git init`을 먼저 실행합니다.)
> 이렇게 **개발자 PC → CI** 순서로 점점 촘촘하게 막는 것이 "shift-left"입니다.
> (최초 설치에는 시간이 걸릴 수 있습니다. 진행이 어려우면 강사 데모로 대체합니다.)

---

## 도전 과제 (보너스)

### 보너스 1: Dockerfile 도 스캔하기
컨테이너 이미지 설정(Dockerfile)도 코드로 관리하는 IaC입니다. checkov는 이것도 검사합니다.

```bash
./scan.sh checkov 03-dockerfile/vulnerable   # → Failed 4
./scan.sh checkov 03-dockerfile/fixed        # → Failed 0
```

찾게 되는 문제 4가지:
- `CKV_DOCKER_7`: base image가 `latest` 태그 (버전 불명)
- `CKV_DOCKER_3`: `USER` 없음 → 컨테이너가 root로 실행
- `CKV_DOCKER_4`: `ADD` 대신 `COPY`를 사용해야 함
- `CKV_DOCKER_2`: `HEALTHCHECK` 없음

→ 이제 IaC 3종(Terraform · Kubernetes · Dockerfile)을 모두 스캔했습니다.

### 보너스 2: medium 하나 실제로 제거하기
tfsec `fixed`에 남은 6개 중 "versioning"을 켜서 medium을 하나 줄여 봅니다.
`01-terraform/fixed/main.tf` 맨 아래에 추가한 뒤 재스캔하면 **medium 5 → 4**가 됩니다.

```hcl
resource "aws_s3_bucket_versioning" "docs_ver" {
  bucket = aws_s3_bucket.docs.id
  versioning_configuration { status = "Enabled" }
}
```

### 보너스 3: 예외 처리(suppression) 적용하기
정말 안전한데 규칙에 걸릴 때에 한해, **이유를 적고** 무시하는 방법입니다.

```hcl
#tfsec:ignore:aws-s3-enable-versioning  # 데모용 버킷이라 버저닝 불필요 (이유 필수)
```

주석을 붙이고 재스캔하여 해당 항목이 사라지는지 확인합니다. (이유 없이 무분별하게 skip 하는 것은 금지입니다.)

---

## 과제 (집에서)

수업과 다른 새 인프라(`homework/vulnerable/main.tf`)를 직접 스캔하고 고치는 과제입니다.
목표는 **CRITICAL·HIGH를 0으로** 만드는 것입니다. 자세한 내용과 평가 기준은 **`homework/ASSIGNMENT.md`**를 참고합니다.

```bash
./scan.sh tfsec homework/vulnerable      # CRITICAL 4 · HIGH 10
# → 직접 고쳐서 재스캔 → CRITICAL 0 · HIGH 0 만들기
```

---

## 오늘의 핵심 흐름

```
IaC 작성  →  로컬 스캔(tfsec/checkov)  →  수정  →  커밋 훅  →  CI 스캔  →  머지
```

## 실측 스캔 결과 요약 (이대로 나오면 정상)

| 스캔 | 취약 버전 | 고친 버전 |
|---|---|---|
| tfsec (Terraform) | critical 3 · high 9 · 총 **21** | **critical 0 · high 0** · 총 6 |
| checkov (Terraform) | Passed 14 · **Failed 21** |: |
| checkov (Kubernetes) | Passed 69 · **Failed 20** | Passed 81 · **Failed 8** |
| checkov (Dockerfile · 보너스) | Passed 22 · **Failed 4** | Passed 43 · **Failed 0** |
| tfsec (과제) | critical 4 · high 10 | critical 0 · high 0 |

## 자주 나오는 규칙 요약

| 영역 | 위험한 설정 | 안전한 설정 |
|---|---|---|
| S3 | public-read, 미암호화 | private, KMS 암호화, public access block |
| 보안그룹 | 22번 `0.0.0.0/0` | 필요한 IP 대역만 (사내망) |
| RDS | 하드코딩 비번, public | 변수 주입, 암호화, 비공개 |
| K8s | privileged, root, hostPath | 최소권한, non-root, limits |
