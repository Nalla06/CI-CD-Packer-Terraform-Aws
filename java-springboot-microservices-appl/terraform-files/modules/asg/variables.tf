variable "ami_id" {
  description = "AMI ID for the instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "user_data" {
  description = "User data script"
  type        = string
}

variable "ec2_sg_id" {
  description = "ID of the existing security group"
  type        = string
}

variable "ec2_instance_connect_sg_id" {
  description = "ID of the EC2 Instance Connect security group"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "min_size" {
  description = "Minimum size of the ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum size of the ASG"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity of the ASG"
  type        = number
}

variable "alb_tg_arn" {
  description = "ARN of the ALB target group"
  type        = string
}
variable "ec2_instance_connect_endpoint_id" {
  description = "ID of the EC2 Instance Connect Endpoint"
  type        = string
}