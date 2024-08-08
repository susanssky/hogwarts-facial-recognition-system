provider "aws" {}


terraform {
  backend "s3" {
    bucket = "cloud-projects-tfstate"
    key    = "2-rekognition.tfstate"
    region = "eu-west-2"
  }
}
