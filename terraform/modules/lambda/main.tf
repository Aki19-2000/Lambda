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

  # Conditionally add Dead Letter Queue configuration if dlq_arn is set
  dynamic "dead_letter_config" {
    for_each = var.dlq_arn != "" ? [1] : []
    content {
      target_arn = var.dlq_arn
    }
  }
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}

output "lambda_function_arn" {
  value = aws_lambda_function.this.arn
}
