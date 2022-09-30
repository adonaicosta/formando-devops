provider "aws" {
	region = "us-east-1"
	version = "~> 2.0"
}

terraform {
	backend "s3" {
		bucket = "descomplicando-terraform-guilherme-tfstates" /* nome apenas de exemplo */
		key    = "terraform-test.tfstate"
		region = "us-east-1"
	}
}
