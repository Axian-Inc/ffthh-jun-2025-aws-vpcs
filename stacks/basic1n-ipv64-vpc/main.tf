provider "aws" {
  allowed_account_ids = [var.account_id]
  region              = var.region
}

module "vpc" {
  source = "../../modules/ipv64/basic1n"

  name_prefix     = var.name_prefix
  subnet_az_count = var.subnet_az_count
}
