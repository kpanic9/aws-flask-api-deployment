variable "git_user" {
	type = "string"
	default = "user"
}

variable "git_password" {
	type = "string"
	default = "password"
}

variable "git_url" {
	type = "string"
	default = "url"
}

variable "api_dir" {
	type = "string"
	default = "url"
}

variable "config" {
	type = "string"
	default = "config"
}

variable "private_subnet_1" {
	type = "string"
	default = "subnet-0ada1a79ff65969ad"
}

variable "private_subnet_2" {
	type = "string"
	default = "subnet-03f5581803dd0663d"
}

variable "public_subnet_1" {
	type = "string"
	default = "subnet-0e01336213c9a67b4"
}

variable "public_subnet_2" {
	type = "string"
	default = "subnet-0b9d077bb38fc4659"
}

variable "ami" {
	type = "string"
	default = "ami-0782017a917e973e7"
}

variable "node_type" {
	type = "string"
	default = "t2.micro"
}

variable "key_pair" {
	type = "string"
	default = "test"
}



