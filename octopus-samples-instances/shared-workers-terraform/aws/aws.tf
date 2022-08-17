

resource "aws_iam_instance_profile" "linux-worker-profile" {
    name = var.octopus_aws_instance_profile_name
    role = var.octopus_aws_role_name
}


resource "aws_launch_configuration" "linux-worker-launchconfig" {
    name_prefix = var.octopus_aws_launch_configuration_name
    image_id = "${var.octopus_aws_linux_ami_id}"
    instance_type = var.octopus_aws_ec2_instance_type

    iam_instance_profile = "${aws_iam_instance_profile.linux-worker-profile.name}"
    key_name = "ShawnSesna-samples-debug"
    
    security_groups = ["${var.octopus_aws_security_group_id}"]
  
    # script to run when created
    user_data = "${file("../configure-tentacle.sh")}"

    # root disk
    root_block_device {
        volume_size           = "30"
        delete_on_termination = true
    }
}

resource "aws_autoscaling_group" "linux-worker-autoscaling" {
    name = var.auto_scaling_group_name
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

