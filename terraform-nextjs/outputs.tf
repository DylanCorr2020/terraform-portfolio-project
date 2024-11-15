output "bucket_name" {
  value       = aws_s3_bucket.static_website_bucket.bucket
  description = "The name of the S3 bucket for the static website"
}

# Output the CloudFront Distribution URL

output "cloudfront_url" {
  value       = aws_cloudfront_distribution.s3_distribution.domain_name # Refers to the domain name of the CloudFront distribution
  description = "The CloudFront distribution domain name"
}
