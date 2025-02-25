variable "patient_service_image_uri" {
  description = "The ECR repository URL for the patient service Lambda function"
  type        = string
}

variable "appointment_service_image_uri" {
  description = "The ECR repository URL for the appointment service Lambda function"
  type        = string
}

variable "private_subnet_ids" {
  description = "The subnet IDs where Lambda will run"
  type        = list(string)
}

variable "lambda_security_group_id" {
  description = "The security group ID for Lambda functions"
  type        = string
}

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
        Resource = var.patient_service_image_uri
      },
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer"
        ]
        Effect   = "Allow"
        Resource = var.appointment_service_image_uri
      }
    ]
  })
}

# Lambda function for Patient Service with VPC and Security Group
resource "aws_lambda_function" "patient_service" {
  function_name = "patient-service"
  role          = aws_iam_role.lambda_exec_role.arn
  image_uri     = var.patient_service_image_uri
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
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }
}

# Lambda function for Appointment Service with VPC and Security Group
resource "aws_lambda_function" "appointment_service" {
  function_name = "appointment-service"
  role          = aws_iam_role.lambda_exec_role.arn
  image_uri     = var.appointment_service_image_uri
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
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }
}
