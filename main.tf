terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~>3.0"
      }
    }
}

# Configure the AWS provider 
provider "aws" {
    region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "Topic1-VPC"{
    cidr_block = var.cidr_block[0]
    tags = {
        Name = "Topic1-VPC"
    }
}

# Create Subnet (Public)
resource "aws_subnet" "Topic1-Subnet" {
    vpc_id = aws_vpc.Topic1-VPC.id
    cidr_block = var.cidr_block[1]
    tags = {
        Name = "Topic1-Subnet"
    }
}

# Create Internet Gateway
resource "aws_internet_gateway" "Topic1-IGW" {
    vpc_id = aws_vpc.Topic1-VPC.id
    tags = {
        Name = "Topic1-IGW"
    }
}

# Create Security Group
resource "aws_security_group" "Topic1-SG" {
    name = "Topic1-SG"
    description = "To allow inbound and outbount traffic to Topic1 EC2"
    vpc_id = aws_vpc.Topic1-VPC.id
    dynamic ingress {
        iterator = port
        for_each = var.ports
            content {
              from_port = port.value
              to_port = port.value
              protocol = "tcp"
              cidr_blocks = ["0.0.0.0/0"]
            }
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "allow traffic"
    }
}

# Create route table and association
resource "aws_route_table" "Topic1-rtb" {
    vpc_id = aws_vpc.Topic1-VPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Topic1-IGW.id
    }
    tags = {
        Name = "Topic1-rtb"
    }
}

resource "aws_route_table_association" "Topic1-rtba" {
    subnet_id = aws_subnet.Topic1-Subnet.id
    route_table_id = aws_route_table.Topic1-rtb.id
}

# Create an AWS EC2 Instance to host Docker
resource "aws_instance" "ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "ec2"
  vpc_security_group_ids = [aws_security_group.Topic1-SG.id]
  subnet_id = aws_subnet.Topic1-Subnet.id
  associate_public_ip_address = true
  user_data = file("./InstallDocker.sh")

  tags = {
    Name = "Dockerhost"
  }
}