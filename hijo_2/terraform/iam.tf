# --- 1. Rol de Ejecución para la Lambda ---
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}-LambdaExecRole"

  # Policy para permitir que el servicio Lambda asuma este rol
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# --- 2. Políticas de Permisos ---

# Permisos para CloudWatch Logs (obligatorio para cualquier Lambda)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Política para acceder a DynamoDB, S3, SNS y Secrets Manager
resource "aws_iam_role_policy" "lambda_service_access" {
  name = "${var.project_name}-ServiceAccessPolicy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # DynamoDB: Lectura/Escritura en la tabla
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.data_table.arn
      },
      # SNS: Publicar en el tópico
      {
        Action   = "sns:Publish",
        Effect   = "Allow",
        Resource = aws_sns_topic.notifications_topic.arn
      },
      # S3: Leer y Escribir en el bucket
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.data_bucket.arn}/*" # Permiso a los objetos dentro del bucket
      },
      # Secrets Manager: Obtener el valor del secreto
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Effect   = "Allow",
        Resource = aws_secretsmanager_secret.app_secret.arn
      }
    ]
  })
}