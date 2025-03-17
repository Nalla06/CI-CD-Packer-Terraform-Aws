resource "aws_db_subnet_group" "this" {
  name       = "app-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "app-db-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]
  skip_final_snapshot    = true
  multi_az               = true

  tags = {
    Name = "app-db-instance"
  }
}
