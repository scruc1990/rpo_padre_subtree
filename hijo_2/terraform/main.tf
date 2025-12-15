# Configuración del proveedor de AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- 1. DynamoDB Table ---
resource "aws_dynamodb_table" "data_table" {
  name             = "${var.project_name}-DataTable"
  billing_mode     = "PAY_PER_REQUEST" # Modo bajo demanda
  hash_key         = "id"
  
  attribute {
    name = "id"
    type = "S"
  }
  
  # Política de eliminación: "DESTROY" para entornos de prueba
  deletion_protection_enabled = false 
}

# --- 2. SNS Topic ---
resource "aws_sns_topic" "notifications_topic" {
  name = "${var.project_name}-NotificationsTopic"
}

# --- 3. S3 Bucket ---
resource "aws_s3_bucket" "data_bucket" {
  bucket = lower("${var.project_name}-data-bucket-unique") # Debe ser globalmente único
}

# Bloquear acceso público (buena práctica)
resource "aws_s3_bucket_public_access_block" "data_bucket_block" {
  bucket                  = aws_s3_bucket.data_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- 4. Secrets Manager Secret ---
resource "aws_secretsmanager_secret" "app_secret" {
  name        = "${var.project_name}-AppSecret"
  description = "Secreto para la aplicación piloto"
}

# Opcional: Agregar un valor inicial
resource "aws_secretsmanager_secret_version" "app_secret_version" {
  secret_id     = aws_secretsmanager_secret.app_secret.id
  secret_string = jsonencode({
    "user"     = "pilot_user",
    "password" = "MyTerraformPassword123"
  })
}

# --- 5. Lambda Function ---
# (Necesitas el archivo ZIP de tu código Lambda en la misma ruta)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "lambda_handler" # Reemplaza con la ruta de tu código
  output_path = "lambda_package.zip"
}

resource "aws_lambda_function" "pilot_lambda" {
  function_name    = "${var.project_name}-PilotLambda"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  timeout          = 30
  memory_size      = 256
  
  # Variables de Entorno
  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.data_table.name
      TOPIC_ARN   = aws_sns_topic.notifications_topic.arn
      BUCKET_NAME = aws_s3_bucket.data_bucket.bucket
      SECRET_NAME = aws_secretsmanager_secret.app_secret.name
    }
  }
}

# --- 6. CloudWatch: Monitoreo Básico (Log Group) ---
# El rol IAM se encarga de los permisos. Aquí solo se define el grupo de logs
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.pilot_lambda.function_name}"
  retention_in_days = 7 # Define la retención de logs
}