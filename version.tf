# terraform block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# provider block
provider "aws" {
  region  = "us-east-1" #us east (north.virginia)#
  profile = "cloud-admin"    #iam-user #
}
