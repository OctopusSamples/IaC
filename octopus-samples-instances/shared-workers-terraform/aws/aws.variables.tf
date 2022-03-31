variable "tags" {
  type = map(string)
  default = {
    Name = "Samples Linux Worker"
    propagate_at_launch = true
  }
}

variable "octopus_aws_vpc_id" {
    type = string
    default = "#{Project.AWS.VPC.Id}"
}

variable "octopus_aws_security_group_id" {
    type = string
    default = "#{Project.AWS.SecurityGroup.Id}"
}

variable "octopus_aws_internet_gateway_id" {
    type = string
    default = "#{Project.AWS.InternetGateway.Id}"
}

variable "octopus_aws_linux_ami_id" {
    type = string
    default = "#{Project.AWS.Linux.AMI.Id}"
}

variable "octopus_aws_subnets" {
    type = list(string)
    default = #{Project.AWS.Subnets}
}

variable "octopus_aws_autoscalinggroup_size" {
    type = number
    default = "#{Project.AWS.EC2.Instance.Count}"
}

variable "octopus_aws_ec2_instance_type" {
    type = string
    default = "#{Project.AWS.EC2.Instance.Type}"
}

variable "auto_scaling_group_name" {
    type = string
    default = "#{Project.AWS.AutoscalingGroupName}"
}

variable "octopus_aws_role_name" {
    type = string
    default = "#{Project.AWS.EC2.Role.Name}"
}
variable "octopus_aws_policy_arn" {
    type = string
    default = "#{Project.AWS.Policy.Arn}"
}

variable "octopus_aws_instance_profile_name" {
    type = string
    default = "#{Project.AWS.InstanceProfile.Name}"
}

variable "octopus_aws_launch_configuration_name" {
    type = string
    default = "#{Project.AWS.LaunchConfiguration.Name}"
}