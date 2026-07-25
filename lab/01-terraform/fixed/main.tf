# ============================================================
#  실습 1 · 고친 Terraform (정답 예시)
#  취약한 버전의 "심각한 위험"을 하나씩 막았습니다. 주석의 ✅ 를 따라가 보세요.
#  → 스캔하면 CRITICAL·HIGH 가 0이 됩니다. (남는 MEDIUM/LOW 는 추가 하드닝 권고)
# ============================================================

provider "aws" {
  region = "ap-northeast-2"
}

# ------------------------------------------------------------
# 0) 암호화용 KMS 키 (우리가 관리하는 키 = customer managed key)
# ------------------------------------------------------------
resource "aws_kms_key" "s3" {
  description         = "S3 encryption key"
  enable_key_rotation = true # ✅ 키 자동 교체
}

# ------------------------------------------------------------
# 1) S3 버킷 — 비공개 + 암호화 + 퍼블릭 차단
# ------------------------------------------------------------
resource "aws_s3_bucket" "docs" {
  bucket = "whitehat-school-docs-2026"
}

# ✅ ACL을 private 로 (공개 제거)
resource "aws_s3_bucket_acl" "docs_acl" {
  bucket = aws_s3_bucket.docs.id
  acl    = "private"
}

# ✅ 우리가 만든 KMS 키로 저장 데이터 암호화
resource "aws_s3_bucket_server_side_encryption_configuration" "docs_enc" {
  bucket = aws_s3_bucket.docs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

# ✅ 계정 차원의 퍼블릭 접근 차단 (실수로도 공개 안 되도록)
resource "aws_s3_bucket_public_access_block" "docs_block" {
  bucket                  = aws_s3_bucket.docs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------
# 2) 보안 그룹 — 사내망(VPC)에서만 접근
# ------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "web server security group"

  # ✅ 22번 포트를 사내망(VPC 내부)에서만 열기 (전 세계 개방 X)
  ingress {
    description = "SSH from internal network only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # 사내 VPC 대역으로 교체
  }

  # ✅ 바깥으로 나가는 것도 사내망으로만 (필요 시 최소 범위로)
  egress {
    description = "internal egress only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# ------------------------------------------------------------
# 3) RDS — 비공개 + 암호화 + 비밀번호는 코드 밖에서
# ------------------------------------------------------------
variable "db_password" {
  description = "DB 비밀번호 (환경변수 TF_VAR_db_password 로 주입)"
  type        = string
  sensitive   = true
}

resource "aws_db_instance" "userdb" {
  identifier          = "whitehat-userdb"
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  username            = "admin"
  password            = var.db_password # ✅ 코드에 하드코딩하지 않음
  skip_final_snapshot = true

  storage_encrypted   = true  # ✅ 저장 데이터 암호화
  publicly_accessible = false # ✅ 인터넷 직접 접근 차단
}
