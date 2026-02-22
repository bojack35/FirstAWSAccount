terraform {
  backend "s3" {
    bucket         = "tf-state-curtis"
    key            = "network/vpc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}