terraform {
  required_version = ">=0.13.0"
}

provider "aws" {
  region = "#{AWS.Region}"
}

variable "cidr_blocks" {
  type = list(string)
}

variable "egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
}

variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["my-vpc"]
  }
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.selected.id
}

resource "aws_security_group" "samples-nsg" {
  name = "samples-nsg"

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = var.cidr_blocks
      description = egress.value.description
    }
  }
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = var.cidr_blocks
      description = ingress.value.description
    }
  }

  tags = {
    Terraform = "true"
    Environment = "#{Octopus.Environment.Name}"
  }
}
