# ============================================================
#  실습 1 · 취약한 Terraform (일부러 잘못 짠 코드입니다)
#  목표: 스캐너를 돌리기 전에, "위험해 보이는 곳"을 눈으로 3개 찾아보세요.
# ============================================================

provider "aws" {
  region = "ap-northeast-2" # 서울 리전
}

# ------------------------------------------------------------
# 1) S3 버킷 — 회사 문서를 저장할 버킷
# ------------------------------------------------------------
resource "aws_s3_bucket" "docs" {
  bucket = "whitehat-school-docs-2026"
}

# 👀 이 버킷을 "공개(public-read)"로 열어버렸습니다.
#    누구나 인터넷에서 파일을 읽을 수 있게 됩니다.
resource "aws_s3_bucket_acl" "docs_acl" {
  bucket = aws_s3_bucket.docs.id
  acl    = "public-read"
}

# (암호화 설정이 아예 없습니다 — 저장 데이터가 평문으로 보관됩니다)

# ------------------------------------------------------------
# 2) 보안 그룹 — 서버 앞단 방화벽
# ------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "web server security group"

  # 👀 SSH(22번 포트)를 전 세계(0.0.0.0/0)에 열었습니다.
  #    누구든 우리 서버에 로그인 시도를 할 수 있습니다.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------------------------------------
# 3) RDS 데이터베이스 — 사용자 정보가 담길 DB
# ------------------------------------------------------------
resource "aws_db_instance" "userdb" {
  identifier          = "whitehat-userdb"
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  username            = "admin"
  password            = "P@ssw0rd1234" # 👀 비밀번호가 코드에 그대로 박혀있습니다.
  skip_final_snapshot = true

  # 👀 storage_encrypted 설정이 없습니다 (기본값 = 미암호화).
  # 👀 publicly_accessible 를 true 로 두면 인터넷에서 DB에 직접 접근됩니다.
  publicly_accessible = true
}
