output "vpc_id" {
  description = "ID de la VPC creada por el módulo vpc."
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "IDs de subnets creadas por el módulo vpc."
  value       = module.vpc.subnet_ids
}

output "instance_id" {
  description = "ID de la instancia EC2 creada por el módulo ec2."
  value       = module.ec2.instance_id
}

output "instance_ip" {
  description = "IP pública de la instancia EC2."
  value       = module.ec2.instance_ip
}

output "bucket_name" {
  description = "Nombre del bucket S3 creado por el módulo s3."
  value       = module.s3.bucket_name
}
