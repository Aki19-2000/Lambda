resource "aws_lambda_function" "patient_service" {
  function_name = "patient-service"
  role          = aws_iam_role.lambda_exec_role.arn
  image_uri     = aws_ecr_repository.patient_service.repository_url
  memory_size   = 128
  timeout       = 15
  package_type  = "Image"

  environment {
    variables = {
      LOG_LEVEL = "info"
    }
  }
}

resource "aws_lambda_function" "appointment_service" {
  function_name = "appointment-service"
  role          = aws_iam_role.lambda_exec_role.arn
  image_uri     = aws_ecr_repository.appointment_service.repository_url
  memory_size   = 128
  timeout       = 15
  package_type  = "Image"

  environment {
    variables = {
      LOG_LEVEL = "info"
    }
  }
}
