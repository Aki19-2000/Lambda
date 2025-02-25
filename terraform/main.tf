module "vpc" {
  source = "./modules/vpc"
}

module "lambda" {
  source = "./modules/lambda"
  private_subnet_ids = module.vpc.private_subnet_ids
  lambda_security_group_id = module.vpc.lambda_security_group_id
  patient_service_image_uri = "510278866235.dkr.ecr.us-east-1.amazonaws.com/patient-service:latest"  # Use actual ECR URL
  appointment_service_image_uri = "510278866235.dkr.ecr.us-east-1.amazonaws.com/appointment-service:latest"  # Use actual ECR URL
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
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "patient_service_integration" {
  rest_api_id = aws_api_gateway_rest_api.patient_service_api.id
  resource_id = aws_api_gateway_resource.patient_service_resource.id
  http_method = aws_api_gateway_method.patient_service_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.patient_service.invoke_arn
}

resource "aws_api_gateway_deployment" "patient_service_deployment" {
  rest_api_id = aws_api_gateway_rest_api.patient_service_api.id
  stage_name  = "prod"
}

# API Gateway for Appointment Service Lambda
resource "aws_api_gateway_rest_api" "appointment_service_api" {
  name        = "appointment-service-api"
  description = "API for Appointment Service Lambda"
}

resource "aws_api_gateway_resource" "appointment_service_resource" {
  rest_api_id = aws_api_gateway_rest_api.appointment_service_api.id
  parent_id   = aws_api_gateway_rest_api.appointment_service_api.root_resource_id
  path_part   = "appointment-service"
}

resource "aws_api_gateway_method" "appointment_service_method" {
  rest_api_id   = aws_api_gateway_rest_api.appointment_service_api.id
  resource_id   = aws_api_gateway_resource.appointment_service_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "appointment_service_integration" {
  rest_api_id = aws_api_gateway_rest_api.appointment_service_api.id
  resource_id = aws_api_gateway_resource.appointment_service_resource.id
  http_method = aws_api_gateway_method.appointment_service_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.appointment_service.invoke_arn
}

resource "aws_api_gateway_deployment" "appointment_service_deployment" {
  rest_api_id = aws_api_gateway_rest_api.appointment_service_api.id
  stage_name  = "prod"
}
