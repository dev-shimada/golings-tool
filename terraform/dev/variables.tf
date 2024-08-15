variable "aws" {
  default = {
    profile = "default"
    region  = "ap-northeast-1"
    bucket  = "terraform-state"
  }
}
variable "schedule" {
  type    = string
  default = "cron(0 10 ? * MON *)"
}
