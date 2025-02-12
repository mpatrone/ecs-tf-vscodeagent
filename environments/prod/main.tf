provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "../../modules/networking"

  environment      = var.environment
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "middleware" {
  source = "../../modules/middleware"

  environment     = var.environment
  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnet_ids
  domain_name    = var.domain_name
  tags           = var.tags
  depends_on     = [module.networking]
}

module "app" {
  source = "../../modules/app"

  environment          = var.environment
  vpc_id              = module.networking.vpc_id
  public_subnets      = module.networking.public_subnet_ids
  private_subnets     = module.networking.private_subnet_ids
  target_group_arn    = module.middleware.target_group_arn
  alb_security_group_id = module.middleware.alb_security_group_id
  tags                = var.tags
  depends_on          = [module.middleware]
}