terraform {
  # Local backend is the default so the repo works immediately in a fresh environment.
  # For a shared AWS deployment, bootstrap the S3 backend and switch to the commented
  # S3 configuration below before running terraform init -reconfigure.
  backend "local" {
    path = "terraform.tfstate"
  }

  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "eightbytes/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "your-terraform-lock-table"
  # }
}
