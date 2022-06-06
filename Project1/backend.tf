terraform {

  backend "s3" {

    # Replace this with your bucket name!

    bucket         = "qg-dev-terraform-statefile-s3ue1"
    key            = "global/s3/dev/terraform.tfstate"
    region         = "us-east-1"

    # Replace this with your DynamoDB table name!

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}