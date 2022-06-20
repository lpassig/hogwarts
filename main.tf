module "vpc" {
  source  = "app.terraform.io/propassig/vpc/aws"
  version = "3.14.1"

  name = "${var.NAME}-vpc"
  cidr = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  azs             = ["${var.AWS_REGION}a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

}

module "security-group" {
  source  = "app.terraform.io/propassig/security-group/aws"
  version = "4.9.0"

  name        = "${var.NAME}-sg"
  description = "Security group for EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = []
  egress_rules        = ["all-all"]

}

output "vpc_id" {
  value = module.vpc.vpc_id
  sensitive = false
}

output "subnet_id" {
  value = element(module.vpc.public_subnets, 0)
  sensitive = false
}

output "availability_zone" {
  value = element(module.vpc.azs, 0)
  sensitive = false
}

output "instance_profile" {
  value = aws_iam_instance_profile.magic_profile.name
  sensitive = false
}

output "vpc_security_group_ids" {
  value = [module.security-group.security_group_id]
  sensitive = false
}