variable "name" {
  description = "The name of the security group"
  type        = string
}

variable "description" {
  description = "The description of the security group"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "ingress_rules" {
  description = "A list of ingress rules"
  type = list(object({
    from_port              = number
    to_port                = number
    protocol               = string
    cidr_blocks            = list(string)
    security_groups  = list(string)
  }))
}

variable "egress_rules" {
  description = "A list of egress rules"
  type = list(object({
    from_port              = number
    to_port                = number
    protocol               = string
    cidr_blocks            = list(string)
  }))
}