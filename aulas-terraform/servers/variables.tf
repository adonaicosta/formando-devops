variable "image_id" {
	default = "ami-12345678"
	type = string
	descripttion = "BLABLABLA"

	validation {
		condition	= length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
		error_message = "must be a valid AMI id"
	}
}

variable "servers" {
	
}
												
