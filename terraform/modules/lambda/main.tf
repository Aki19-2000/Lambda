# Lambda execution IAM role
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda execution (write logs to CloudWatch and access ECR)
resource "aws_iam_role_policy" "lambda_exec_policy" {
  name = "lambda-execution-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer"
        ]
        Effect   = "Allow"
        Resource = aws_ecr_repository.patient_service.arn
      },
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer"
        ]
        Effect   = "Allow"
        Resource = aws_ecr_repository.appointment_service.arn
      }
    ]
  })
}

# Lambda function for Patient Service with VPC and Security Group
resource "aws_lambda_function" "patient_service" {
  function_name = "patient-service"
  role          = aws_iam_role.lambda_exec_role.arn
  image_uri     = 510278866235.dkr.ecr.us-east-1.amazonaws.com/patient-service:latest
  memory_size   = 128
  timeout       = 15
  package_type  = "Image"

  environment {
    variables = {
      LOG_LEVEL = "info"
    }
  }

  # VPC Configuration for Lambda
  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet.id]   # Add private subnets here
    security_group_ids = [aws_security_group.lambda_sg.id]  # Reference the Lambda SG
  }
}

# Lambda function for Appointment Service with VPC and Security Group
resource "aws_lambda_function" "appointment_service" {
  function_name = "appointment-service"
  role          = aws_iam_role.lambda_exec_role.arn
  image_uri     = 510278866235.dkr.ecr.us-east-1.amazonaws.com/appointment-service:latest
  memory_size   = 128
  timeout       = 15
  package_type  = "Image"

  environment {
    variables = {
      LOG_LEVEL = "info"
    }
  }

  # VPC Configuration for Lambda
  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet.id]   # Add private subnets here
    security_group_ids = [aws_security_group.lambda_sg.id]  # Reference the Lambda SG
  }
}
