terraform {
  backend "s3" {
    bucket  = var.aws["bucket"]
    key     = "terraform.tfstate"
    region  = var.aws["region"]
    profile = var.aws["profile"]
  }
}
