resource "aws_vpc" "vpc_name" {
  vpc_name = var.vpc_name
  cidr_block = "10.0.0.0/16"
}