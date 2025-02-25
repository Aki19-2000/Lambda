variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "iam_role_arn" {
  description = "ARN of the IAM role for Lambda"
  type        = string
}

variable "image_uri" {
  description = "URI for the container image in ECR"
  type        = string
}

variable "environment" {
  description = "Environment variable for Lambda (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "dlq_arn" {
  description = "ARN of the Dead Letter Queue (optional)"
  type        = string
  default     = ""  # Default value is empty, can be updated when required
}
