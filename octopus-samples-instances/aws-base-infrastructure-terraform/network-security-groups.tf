resource "aws_security_group" "samples_security_group" {
  name        = "samples-security-group"
  description = "Security group for Samples resources."
  vpc_id      = aws_vpc.solutions_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.solutions_vpc.ipv6_cidr_block]
  }

  ingress {
    description      = "Tomcat default port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.solutions_vpc.ipv6_cidr_block]
  }

  ingress {
    description      = "MySQL default port"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    #cidr_blocks      = [aws_vpc.solutions_vpc.cidr_block]
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.solutions_vpc.ipv6_cidr_block]
  }  

  ingress {
    description      = "MSSQL default port"
    from_port        = 1433
    to_port          = 1433
    protocol         = "tcp"
    #cidr_blocks      = [aws_vpc.solutions_vpc.cidr_block]
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.solutions_vpc.ipv6_cidr_block]
  }

  ingress {
    description      = "PostgreSQL default port"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    #cidr_blocks      = [aws_vpc.solutions_vpc.cidr_block]
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.solutions_vpc.ipv6_cidr_block]
    
  }

  ingress {
    description      = "OctoPetShop default ports"
    from_port        = 5000
    to_port          = 5001
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.solutions_vpc.ipv6_cidr_block]
  }

  ingress {
    description      = "Oracle default ports"
    from_port        = 1521
    to_port          = 1521
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.solutions_vpc.cidr_block]
    #ipv6_cidr_blocks = [aws_vpc.solutions_vpc.ipv6_cidr_block]
  }

  ingress {
    description      = "Tentacle default ports"
    from_port        = 10933
    to_port          = 10933
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.solutions_vpc.cidr_block, var.octopus_cloud_static_cidr]
    #ipv6_cidr_blocks = [aws_vpc.solutions_vpc.ipv6_cidr_block]
  }

  ingress {
    description      = "IIS default HTTP port"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.solutions_vpc.cidr_block]
    #ipv6_cidr_blocks = [aws_vpc.solutions_vpc.ipv6_cidr_block]
  }  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "samples-security-group"
  }
}