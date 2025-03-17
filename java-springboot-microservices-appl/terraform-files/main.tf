resource "aws_security_group" "main" {
  name        = "main-sg"
  description = "Main security group"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "main-sg"
  }
}

resource "aws_security_group" "ec2_instance_connect_ingress" {
  name        = "ec2-instance-connect-ingress-sg"
  description = "Allow EC2 Instance Connect Endpoint to access instances"
  vpc_id      =  module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from EC2 Instance Connect Endpoint"
  }

  tags = {
    Name = "ec2-instance-connect-ingress-sg"
  }
}
# EC2 Instance Connect Endpoint
resource "aws_ec2_instance_connect_endpoint" "app_endpoint" {
  subnet_id          = module.vpc.private_subnet_ids[0]
  security_group_ids = [aws_security_group.ec2_instance_connect_ingress.id]
  preserve_client_ip = true
  
  tags = {
    Name = "app-ec2-instance-connect"
  }
}
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name               = "ec2_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
module "vpc" {
  source           = "./modules/vpc"
  vpc_cidr         = var.vpc_cidr
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets
  availability_zones = var.availability_zones
}

module "alb_sg" {
  source      = "./modules/security_group"
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], security_groups = [] },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], security_groups = [] }
  ]

  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], security_groups = [] }
  ]
}

module "ec2_sg" {
  source      = "./modules/security_group"
  name        = "ec2-sg"
  description = "Security group for EC2"
  vpc_id      = module.vpc.vpc_id
  depends_on  = [module.alb_sg]  # Add this line

  ingress_rules = [
    { 
      from_port = 8080, 
      to_port = 8080, 
      protocol = "tcp", 
      cidr_blocks = [], 
      security_groups = [module.alb_sg.sg_id] 
    }
    
  ]
  
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], security_groups = [] }
  ]
}

module "rds_sg" {
  source      = "./modules/security_group"
  name        = "rds-sg"
  description = "Security group for RDS"
  vpc_id      = module.vpc.vpc_id
  depends_on  = [module.ec2_sg]  # Add this line

  ingress_rules = [
    { 
      from_port = 3306, 
      to_port = 3306, 
      protocol = "tcp", 
      security_groups = [module.ec2_sg.sg_id], 
      cidr_blocks = [] 
    }
  ]

  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], security_groups = [] }
  ]
}
module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.alb_sg.sg_id
  app_port          = 8080
  depends_on        = [module.alb_sg]  # Add this line
}

module "asg" {
  source                           = "./modules/asg"
  ec2_sg_id                        = module.ec2_sg.sg_id
  alb_tg_arn                       = module.alb.alb_tg_arn
  private_subnet_ids               = module.vpc.private_subnet_ids
  ami_id                           = var.ami_id
  instance_type                    = var.instance_type
  key_name                         = var.key_name
  min_size                         = var.asg_min_size
  max_size                         = var.asg_max_size
  desired_capacity                 = var.asg_desired_capacity
  user_data                        = file("scripts/user_data.sh")
  ec2_instance_connect_sg_id       = aws_security_group.ec2_instance_connect_ingress.id
  iam_instance_profile_name        = aws_iam_instance_profile.ec2_profile.name
  ec2_instance_connect_endpoint_id = aws_ec2_instance_connect_endpoint.app_endpoint.id
  depends_on                       = [module.ec2_sg, module.alb]  # Add this line
}

module "rds" {
  source            = "./modules/rds"
  subnet_ids        = module.vpc.database_subnet_ids
  rds_sg_id         = module.rds_sg.sg_id
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  depends_on        = [module.rds_sg]  # Add this line
}