terraform {
    # backend "s3" {
    #   bucket = "eks-bucket"
    #   key    = "eks-bucket/sales"
    #   region = "eu-west-3"
    # }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-3"
}
