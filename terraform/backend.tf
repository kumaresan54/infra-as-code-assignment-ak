terraform {
  backend "s3" {
    bucket  = "my-assignment-bucket-store-ak"
    key     = "terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}