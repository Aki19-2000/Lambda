resource "aws_lambda_function" "this" {
  function_name = var.lambda_function_name
  role          = var.iam_role_arn
  package_type  = "Image"
  image_uri     = "510278866235.dkr.ecr.us-east-1.amazonaws.com/helloworld:latest"
 
  environment {
    variables = {
      ENV = "dev"
    }
  }
}
 
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

# Grant API Gateway permissions to invoke the Lambda function
resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
}

output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/prod/invoke"
}
output "lambda_invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}
 
output "lambda_function_arn" {
  value = aws_lambda_function.this.arn
}
