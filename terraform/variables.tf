# Define la región de AWS
variable "aws_region" {
  description = "Región de AWS para el despliegue"
  type        = string
  default     = "us-east-1" # Cámbiala a tu región preferida
}

# Nombre base para todos los recursos
variable "project_name" {
  description = "Nombre base para los recursos del proyecto"
  type        = string
  default     = "MiPilotoServerless"
}

# Configuración de la Lambda
variable "lambda_handler" {
  description = "Función y archivo de inicio de la Lambda"
  type        = string
  default     = "main.handler"
}

variable "lambda_runtime" {
  description = "Runtime de la función Lambda"
  type        = string
  default     = "python3.12"
}