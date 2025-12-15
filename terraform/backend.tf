# 1. Bucket S3 para almacenar el estado
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "mi-piloto-terraform-state-2025-aqui" # ¡Debe ser único globalmente!

  tags = {
    Name = "Terraform State Bucket para el Piloto"
  }
}

# Asegurar que el bucket no sea público
resource "aws_s3_bucket_acl" "terraform_state_bucket_acl" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  acl    = "private"
}

# Habilitar el versionamiento para revertir errores
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 2. Tabla DynamoDB para el bloqueo de estado (State Locking)
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "mi-piloto-terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# 3. Bloque de configuración del Backend
# NOTA: Este bloque DEBE ir en la configuración raíz
terraform {
  backend "s3" {
    # Estos valores deben ser hardcodeados en el backend block
    # No pueden ser referencias a variables o recursos (como aws_s3_bucket.terraform_state_bucket.bucket)
    
    bucket         = "mi-piloto-terraform-state-2025-aqui" # El mismo nombre que en el resource
    key            = "mi_piloto/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mi-piloto-terraform-locks"
    encrypt        = true
  }
}