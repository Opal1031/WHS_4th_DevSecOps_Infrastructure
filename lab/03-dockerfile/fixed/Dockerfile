# ============================================================
#  보너스 · 고친 Dockerfile (정답 예시)
#  "버전 고정 + 비-root + 최소 이미지" 로 조였습니다.
# ============================================================
FROM node:20.11.1-alpine
# ✅ 버전 고정 + 경량(alpine) 이미지

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
# ✅ ADD 대신 COPY, 의존성 먼저 복사(캐시 활용)

# ✅ 비-root 사용자 생성 후 전환
RUN addgroup -S app && adduser -S app -G app
USER app

EXPOSE 3000

# ✅ 컨테이너 상태 점검
HEALTHCHECK CMD node healthcheck.js || exit 1

CMD ["node", "server.js"]
