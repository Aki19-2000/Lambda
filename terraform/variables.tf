variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "The AWS Account ID"
  type        = string
  default     = ""  # You can leave it blank or hardcode your AWS account ID here
}
