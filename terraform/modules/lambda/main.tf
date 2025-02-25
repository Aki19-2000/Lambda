resource "aws_lambda_function" "this" {
  function_name = var.lambda_function_name
  role          = var.iam_role_arn
  package_type  = "Image"
  image_uri     = var.image_uri

  environment {
    variables = {
      ENV = var.environment
    }
  }
}

# API Gateway to trigger the Lambda function
resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.lambda_function_name}-api"
  description = "API Gateway to trigger ${var.lambda_function_name}"
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "invoke"
}

resource "aws_api_gateway_method" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.this.arn}/invocations"
}

# Lambda permissions for API Gateway to invoke the function
resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
}

# Deploy API Gateway to a stage
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = var.api_stage

  depends_on = [
    aws_api_gateway_integration.this,
    aws_api_gateway_method.this
  ]
}

# API Gateway stage with logging settings
resource "aws_api_gateway_stage" "this" {
  stage_name    = var.api_stage
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id

  # Configure access log settings for the stage (optional)
  access_log_settings {
    destination_arn = "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/api-gateway/${var.api_stage}"
    format          = jsonencode({
      requestId     = "$context.requestId"
      ip            = "$context.identity.sourceIp"
      userAgent     = "$context.identity.userAgent"
      method        = "$context.httpMethod"
      resourcePath  = "$context.resourcePath"
      status        = "$context.status"
      responseTime  = "$context.responseLatency"
    })
  }


output "lambda_invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}

output "lambda_function_arn" {
  value = aws_lambda_function.this.arn
}

output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/${var.api_stage}/invoke"
}
