variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}
 
variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}
 
variable "iam_role_arn" {
  description = "ARN of the IAM role for Lambda"
  type        = string
}
