provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "vpc_demo" {
  cidr_block       = "11.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "learnvpc"
  }
}

resource "aws_subnet" "pub_sub_1" {
  vpc_id                  = aws_vpc.vpc_demo.id
  cidr_block              = "11.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-1"
  }
}
resource "aws_subnet" "pub_sub_2" {
  vpc_id                  = aws_vpc.vpc_demo.id
  cidr_block              = "11.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "Public-Subnet-2"
  }
}

resource "aws_internet_gateway" "igw" { 
    vpc_id = aws_vpc.vpc_demo.id 
    
    tags = { 
         Name = "Internet gateway" 
   } 
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc_demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
    tags = {
    Name = "Route Table"
  }
}
resource "aws_route_table_association" "pub_1" {
  subnet_id      = aws_subnet.pub_sub_1.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "pub_2" {
  subnet_id      = aws_subnet.pub_sub_2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.vpc_demo.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-security-group"
  }
}

resource "aws_instance" "web_1" {
  ami                    = "ami-0d27e0fb3bac4d724"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.pub_sub_1.id
  key_name               ="demo_key"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y docker
    systemctl enable --now docker
    docker pull ghcr.io/pnpraveena2020-gif/jenkins-docker-app:latest
    docker run -d --name myapp -p 80:80 ghcr.io/pnpraveena2020-gif/jenkins-docker-app:latest
  EOF

  tags = {
    Name = "Web-Server-1"
  }
}

resource "aws_instance" "web_2" {
  ami                    = "ami-0d27e0fb3bac4d724"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.pub_sub_2.id
  key_name               = "demo_key"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y docker
    systemctl enable --now docker
    docker pull ghcr.io/pnpraveena2020-gif/jenkins-docker-app:latest
    docker run -d --name myapp -p 80:80 ghcr.io/pnpraveena2020-gif/jenkins-docker-app:latest
  EOF

  tags = {
    Name = "Web-Server-2"
  }
}
