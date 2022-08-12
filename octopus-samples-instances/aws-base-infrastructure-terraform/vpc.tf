# VPC
resource "aws_vpc" "solutions_vpc" {
  cidr_block       = var.vpc_cidr
  tags = {
    Name = "solutions-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "solutions_igw" {
  vpc_id = aws_vpc.solutions_vpc.id
  tags = {
    Name = "solutions-igw"
  }
}

# Subnets : public
resource "aws_subnet" "solutions-public-sb" {
  count = length(var.subnets_cidr)
  vpc_id = aws_vpc.solutions_vpc.id
  cidr_block = element(var.subnets_cidr,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-${count.index+1}"
  }
}

# Route table: attach Internet Gateway 
resource "aws_route_table" "solutions_rt" {
  vpc_id = aws_vpc.solutions_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.solutions_igw.id
  }
  tags = {
    Name = "solutions-prt"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "a" {
  count = length(var.subnets_cidr)
  subnet_id      = element(aws_subnet.solutions-public-sb.*.id,count.index)
  route_table_id = aws_route_table.solutions_rt.id
}