module "vpc" {
  source = "./modules/vpc"
}

module "lambda" {
  source = "./modules/lambda"
}

#module "ecr" {
  #source = "./modules/ecr"
#}
