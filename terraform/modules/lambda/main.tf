resource "aws_lambda_function" "helloworld_lambda" {
  function_name = "helloworld-lambda"
  
  image_uri = "510278866235.dkr.ecr.us-east-1.amazonaws.com/helloworld:latest"
  
  memory_size = 128
  timeout     = 3
  
  # IAM Role for Lambda (simple execution role)
  role = aws_iam_role.lambda_exec_role.arn
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect    = "Allow"
      Sid       = ""
    }]
  })
}

resource "aws_api_gateway_rest_api" "helloworld_api" {
  name        = "helloworld-api"
  description = "API for triggering helloworld Lambda"
}

resource "aws_api_gateway_resource" "helloworld_resource" {
  rest_api_id = aws_api_gateway_rest_api.helloworld_api.id
  parent_id   = aws_api_gateway_rest_api.helloworld_api.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "helloworld_method" {
  rest_api_id   = aws_api_gateway_rest_api.helloworld_api.id
  resource_id   = aws_api_gateway_resource.helloworld_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "helloworld_integration" {
  rest_api_id             = aws_api_gateway_rest_api.helloworld_api.id
  resource_id             = aws_api_gateway_resource.helloworld_resource.id
  http_method             = aws_api_gateway_method.helloworld_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.helloworld_lambda.arn}/invocations"
}

resource "aws_api_gateway_deployment" "helloworld_deployment" {
  rest_api_id = aws_api_gateway_rest_api.helloworld_api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.helloworld_lambda.function_name
}
