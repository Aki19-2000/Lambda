provider "aws" {
  region = "us-west-2"
}

module "lambda" {
  source = "./modules/lambda"
}
