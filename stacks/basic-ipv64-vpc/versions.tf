terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.58"
    }
  }

  #backend "s3" {
  #  bucket  = "<BUCKET NAME HERE>"
  #  key     = "<UNIQUE STACK KEY HERE>/terraform.tfstate"
  #  region  = "<BUCKET REGION HERE>"
  #  encrypt = true
  #  dynamodb_table = "<DYNAMODB TABLE NAME HERE>"
  #}
}
