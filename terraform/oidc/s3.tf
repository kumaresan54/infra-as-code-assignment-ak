resource "aws_s3_bucket" "my_bucket_store" {
  bucket        = "my-assignment-bucket-store-${var.prefix}"
  force_destroy = true
}
