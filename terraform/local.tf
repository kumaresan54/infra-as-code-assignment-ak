# Lambda functions and their corresponding routes
locals {
  lambda_functions = {
    "register_user" = {
      "handler"  = "register_user.handler",
      "filename" = "../lambda/register_user.py",
      "route"    = "/register"
    },
    "verify_user" = {
      "handler"  = "verify_user.handler",
      "filename" = "../lambda/verify_user.py",
      "route"    = "/"
    }
  }
  s3_files = {
    "index.html" = "../files/index.html"
    "error.html" = "../files/error.html"
  }
}