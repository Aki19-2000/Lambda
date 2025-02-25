# Provider configuration for AWS
provider "aws" {
  region = "us-west-2"
}

# Lambda module reference
module "lambda" {
  source = "./modules/lambda"
}
