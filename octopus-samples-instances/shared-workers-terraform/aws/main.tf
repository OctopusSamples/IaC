terraform {

  required_version = ">=0.12"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  
  backend "s3" {
    bucket = "#{Project.AWS.Backend.Bucket}"
    key = "#{Project.AWS.Backend.Key}"
    region = "#{Project.AWS.Backend.Region}"
  }  
}

# Configure the AWS Provider
provider "aws" {
  region = "#{Project.AWS.Backend.Region}"
}
