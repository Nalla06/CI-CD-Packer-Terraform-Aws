variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "database_subnets" {
  description = "List of database subnet CIDRs"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  default     = "ami-08b5b3a93ed654d19"
  # This should be your Packer-built AMI ID
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  default     = "linux-key-pair"
}

variable "asg_min_size" {
  description = "Minimum size of ASG"
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of ASG"
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired capacity of ASG"
  default     = 2
}

variable "db_name" {
  description = "Database name"
  default     = "appdb"
}

variable "db_username" {
  description = "Database username"
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  sensitive   = true
}

variable "db_instance_class" {
  description = "Database instance class"
  default     = "db.t3.micro"
}
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]  # Adjust for your region
}