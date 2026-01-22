module "secrets" {
  source = "./modules/secrets"

  project        = var.project
  environment    = var.environment
  db_username    = var.db_username
  db_password    = var.db_password
  db_name        = var.db_name
  db_host        = module.database.db_endpoint
  db_port        = 3306
  tags           = local.tags
}


module "networking" {
  source              = "./modules/networking"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  db_subnet_cidrs     = var.db_subnet_cidrs
  project             = var.project
  tags                = local.tags
}


module "security" {
  source = "./modules/security"


  vpc_id = module.networking.vpc_id
  tags   = local.tags
}


module "alb" {
  source = "./modules/alb"


  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnets
  alb_sg_id      = module.security.web_sg_id
  project        = var.project
  tags           = local.tags
}


module "compute" {
  source = "./modules/compute"

  depends_on = [module.secrets]

  private_subnets              = module.networking.app_subnets
  app_sg_id                    = module.security.app_sg_id
  target_group_arn            = module.alb.target_group_arn
  project                      = var.project
  tags                         = local.tags
  db_host                      = module.database.db_endpoint
  db_name                      = var.db_name
  db_port                      = 3306
  db_credentials_secret_arn    = module.secrets.db_credentials_secret_arn
  db_credentials_secret_id     = module.secrets.db_credentials_secret_id

}


module "database" {
  source = "./modules/database"


  db_subnets = module.networking.db_subnets
  db_sg_id   = module.security.db_sg_id


  db_name  = var.db_name
  username = var.db_username
  password = var.db_password


  project = var.project
  tags    = local.tags
}
