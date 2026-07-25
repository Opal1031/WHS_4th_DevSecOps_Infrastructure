# ============================================================
#  과제 · 취약한 인프라 (수업과 다른 새 시나리오)
#  상황: 사내 웹서비스 인프라를 급하게 만들었더니 곳곳이 위험합니다.
#  목표: 스캔해서 CRITICAL·HIGH 를 전부 0으로 만드세요.
# ============================================================

provider "aws" {
  region = "ap-northeast-2"
}

# ------------------------------------------------------------
# 1) 로그 저장용 S3 버킷
# ------------------------------------------------------------
resource "aws_s3_bucket" "logs" {
  bucket = "company-web-logs-2026"
}

resource "aws_s3_bucket_acl" "logs_acl" {
  bucket = aws_s3_bucket.logs.id
  acl    = "public-read" # 위험: 로그가 인터넷에 공개
}
# (암호화 설정 없음)

# ------------------------------------------------------------
# 2) 웹 + DB 보안 그룹
# ------------------------------------------------------------
resource "aws_security_group" "web" {
  name = "web-sg"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 위험: SSH 전 세계 개방
  }

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 위험: DB 포트를 인터넷에 개방
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------------------------------------
# 3) 사용자 DB
# ------------------------------------------------------------
resource "aws_db_instance" "users" {
  identifier          = "company-users"
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  username            = "admin"
  password            = "admin1234!" # 위험: 비밀번호 하드코딩
  skip_final_snapshot = true

  publicly_accessible = true # 위험: 인터넷에서 DB 직접 접근
  # (storage_encrypted 없음 → 미암호화)
}

# ------------------------------------------------------------
# 4) 첨부파일용 EBS 볼륨
# ------------------------------------------------------------
resource "aws_ebs_volume" "attachments" {
  availability_zone = "ap-northeast-2a"
  size              = 20
  # (encrypted 없음 → 미암호화)
}
