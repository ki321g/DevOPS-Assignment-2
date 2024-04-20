# Outputs are defined here.
# These outputs are used to display the values of the resources created by the Terraform script.
output "target_group_arn" {
    description = "The ARN of the target group"
    value       = aws_lb_target_group.tg-http.arn
}

output "launch_template_name" {
    description = "The name of the launch template"
    value       = "${local.prefix}-Launch-Template"
}

output "security_groups" {
    description = "The IDs of the security groups"
    value       = [
        module.http_security_group.security_group_id, 
        module.ssh_bastion_security_group.security_group_id,
        module.egress_security_group.security_group_id
    ]
}

output "image_id" {
    description = "The ID of the AMI used for instances"
    value       = local.app_ami
}

output "instance_type" {
    description = "The type of instances"
    value       = "t2.nano"
}

output "iam_instance_profile_arn" {
    description = "The ARN of the IAM instance profile"
    value       = local.iam_roles.instance_profile_arn
}

output "vpc_id" {
    description = "The ID of the VPC"
    value       = module.vpc.default_vpc_id
}

output "alb_arn" {
    description = "The ARN of the Application Load Balancer"
    value       = module.alb.arn
}

output "public_ip" {
    description = "The public IP address of the instance"
    value       = "${chomp(data.http.myip.response_body)}"
}

output "key_pair_name" {
    description = "The key pair name"
    value       = module.key_pair.key_pair_name 
}

output "bastion_host" {
    description = "The public IP address of the bastion host"
    value       = module.bastion_host.public_ip
}

output "autoscaling_group_name" {
    description = "The name of the Auto Scaling group"
    value       =module.auto_scaling_group.autoscaling_group_name
}

output "scale_up_policy_arn" {
    description = "The ARN of the scale up policy"
    value       = aws_autoscaling_policy.scale_up.arn
}

output "scale_down_policy_arn" {
    description = "The ARN of the scale down policy"
    value       = aws_autoscaling_policy.scale_down.arn
}

output "cloudwatch_scale_up_alarm_arn" {
    description = "The ARN of the high threshold CloudWatch Alarm"
    value       =  aws_cloudwatch_metric_alarm.scale_up_alarm.arn
}

output "cloudwatch_scale_down_alarm_arn" {
    description = "The ARN of the low threshold CloudWatch Alarm"
    value       = aws_cloudwatch_metric_alarm.scale_down_alarm.arn
}