# Provider setup
provider "aws" {
  region = "us-east-1"
}

# Lambda Module
module "lambda" {
  source = "./modules/lambda"

  # Pass the ECR image URIs and VPC subnet IDs/security group IDs
  patient_service_image_uri    = "510278866235.dkr.ecr.us-east-1.amazonaws.com/patient-service:latest"
  
  private_subnet_ids          = module.vpc.private_subnet_ids
  lambda_security_group_id    = module.vpc.lambda_security_group_id
}


# API Gateway for Patient Service Lambda
resource "aws_api_gateway_rest_api" "patient_service_api" {
  name        = "patient-service-api"
  description = "API for Patient Service Lambda"
}

resource "aws_api_gateway_resource" "patient_service_resource" {
  rest_api_id = aws_api_gateway_rest_api.patient_service_api.id
  parent_id   = aws_api_gateway_rest_api.patient_service_api.root_resource_id
  path_part   = "patient-service"
}

resource "aws_api_gateway_method" "patient_service_method" {
  rest_api_id   = aws_api_gateway_rest_api.patient_service_api.id
  resource_id   = aws_api_gateway_resource.patient_service_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "patient_service_integration" {
  rest_api_id             = aws_api_gateway_rest_api.patient_service_api.id
  resource_id             = aws_api_gateway_resource.patient_service_resource.id
  http_method             = aws_api_gateway_method.patient_service_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.patient_service_invoke_arn
}

resource "aws_api_gateway_deployment" "patient_service_deployment" {
  depends_on = [aws_api_gateway_integration.patient_service_integration]
  rest_api_id = aws_api_gateway_rest_api.patient_service_api.id
  stage_name  = "prod"
}

