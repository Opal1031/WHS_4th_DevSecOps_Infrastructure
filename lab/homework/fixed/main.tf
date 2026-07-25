# ============================================================
#  과제 · 취약한 인프라 (수업과 다른 새 시나리오)
#  상황: 사내 웹서비스 인프라를 급하게 만들었더니 곳곳이 위험합니다.
#  목표: 스캔해서 CRITICAL·HIGH 를 전부 0으로 만드세요.
# ============================================================

provider "aws" {
  region = "ap-northeast-2"
}

# SSH·MySQL 접근을 허용할 사내망 대역
variable "trusted_cidr" {
  type    = string
  default = "10.0.0.0/8"
}

# DB 비밀번호를 코드에 직접 작성하지 않고 외부에서 입력
variable "db_password" {
  type      = string
  sensitive = true
}

# S3·RDS·EBS 암호화에 사용할 고객 관리형 KMS 키
resource "aws_kms_key" "infrastructure" {
  description         = "KMS key for company web infrastructure"
  enable_key_rotation = true
}

# ------------------------------------------------------------
# 1) 로그 저장용 S3 버킷
# ------------------------------------------------------------
resource "aws_s3_bucket" "logs" {
  bucket = "company-web-logs-2026"
}

resource "aws_s3_bucket_acl" "logs_acl" {
  bucket = aws_s3_bucket.logs.id
  acl    = "private" # 수정: 로그 버킷의 공개 ACL 제거
}

# 수정: ACL·정책을 통한 모든 퍼블릭 액세스 차단
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 수정: 고객 관리형 KMS 키로 로그 데이터 암호화
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.infrastructure.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

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
    cidr_blocks = [var.trusted_cidr] # 수정: SSH 접근을 사내망으로 제한
  }

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.trusted_cidr] # 수정: DB 접근을 사내망으로 제한
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.trusted_cidr] # 수정: 외부 송신도 사내망으로 제한
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
  password            = var.db_password # 수정: 하드코딩 대신 민감 변수 사용
  skip_final_snapshot = true

  publicly_accessible    = false # 수정: 인터넷에서 DB 직접 접근 차단
  storage_encrypted      = true  # 수정: RDS 저장 데이터 암호화
  kms_key_id             = aws_kms_key.infrastructure.arn
  vpc_security_group_ids = [aws_security_group.web.id]
}

# ------------------------------------------------------------
# 4) 첨부파일용 EBS 볼륨
# ------------------------------------------------------------
resource "aws_ebs_volume" "attachments" {
  availability_zone = "ap-northeast-2a"
  size              = 20
  encrypted         = true # 수정: EBS 저장 데이터 암호화
  kms_key_id        = aws_kms_key.infrastructure.arn
}

