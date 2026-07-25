# DevSecOps(Infrastructure) 실습 · Whitehat School 4기

실습은 **`lab/` 폴더** 안에서 진행합니다.

```bash
git clone https://github.com/Opal1031/WHS_4th_DevSecOps_Infrastructure.git
cd WHS_4th_DevSecOps_Infrastructure/lab
bash setup.sh        # Docker 확인 · 권한 · 스캐너 이미지 받기
```

자세한 순서는 [`lab/README.md`](lab/README.md) 를 보세요.

- 필요한 것: **git · Docker** (실습 6만 Python 3 추가)
- Windows: **Git Bash** 또는 **WSL** 에서 실행

## GitHub Actions 카나리 배포

저장소 루트의 `.github/workflows/deploy.yml`은 `main` 브랜치에서
`lab/canary_test/` 파일이 변경되면 self-hosted runner에서 실행됩니다.
Actions 화면의 **Run workflow** 버튼으로 수동 실행할 수도 있습니다.

사전 조건:

- 이 저장소에 online 상태의 self-hosted runner가 등록되어 있어야 합니다.
- runner 호스트에서 Docker가 실행 중이어야 합니다.
- runner 계정이 Docker 명령을 실행할 권한이 있어야 합니다.

배포 스크립트는 `canary-net`, 앱 컨테이너와 Nginx 프록시를 최초 실행 시
자동으로 준비합니다. 호스트의 80번 포트는 비어 있어야 합니다.
