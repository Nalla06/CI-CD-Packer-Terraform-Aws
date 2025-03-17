variable "alb_sg_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "app_port" {
  description = "Port for the application"
  type        = number
  default     = 80
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}