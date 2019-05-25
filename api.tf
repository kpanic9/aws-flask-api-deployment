provider "aws" {
	region = "us-west-1"
}



data "template_file" "api_node" {
	template = "${file("./app-config.sh.tpl")}"
	
	vars {
		git_user = "${var.git_user}"
		git_password = "${var.git_password}"
		git_url = "${git_url}"
		config = "${var.config}"
		api_dir = "${var.api_dir}"
	}
}

