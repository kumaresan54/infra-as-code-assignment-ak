# Create an S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-assignment-bucket-${var.prefix}" 
}

resource "aws_s3_object" "website_files" {
  for_each = local.s3_files

  bucket = aws_s3_bucket.my_bucket.bucket
  key    = each.key    
  source = each.value 
}