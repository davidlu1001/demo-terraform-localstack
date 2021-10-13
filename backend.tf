# Use S3 as remote backend with DynamoDB table for lock
terraform {
  backend "s3" {
    region                      = "ap-southeast-2"
    bucket                      = "terraform-state"
    key                         = "global/s3/terraform.tfstate"
    endpoint                    = "http://localhost:4566"
    access_key                  = "test"
    secret_key                  = "test"
    force_path_style            = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    dynamodb_table              = "terraform-lock"
    dynamodb_endpoint           = "http://localhost:4566"
    encrypt                     = true
  }
}
