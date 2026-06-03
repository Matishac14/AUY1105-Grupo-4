module "vpc" {
  source = "git::https://github.com/AUY1105-II/Modulos-AUY1105-Grupo-4.git//modules/vpc?ref=main"

  project_name     = var.project_name
  environment      = var.environment
  allowed_ssh_cidr = var.my_ip
}

module "ec2" {
  source = "git::https://github.com/AUY1105-II/Modulos-AUY1105-Grupo-4.git//modules/ec2?ref=main"

  project_name       = var.project_name
  environment        = var.environment
  subnet_id          = module.vpc.subnet_ids[0]
  security_group_ids = [module.vpc.ssh_security_group_id]
}

module "s3" {
  source = "git::https://github.com/AUY1105-II/Modulos-AUY1105-Grupo-4.git//modules/s3?ref=main"

  bucket_name = var.bucket_name
  environment = var.environment
}
