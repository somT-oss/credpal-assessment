output "bucket_name" {
  value = aws_s3_bucket.deploy.id
}

output "bucket_arn" {
  value = aws_s3_bucket.deploy.arn
}
