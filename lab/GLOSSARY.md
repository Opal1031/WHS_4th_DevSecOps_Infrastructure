# 용어 사전: DevSecOps(Infrastructure)

수업에 나오는 용어를 한 줄로 정리했습니다. 모르는 단어가 나오면 여기서 찾아보세요.

## 기본
- **IaC (Infrastructure as Code)**: 서버·네트워크 같은 인프라를 클릭이 아니라 코드로 정의하는 방식.
- **Terraform**: 대표적인 IaC 도구. `.tf` 파일에 인프라를 기술한다.
- **HCL**: Terraform이 쓰는 설정 언어. `resource "타입" "이름" { 속성 = 값 }` 형태.
- **provider**: 어떤 클라우드에 만들지 정하는 부분 (AWS, GCP 등).
- **resource**: 실제로 만드는 자원 하나 (S3 버킷, 보안그룹, DB 등).
- **쿠버네티스 (K8s)**: 컨테이너 여러 개를 자동으로 배치·운영하는 시스템.
- **컨테이너 / 파드(Pod) / 노드(Node)**: 컨테이너=앱을 담은 상자, 파드=컨테이너 실행 단위, 노드=파드가 도는 실제 서버.
- **Dockerfile**: 컨테이너 이미지를 어떻게 만들지 적은 설정 파일. 이것도 IaC.

## 스캐너
- **tfsec**: Terraform 전용 보안 스캐너. 현재 Trivy에 통합되는 중.
- **checkov**: Terraform·K8s·Dockerfile 등을 검사하는 멀티 프레임워크 스캐너.
- **Trivy**: IaC·이미지·시크릿·취약점을 한 번에 보는 올인원 스캐너.
- **SAST**: 코드를 실행하지 않고 읽어서(정적 분석) 문제를 찾는 방식.
- **misconfiguration**: 설정 오류. 클라우드 침해의 가장 흔한 원인.
- **규칙 ID**: 각 발견의 식별자 (예: `aws-s3-no-public-buckets`, `CKV_AWS_20`). 검색하면 문서가 나온다.
- **심각도 (CRITICAL·HIGH·MEDIUM·LOW)**: 얼마나 급한지의 등급. CRITICAL·HIGH부터 고친다.
- **오탐 (false positive)**: 실제로는 안전한데 규칙에 걸린 경우.
- **suppression / skip**: 오탐을 이유를 적고 예외 처리하는 것 (`#tfsec:ignore:...`).
- **baseline**: 이미 존재하는 기존 발견 묶음. 실무에선 신규만 막고 기존은 백로그로 둔다.

## 보안 개념
- **CIDR / `0.0.0.0/0`**: IP 대역 표기. `0.0.0.0/0`은 "모든 IP 허용"(전 세계 개방).
- **보안 그룹 (Security Group)**: 클라우드 서버의 방화벽. 어떤 IP·포트를 열지 정한다.
- **암호화 (SSE / KMS)**: 저장 데이터를 암호화하는 것. KMS는 암호화 키 관리 서비스.
- **하드코딩**: 비밀번호·키를 코드에 그대로 적는 것. git 히스토리에 영구 노출된다.
- **시크릿 매니저**: 비밀번호·키를 중앙에서 발급·관리하는 서비스 (AWS Secrets Manager, Vault).
- **NHI (비인간 신원)**: 사람이 아닌 키·토큰·서비스 계정. 요즘 클라우드 보안의 큰 주제.
- **최소 권한 (least privilege)**: 필요한 만큼만 권한을 주는 원칙.
- **privileged / runAsNonRoot / hostPath / capabilities**: K8s 컨테이너 권한 설정들. 과하면 컨테이너 탈출로 노드까지 해킹당한다.
- **resource limits**: 파드가 쓸 수 있는 CPU·메모리 상한. 없으면 한 파드가 노드 자원을 독점한다.

## 파이프라인
- **shift-left**: 문제를 개발 단계(왼쪽)에서 미리 잡는 것. 왼쪽일수록 고치는 비용이 싸다.
- **pre-commit**: 커밋 직전에 자동으로 검사를 돌리는 훅. 문제 있으면 커밋을 막는다.
- **CI (Continuous Integration)**: 코드를 올리면 서버가 자동으로 검사·빌드하는 자동화.
- **PR (Pull Request)**: 변경을 팀에 합치기 전 리뷰를 요청하는 것.
- **exit code**: 명령이 성공/실패로 끝났는지 알려주는 종료 신호 (0 = 성공).
- **hard-fail / soft-fail**: 문제 발견 시 머지를 막을지(hard) 경고만 할지(soft).
