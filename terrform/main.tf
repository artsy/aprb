provider "aws" {}

resource "terraform_remote_state" "infrastructure" {
    backend = "s3"
    config {
        bucket = "artsy-terraform"
        key = "infrastructure/terraform.tfstate"
        region = "us-east-1"
    }
}
