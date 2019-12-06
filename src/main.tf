  
terraform {
  backend "s3" {
    bucket = "terraform-boggyd"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
  version = "2.41.0"
}

resource "aws_instance" "example" {
  ami           = "ami-05f37c3995fffb4fd"
  instance_type = "t2.micro"
}