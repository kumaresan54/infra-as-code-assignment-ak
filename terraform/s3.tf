module "s3_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  bucket        = "my-assignment-bucket-${var.prefix}"
  force_destroy = true
  version       = "~> 4.0"
}

resource "aws_s3_object" "website_files" {
  for_each = local.s3_files

  bucket = module.s3_bucket.s3_bucket_id
  key    = each.key
  source = each.value
}
