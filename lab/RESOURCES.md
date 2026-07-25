# 더 배우기: 자료 모음

수업 뒤에 스스로 더 파고들 때 보는 링크입니다.

## 오늘 쓴 도구
- **tfsec**: https://github.com/aquasecurity/tfsec (현재 Trivy에 통합 중)
- **Checkov**: https://www.checkov.io · 규칙 검색: https://www.checkov.io/5.Policy%20Index/terraform.html
- **Trivy (올인원)**: https://trivy.dev · https://github.com/aquasecurity/trivy
- **pre-commit**: https://pre-commit.com

## 다음 도구 (슬라이드 34 · 스캐너 지형도)
- **Terrascan**: https://github.com/tenable/terrascan
- **KICS**: https://kics.io
- **OPA / Conftest** (정책 직접 작성): https://www.openpolicyagent.org · https://www.conftest.dev
- **gitleaks** (시크릿/유출 키 탐지): https://github.com/gitleaks/gitleaks

## 기준·가이드
- **CIS Benchmarks** (많은 규칙의 출처): https://www.cisecurity.org/cis-benchmarks
- **AWS Well-Architected: 보안 기둥**: https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html
- **Kubernetes Pod Security Standards**: https://kubernetes.io/docs/concepts/security/pod-security-standards
- **OWASP** (클라우드·IaC 보안 자료): https://owasp.org
- **Terraform 공식 문서**: https://developer.hashicorp.com/terraform

## 실제 사고 (슬라이드 8 · 사고 갤러리)
- **Capital One (2019)**: 검색: "Capital One 2019 data breach" · 요약: https://en.wikipedia.org/wiki/2019_Capital_One_data_breach
- **Uber (2016)**: 검색: "Uber 2016 breach AWS keys GitHub"
- **Tesla (2018) 크립토재킹**: 검색: "Tesla Kubernetes cryptojacking RedLock 2018"
- **Toyota (2022)**: 검색: "Toyota access key GitHub 2022 exposure"

## 시크릿 / NHI (슬라이드 21)
- **AWS Secrets Manager**: https://docs.aws.amazon.com/secretsmanager
- **HashiCorp Vault**: https://developer.hashicorp.com/vault
- **비인간 신원(NHI) 보안**: 검색: "Non-Human Identity security" · Cremit(강사 회사): https://cremit.io

## 한 걸음 더
- 내 GitHub 저장소에 **checkov를 GitHub Action으로** 붙여보기 (슬라이드 26 예시 참고).
- GitHub·GitLab 등 공개 IaC 저장소를 clone해서 `./scan.sh` 돌려보기, 취약한 인프라를 직접 구현해 스캔, 또는 스캐너 룰(정책)을 직접 작성 (과제 보너스).
