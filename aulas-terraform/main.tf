provider "aws" {
	region = "${terraform.workspace == "production" ? "us-east-1" : "us-east-2"}"
	version = "~> 2.0"
}

terraform {
	backend "s3" {
		bucket = "descomplicando-terraform-guilherme-tfstates" /* nome apenas de exemplo */
		key    = "terraform-test.tfstate"
		region = "us-east-1"
		encrypt = true
	}
}
