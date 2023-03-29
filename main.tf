terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}
provider "aws" {
 region = "us-east-1"
}

resource "aws_vpc" "JD" {
  cidr_block = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames = true
  enable_dns_support = true
  
    }

resource "aws_subnet" "JD-subnet-public" {
  count = var.public_subnet_count
  vpc_id = aws_vpc.JD.id
  cidr_block = cidrsubnet(aws_vpc.JD.cidr_block, 8, count.index)
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
 tags = {
  "Name" = "${var.default_tags.env}"
 }
}

resource "aws_internet_gateway" "jd-igw" {
  vpc_id = aws_vpc.JD.id
  tags = {
    "Name" = "${var.default_tags.env}-IGW"
  }
}

resource "aws_route_table" "JD-route-table"{
  vpc_id = aws_vpc.JD.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jd-igw.id
  }
  
}
resource "aws_route_table_association" "JD-route-table-subnet-1" {
 count = var.public_subnet_count
  subnet_id = element(aws_subnet.JD-subnet-public.*.id, count.index)
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

