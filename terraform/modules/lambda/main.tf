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
 
output "lambda_invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}
 
output "lambda_function_arn" {
  value = aws_lambda_function.this.arn
}
