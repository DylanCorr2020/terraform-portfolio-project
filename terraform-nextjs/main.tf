
# Provider configuration
provider "aws" {
  region = "eu-west-1"
}


# Create an S3 bucket for hosting a static website
resource "aws_s3_bucket" "static_website_bucket" {
  bucket = "myblog-tf-bucket" # The name of the S3 bucket that will store the static website files.


  website {
    index_document = "index.html" # Defines the index page (landing page) for the website.
    error_document = "index.html" # Defines the error page (e.g., for 404 errors) to be served when there's an issue.
  }

  tags = {
    Name = "myblog-tf-bucket" #tag to define the name of the bucket 
  }


}
# Set the public access block separately
#this allows the bucket to be accessed accessible
resource "aws_s3_bucket_public_access_block" "static_website_bucket_public_access" {
  bucket                  = aws_s3_bucket.static_website_bucket.bucket
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# Create an S3 bucket policy to allow public access to the website files
resource "aws_s3_bucket_policy" "allow_access_from_any_account" {
  bucket = aws_s3_bucket.static_website_bucket.id # Refers to the ID of the previously created S3 bucket.


  # Specifies the version of the policy language.
  # This policy allows access.
  # The wildcard (*) means any user can access the content.
  # The allowed action is 'GetObject' (reading files) from the bucket.
  # allows to get any objects from the bucket 
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::myblog-tf-bucket/*"
      ]
    }
  ]
}
EOF
}


# Create a CloudFront distribution to deliver the static website content from the S3 bucket
resource "aws_cloudfront_distribution" "s3_distribution" {

  # Origin block defines where CloudFront will fetch the content (from S3 bucket in this case)
  origin {
    domain_name = "myblog-tf-bucket.s3.eu-west-1.amazonaws.com" # The S3 bucket's domain name for the website.
    origin_id   = "S3-Website"                                  # A unique ID for this origin (the S3 bucket) within CloudFront.
  }


  enabled = true # This ensures the CloudFront distribution is active (not disabled).

  # Defines the default object to serve when accessing the root URL of the CloudFront distribution.
  default_root_object = "index.html"


  #how CloudFront interacts with requests and caches content.
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"] #Specifies the HTTP methods that users are allowed to use when requesting content from this CloudFront distribution.
    cached_methods  = ["GET", "HEAD"] #CloudFront caches responses only for GET and HEAD requests.
    # Specifies that the request should be routed to the "s3-Website" origin.
    target_origin_id = "S3-Website"


    forwarded_values {

      query_string = false # Do not forward query strings in the request to S3.

      cookies {
        forward = "none" # Do not forward cookies with the request to S3
      }
    }
    viewer_protocol_policy = "redirect-to-https" # Force all viewers to use HTTPS for secure access.

  }


  # Restrictions block allows configuring geographical restrictions (not applying any here).
  restrictions {

    geo_restriction {
      restriction_type = "none"
    }

  }

  # Viewer certificate for CloudFront's SSL/TLS setup.
  viewer_certificate {
    cloudfront_default_certificate = true # Use CloudFront's default SSL certificate (not a custom domain).
  }

  tags = {
    Name = "cloud-front-s3"
  }

}

