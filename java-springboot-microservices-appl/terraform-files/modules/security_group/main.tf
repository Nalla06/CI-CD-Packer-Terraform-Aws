resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
  
  # Default egress rule directly in the security group
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Delay to ensure the security group is fully created
resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_security_group.this]
  create_duration = "30s"
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress_rules)
  
  security_group_id        = aws_security_group.this.id
  type                     = "ingress"
  from_port                = var.ingress_rules[count.index].from_port
  to_port                  = var.ingress_rules[count.index].to_port
  protocol                 = var.ingress_rules[count.index].protocol
  cidr_blocks              = length(var.ingress_rules[count.index].cidr_blocks) > 0 ? var.ingress_rules[count.index].cidr_blocks : null
  source_security_group_id = length(var.ingress_rules[count.index].security_groups) > 0 ? var.ingress_rules[count.index].security_groups[0] : null
  
  depends_on = [time_sleep.wait_30_seconds]
}