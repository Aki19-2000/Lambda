# VPC Configuration (Private Subnet)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}

# Security Group for Lambda
resource "aws_security_group" "lambda_sg" {
  vpc_id      = aws_vpc.main.id
  description = "Security group for Lambda functions"
}

# Output the subnet IDs and security group ID
output "private_subnet_ids" {
  value = [aws_subnet.private_subnet.id]
}

output "lambda_security_group_id" {
  value = aws_security_group.lambda_sg.id
}
