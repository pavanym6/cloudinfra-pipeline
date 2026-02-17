locals {
  cluster-name = var.cluster-name
}

#-------------------------------------------------------------------VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr-block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc-name  # Fixed: Removed quotes to use the variable
    ENV  = var.env
  }
}

#-------------------------------------------------------------------IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw-name
    env  = var.env
    "kubernetes.io/cluster/${local.cluster-name}" = "owned"
  }
}

#-------------------------------------------------------------------PUBLIC SUBNET
resource "aws_subnet" "public_subnet" {
  count                   = var.pub_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.pub_cidr_block, count.index)
  availability_zone       = element(var.pub_availability_zone, count.index)
  map_public_ip_on_launch = true # This allows instances to get a dynamic Public IP
  
  tags = {
    Name                                          = "${var.pub_sub_name}-${count.index + 1}"
    Env                                           = var.env
    "kubernetes.io/cluster/${local.cluster-name}" = "owned"
    "kubernetes.io/role/elb"                      = "1"
  }
}

#-------------------------------------------------------------------PRIVATE SUBNET (Now "Publicly Accessible")
resource "aws_subnet" "private_subnet" {
  count                   = var.pri_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.pri_cidr_block, count.index)
  availability_zone       = element(var.pri_availability_zone, count.index)
  
  # Crucial Change: We enable Public IPs here so nodes can reach the internet without a NAT Gateway
  map_public_ip_on_launch = true 

  tags = {
    Name                                          = "${var.pri_subnet_name}-${count.index + 1}"
    ENV                                           = var.env
    "kubernetes.io/cluster/${local.cluster-name}" = "owned"
    "kubernetes.io/role/internal-elb"             = "1" 
  }
}

#-------------------------------------------------------------------COMMON ROUTE TABLE
# Since we can't use a NAT Gateway, both Public and Private subnets 
# will use this Route Table to talk to the Internet Gateway (IGW).
resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "lab-main-route-table"
    env  = var.env
  }
}

#-------------------------------------------------------------------RT ASSOCIATIONS
resource "aws_route_table_association" "public_assoc" {
  count          = var.pub_subnet_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.main_rt.id
}

resource "aws_route_table_association" "private_assoc" {
  count          = var.pri_subnet_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.main_rt.id
}

#-------------------------------------------------------------------SECURITY GROUP
resource "aws_security_group" "eks-cluster-sg" {
  name        = var.eks_sg
  description = "Allow traffic for EKS"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In a real project, restrict this to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.eks_sg
  }
}