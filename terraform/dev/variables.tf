variable "aws_profile" {
  type    = string
  default = "default"
}
variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}
variable "aws_bucket" {
  type    = string
  default = "terraform-state"
}
variable "schedule" {
  type    = string
  default = "cron(0 10 ? * MON *)"
}
