terraform {
  backend "s3" {
    # Specifies the storage backend type as Amazon S3
    bucket = "dylan-terraform-state"
    # The S3 bucket where the state file will be stored
    key = "global/s3/terraform.tfstate"
    # The specific path within the bucket where the state file will be placed
    region = "eu-west-1"
    # The AWS region where the S3 bucket is located
    dynamodb_table = "terraform-locks"
    # The DynamoDB table used for locking the state file, preventing concurrent modifications ensures integrity 
  }
}

