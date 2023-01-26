#DB Security Group
resource "aws_security_group" "db" {
  name_prefix = var.db_security_group_name
  description = "Allow MYSQL inbound traffic"
  vpc_id      = aws_vpc.main.id


  ingress {
    description = "MYSQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_mysql_db"
  }
}

#DB Subnet Group
resource "aws_db_subnet_group" "tf-db" {
  name       = "tf-db subnet group"
  subnet_ids = [aws_subnet.pri_a.id, aws_subnet.pri_c.id]

  tags = {
    Name = "Terraform DB subnet group"
  }
}

#DB
resource "aws_db_instance" "tf-db" {
  identifier_prefix = "tf-db"
  allocated_storage = 10
  db_name           = "tf"
  engine            = "mysql"
  engine_version    = "5.7"
  /*multi_az               = true*/
  instance_class         = "db.t3.micro"
  username               = "master"
  password               = "tf-password"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.tf-db.name
  vpc_security_group_ids = [aws_security_group.db.id]
}
