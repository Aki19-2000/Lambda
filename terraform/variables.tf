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

