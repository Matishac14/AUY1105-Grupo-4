variable "project_name" {
  description = "Nombre del proyecto."
  type        = string
  default     = "cheese-factory"
}

variable "environment" {
  description = "Entorno (dev, prod, etc.)."
  type        = string
  default     = "dev"
}

variable "my_ip" {
  description = "CIDR autorizado para SSH (formato x.x.x.x/32)."
  type        = string
}

variable "bucket_name" {
  description = "Nombre único global del bucket S3."
  type        = string
}
