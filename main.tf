module "vpc" {
  source = "git::https://github.com/Matishac14/Modulos-AUY1105-EV3.git//modules/vpc?ref=main"

  project_name     = var.project_name
  environment      = var.environment
  allowed_ssh_cidr = var.my_ip
}

module "ec2" {
  source = "git::https://github.com/AUY1105-II/Modulos-AUY1105-Grupo-4.git//modules/ec2?ref=v1.0.0"

  project_name       = var.project_name
  environment        = var.environment
  subnet_id          = module.vpc.subnet_ids[0]
  security_group_ids = ["sg-0391898c7effc27fc"]
}

module "s3" {
  source = "git::https://github.com/AUY1105-II/Modulos-AUY1105-Grupo-4.git//modules/s3?ref=v1.0.0"

  bucket_name = var.bucket_name
  environment = var.environment
}
