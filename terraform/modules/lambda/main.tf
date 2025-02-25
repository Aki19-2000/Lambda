# Get the current AWS region
data "aws_region" "current" {}

# Lambda function using container image
resource "aws_lambda_function" "helloworld_lambda" {
  function_name = "helloworld-lambda"
  
  # Reference the newly pushed image in ECR
  image_uri = "510278866235.dkr.ecr.us-east-1.amazonaws.com/helloworld:latest"
  
  # Specify package type as Image for container-based Lambda
  package_type = "Image"
  
  memory_size = 128
  timeout     = 3
  
  # IAM Role for Lambda (with added permissions)
  role = aws_iam_role.lambda_exec_role.arn
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [ {
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect    = "Allow"
      Sid       = ""
    }]
  })
}

# Attach permissions to the Lambda role (CloudWatch logs, ECR access, etc.)
resource "aws_iam_role_policy" "lambda_logs_policy" {
  name = "lambda-logs-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

# Attach permissions for ECR to Lambda role
resource "aws_iam_role_policy" "lambda_ecr_policy" {
  name = "lambda-ecr-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ecr:GetAuthorizationToken"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "ecr:BatchGetImage"
        Effect   = "Allow"
        Resource = "arn:aws:ecr:us-east-1:510278866235:repository/helloworld"
      },
      {
        Action   = "ecr:BatchGetImage"
        Effect   = "Allow"
        Resource = "arn:aws:ecr:us-east-1:510278866235:repository/helloworld/*"
      }
    ]
  })
}

# API Gateway to trigger Lambda
resource "aws_api_gateway_rest_api" "helloworld_api" {
  name        = "helloworld-api"
  description = "API for triggering helloworld Lambda"
}

# API Gateway Resource (Path)
resource "aws_api_gateway_resource" "helloworld_resource" {
  rest_api_id = aws_api_gateway_rest_api.helloworld_api.id
  parent_id   = aws_api_gateway_rest_api.helloworld_api.root_resource_id
  path_part   = "hello"
}

# API Gateway Method (GET)
resource "aws_api_gateway_method" "helloworld_method" {
  rest_api_id   = aws_api_gateway_rest_api.helloworld_api.id
  resource_id   = aws_api_gateway_resource.helloworld_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integration for API Gateway to invoke the Lambda
resource "aws_api_gateway_integration" "helloworld_integration" {
  rest_api_id             = aws_api_gateway_rest_api.helloworld_api.id
  resource_id             = aws_api_gateway_resource.helloworld_resource.id
  http_method             = aws_api_gateway_method.helloworld_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.helloworld_lambda.arn}/invocations"
}

# Explicit API Gateway stage configuration (no deprecated "stage_name")
resource "aws_api_gateway_stage" "helloworld_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.helloworld_api.id
  deployment_id = aws_api_gateway_deployment.helloworld_deployment.id
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "helloworld_deployment" {
  rest_api_id = aws_api_gateway_rest_api.helloworld_api.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_integration.helloworld_integration,
    aws_api_gateway_method.helloworld_method
  ]
}

# Lambda Permission to allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.helloworld_lambda.function_name
}
