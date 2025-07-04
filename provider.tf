# AWS provider version definition
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "terraform/qa/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    profile        = "my-aws-profile"
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

}
