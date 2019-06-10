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
	default = ""
}

variable "private_subnet_2" {
	type = "string"
	default = ""
}

variable "public_subnet_1" {
	type = "string"
	default = ""
}

variable "public_subnet_2" {
	type = "string"
	default = ""
}

variable "ami" {
	type = "string"
	default = ""
}

variable "node_type" {
	type = "string"
	default = "t2.micro"
}

variable "key_pair" {
	type = "string"
	default = "test"
}

variable "vpc_id" {
	type = "string"
	default = ""
}
