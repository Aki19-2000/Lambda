# Provider configuration for AWS
provider "aws" {
  region = "us-east-1"
}

# Lambda module reference
module "lambda" {
  source = "./modules/lambda"
}
