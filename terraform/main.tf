# Provider configuration for AWS
provider "aws" {
  region = var.region
}

# Lambda module reference
module "lambda" {
  source               = "./modules/lambda"
  lambda_function_name  = "myLambdaFunction"
  iam_role_arn          = module.iam.lambda_role_arn
  image_uri             = "510278866235.dkr.ecr.us-east-1.amazonaws.com/helloworld:latest"
  environment           = "dev"
  api_stage             = "prod"
  account_id            = "510278866235"
  region                = var.region  # Pass region to the lambda module
}

# IAM module reference
module "iam" {
  source = "./modules/iam"
  lambda_function_name = "myLambdaFunction"
}

output "lambda_function_arn" {
  value = module.lambda.lambda_function_arn
}

output "api_gateway_url" {
  value = module.lambda.api_gateway_url
}
