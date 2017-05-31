terraform {
  backend "s3" {
    bucket     = "artsy-terraform"
    key        = "aprb/terraform.tfstate"
    region     = "us-east-1"
    encrypt    = true
    lock_table = "terraform_locks"
  }
}

provider "aws" {}

data "terraform_remote_state" "infrastructure" {
    backend = "s3"
    config {
        bucket = "artsy-terraform"
        key = "infrastructure/terraform.tfstate"
        region = "us-east-1"
    }
}
