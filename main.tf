terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}
provider "aws" {
  default_tags {
    tags = {
    Name = "Jason"
    name = "jason"
    }
  }
   region = "us-east-1"
}

resource "aws_vpc" "JD" {
  cidr_block = "10.4.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames = true
  enable_dns_support = true
  
    }

resource "aws_subnet" "JD-subnet-public-1" {
  vpc_id = aws_vpc.JD.id
  cidr_block = "10.4.0.0/26"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
 
}

resource "aws_internet_gateway" "jd-igw" {
  vpc_id = aws_vpc.JD.id
  
}

resource "aws_route_table" "JD-route-table"{
  vpc_id = aws_vpc.JD.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jd-igw.id
  }
  
}
resource "aws_route_table_association" "JD-route-table-subnet-1" {
  subnet_id = aws_subnet.JD-subnet-public-1.id
  route_table_id = aws_route_table.JD-route-table.id
}

resource "aws_security_group" "JD-VPC-Main-SG" {
  vpc_id = aws_vpc.JD.id
egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
  from_port = 22
  to_port =  22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_spot_instance_request" "jd-terrafrom-ec2" {
  ami = "ami-04581fbf744a7d11f"
  
  instance_type = "t3.micro"
  key_name = "Jason_D"
  subnet_id = aws_subnet.JD-subnet-public-1.id
  vpc_security_group_ids = [aws_security_group.JD-VPC-Main-SG.id]
    
}