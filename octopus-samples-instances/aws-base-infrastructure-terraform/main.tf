terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    
  }
  
  backend "s3" { }
  required_version = "~> 1.9.8"
}

