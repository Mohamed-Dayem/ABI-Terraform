provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}


resource "aws_subnet" "my_subnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}


resource "aws_subnet" "my_subnet2" {
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  vpc_id             = aws_vpc.my_vpc.id

}


resource "aws_security_group" "laravel_backend_sg" {
  name        = "laravel-backend-sg"
  description = "Security group for Laravel PHP backend"
  vpc_id      = aws_vpc.my_vpc.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}








resource "aws_instance" "backend_instance" {
  ami                    = "ami-07d9b9ddc6cd8dd30"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_subnet1.id
  security_groups        = [aws_security_group.laravel_backend_sg.id]
  associate_public_ip_address = true
  key_name               = "demo"

  tags = {
    Name = "Backend Machine"
  }
}

resource "aws_security_group" "nodejs_frontend_sg" {
  name        = "nodejs-frontend-sg"
  description = "Security group for Node.js frontend"
  vpc_id      = aws_vpc.my_vpc.id
  

  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "frontend_instance" {
  ami                    = "ami-07d9b9ddc6cd8dd30" 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_subnet1.id
  security_groups        = [aws_security_group.nodejs_frontend_sg.id]
  associate_public_ip_address = true
  key_name               = "demo"

  tags = {
    Name = "Frontend Machine"
  }
}


resource "aws_db_subnet_group" "my_db_subnet_group" {
  name        = "my-db-subnet-group"
  description = "My DB Subnet Group"
  subnet_ids  = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id]
}

resource "aws_db_parameter_group" "mysql8_0_param_group" {
  name   = "my-mysql8-0-param-group"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "collation_server"
    value = "utf8_general_ci"
  }
}



resource "aws_db_instance" "mysql_instance" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  identifier           = "my-mysql-rdb"
  username             = "admin"
  password             = "12345678"
  parameter_group_name = aws_db_parameter_group.mysql8_0_param_group.name
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name



  tags = {
    Name = "My MySQL RDS"
  }
}
