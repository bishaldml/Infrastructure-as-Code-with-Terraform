terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Define the provider
provider "aws" {
  region = "ap-south-1"
}

# Define the VPC
resource "aws_vpc" "bishal" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "bishal"
  }
}

# Define the subnets
resource "aws_subnet" "bishalsub-ap-south-1a" {
  vpc_id = aws_vpc.bishal.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "sub-ap-south-1a"
  }
}

#Create Internet gateway
resource "aws_internet_gateway" "bishal-ig01" {
}

resource "aws_internet_gateway_attachment" "bishaligattach" {
  internet_gateway_id = aws_internet_gateway.bishal-ig01.id
  vpc_id              = aws_vpc.bishal.id
}

resource "aws_route_table" "bishalroutetb01" {
vpc_id              = aws_vpc.bishal.id
}

resource "aws_route" "route01" {
  route_table_id            = aws_route_table.bishalroutetb01.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.bishal-ig01.id
}

resource "aws_route_table_association" "bishalroutetbassoc01" {
  subnet_id      = aws_subnet.bishalsub-ap-south-1a.id
  route_table_id = aws_route_table.bishalroutetb01.id
}

#Define Security group
resource "aws_security_group" "bishalsg01" {
  name_prefix = "sg01_security_group"
  vpc_id = aws_vpc.bishal.id
 
ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
 
ingress {
    from_port   = 80
    to_port     = 80
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

#Define ec2 instance
resource "aws_instance" "bishalhttp-srv01" {
  ami = "ami-0c768662cc797cd75"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.bishalsub-ap-south-1a.id
  vpc_security_group_ids = [aws_security_group.bishalsg01.id]
  user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install -y httpd
            sudo systemctl start httpd
            sudo systemctl enable httpd
            sudo echo "<h1>Welcome to Bishal-site</h1>" > /var/www/html/index.html
EOF
tags = {
    Name = "bishalhttp-srv01"
  }
  key_name = "minikube"
}
