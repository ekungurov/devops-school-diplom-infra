resource "aws_db_subnet_group" "education" {
  name       = "education"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "Education"
  }
}

resource "aws_db_parameter_group" "education" {
  name   = "education"
  family = "mariadb10.4"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }  

  parameter {
    name  = "sql_mode"
    value = "NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION"
  }
}

resource "aws_db_instance" "education" {
  identifier             = "education"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  name                   = "star_wars"
  engine                 = "mariadb"
  engine_version         = "10.4"
  username               = "edu"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.education.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
