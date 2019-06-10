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

resource "aws_launch_configuration" "api_launch_configuration" {
	name = "api_node_lc"
	image_id = "${var.ami}"
	instance_type = "${var.node_type}"
	
	key_name = "${var.key_pair}"
	security_groups = ["${aws_security_group.node_sg.id}"]
	user_data = "${data.template_file.api_node.rendered}"
}

resource "aws_alb_target_group" "api" {
	name = "api-target-group"
	port = 80
	protocol = "HTTP"
	vpc_id = "${var.vpc_id}"
	
	health_check {
        path = "/"
        port = "80"
        protocol = "HTTP"
        healthy_threshold = 2
        unhealthy_threshold = 2
        interval = 5
        timeout = 4
        matcher = "200-308"
    }
}

resource "aws_autoscaling_group" "api_autoscaling_group" {
	name = "api"
	launch_configuration = "${aws_launch_configuration.api_launch_configuration.name}"
	min_size = 2
	max_size = 4
	vpc_zone_identifier = ["${var.private_subnet_1}", "${var.private_subnet_2}"]

	
	target_group_arns = ["${aws_alb_target_group.api.arn}"]
	
	lifecycle {
		create_before_destroy = true
	}
	
	tag = {
		key = "Name"
		value = "api"
		propagate_at_launch = true
	}
	
}

resource "aws_autoscaling_policy" "scale-up" {
	name = "node-cpu-scale-up"
	autoscaling_group_name = "${aws_autoscaling_group.api_autoscaling_group.name}"
	adjustment_type = "ChangeInCapacity"
	scaling_adjustment = "1"
	cooldown = "300"
	policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale-up" {
	alarm_name = "scale-up"
	alarm_description = "cpu-scale-up"
	comparison_operator = "GreaterThanOrEqualToThreshold"
	evaluation_periods = "2"
	metric_name = "CPUUtilization"
	namespace = "AWS/EC2"
	period = "120"
	statistic = "Average"
	threshold = "60"
	dimensions = {
		"AutoScalingGroupName" = "${aws_autoscaling_group.api_autoscaling_group.name}"
	}
	actions_enabled = true
	alarm_actions = ["${aws_autoscaling_policy.scale-up.arn}"]
}

resource "aws_autoscaling_policy" "scale-down" {
	name = "scale-down"
	autoscaling_group_name = "${aws_autoscaling_group.api_autoscaling_group.name}"
	adjustment_type = "ChangeInCapacity"
	scaling_adjustment = "-1"
	cooldown = "300"
	policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale-down" {
	alarm_name = "node-cpu-scale-down"
	alarm_description = "cpu-scale-down"
	comparison_operator = "LessThanOrEqualToThreshold"
	evaluation_periods = "2"
	metric_name = "CPUUtilization"
	namespace = "AWS/EC2"
	period = "120"
	statistic = "Average"
	threshold = "60"
	dimensions = {
		"AutoScalingGroupName" = "${aws_autoscaling_group.api_autoscaling_group.name}"
	}
	actions_enabled = true
	alarm_actions = ["${aws_autoscaling_policy.scale-down.arn}"]
}


# alb security group
resource "aws_security_group" "alb_sg" {
	name = "alb security group"
	description = "ALB security group"
	vpc_id = "${var.vpc_id}"
	
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

}
