resource "aws_launch_configuration" "linux-worker-launchconfig" {
    name_prefix = "linux-worker-launchconfig"
    image_id = "${var.octopus_aws_linux_ami_id}"
    instance_type = var.octopus_aws_ec2_instance_type
    
    security_groups = ["${var.octopus_aws_security_group_id}"]
  
    # script to run when created
    user_data = "${file("../configure-tentacle.sh")}"
}

resource "aws_autoscaling_group" "linux-worker-autoscaling" {
    name = "linux-worker-autoscaling"
    vpc_zone_identifier = var.octopus_aws_subnets
    launch_configuration = "${aws_launch_configuration.linux-worker-launchconfig.name}"
    min_size = var.octopus_aws_autoscalinggroup_size
    max_size = var.octopus_aws_autoscalinggroup_size
    health_check_grace_period = 300
    health_check_type = "EC2"
    force_delete = true

    tag {
        key = "Name"
        value = "Samples Linux Worker"
        propagate_at_launch = true
    }
}

