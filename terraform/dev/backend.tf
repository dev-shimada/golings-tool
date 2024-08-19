terraform {
  backend "s3" {
    bucket  = var.aws_bucket
    key     = "terraform.tfstate"
    region  = var.aws_region
    profile = var.aws_profile
  }
}
