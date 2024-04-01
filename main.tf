
/****************************************************************************************************
*  Section : Create VPC
*
*  Desc: This Module is used to create a VPC 
*        with 3 public and 3 private subnets in 3 AZs
*        It also creates a NAT Gateway and VPN Gateway
*
*  URL: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
*
*  REVISIONS:
*       Ver         Date          Author                 Description
*    ---------   ----------   ---------------   ------------------------------------
*       1.0      28/03/2024    Kieron Garvey     1. Created VPC Module
******************************************************************************************************/
module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = "${local.prefix}-vpc"
    cidr = "10.0.0.0/16"

    azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

    # enable_vpn_gateway = true
    enable_dns_hostnames = true
    enable_nat_gateway = true    
    single_nat_gateway   = true
    
    tags = merge(
    var.default_tags,
    {
        VPC-Name = "${local.prefix}-vpc"
    }
    )
}

/****************************************************************************************************
*  Section : Get Public IP to use in SSH Security Group
* 
*  Desc: After a bit of research, I found a way to get the public IP of the PC 
*        runing the terraform script
*
*  URL#1: https://stackoverflow.com/questions/46763287/i-want-to-identify-the-public-ip-of-the-terraform-execution-environment-and-add
*  URL#2: https://www.reddit.com/r/Terraform/comments/9g62ox/getting_my_own_public_ip/
******************************************************************************************************/
data "http" "myip" {
    url = "https://ipv4.icanhazip.com"  
}


/****************************************************************************************************
*  Section : Create Security Groups
*
*  Desc: This Section is used to create Security Groups
*
*  URL: https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
*
*  REVISIONS:
*       Ver         Date          Author                 Description
*    ---------   ----------   ---------------   ------------------------------------
*       1.0      28/03/2024    Kieron Garvey     1. Created SSH & HTTP Security Module
******************************************************************************************************/
module "egress_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name               = "${local.prefix}-all-egress"
  description        = "Allow all egress"
  vpc_id             = module.vpc.vpc_id
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

   tags = merge(
    var.default_tags,
    {
        Security-Group-Name = "${local.prefix}-egress_security_group"
    }
    )
}

module "http_security_group" {
    source = "terraform-aws-modules/security-group/aws"

    name                = "${local.prefix}-http"
    description         = "Allow all HTTP ingress"
    vpc_id              = module.vpc.vpc_id
    ingress_cidr_blocks = ["0.0.0.0/0"]
    ingress_rules       = ["http-80-tcp"]

    tags = merge(
    var.default_tags,
    {
        Security-Group-Name = "${local.prefix}-http"
    }
    )
}

module "ssh_security_group" {
    source = "terraform-aws-modules/security-group/aws"

    name                = "${local.prefix}-ssh"
    description         = "Allow all SSH ingress"
    vpc_id              = module.vpc.vpc_id
    # ingress_cidr_blocks = [
    #     "${chomp(data.http.myip.response_body)}/32",
    #     "86.44.41.7/32" 
    # ]
    ingress_cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
    ingress_rules       = ["ssh-tcp"]

    tags = merge(
        var.default_tags,
        {
            Security-Group-Name = "${local.prefix}-ssh"
        }
    )
}

module "ssh_bastion_security_group" {
    source = "terraform-aws-modules/security-group/aws"

    name                = "${local.prefix}-ssh-bastion"
    description         = "Allow all SSH ingress from bastion"
    vpc_id              = module.vpc.vpc_id
    ingress_cidr_blocks = ["${module.bastion_host.private_ip}/32"]
    ingress_rules = ["ssh-tcp"]

    tags = merge(
        var.default_tags,
        {
            Security-Group-Name = "${local.prefix}-ssh-bastion"
        }
    )
}

/****************************************************************************************************
*  Section : Create Key Pairs
*
*  Desc: This Section is used to create Key Pairs
*
*  URL: https://github.com/terraform-aws-modules/terraform-aws-key-pair
*
*  REVISIONS:
*       Ver         Date          Author                 Description
*    ---------   ----------   ---------------   ------------------------------------
*       1.0      28/03/2024    Kieron Garvey     1. Created key_pair Module
******************************************************************************************************/
# resource "tls_private_key" "this" {
#   algorithm = "RSA"
# }

module "key_pair" {
    source = "terraform-aws-modules/key-pair/aws"

    key_name           = "${local.prefix}-Key-Pair"    
    # public_key = trimspace(tls_private_key.this.public_key_openssh)
    create_private_key = true

    tags = merge(
        var.default_tags,
        {
            Key-Pair-Name = "${local.prefix}-Key-Pair"
        }
    )
}

/****************************************************************************************************
*  Note: Create Local Key Pair File in order to SSH
*
*  URL: https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
******************************************************************************************************/
resource "local_file" "key_pair" {
    content  = module.key_pair.private_key_pem
    filename = "${module.key_pair.key_pair_name}.pem"
    file_permission = 600
}


/****************************************************************************************************
*  Section : Create Auto Load Balancer
*
*  Desc: This Section is used to create the Load Balancer
*
*  URL: https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest
*
*  REVISIONS:
*       Ver         Date          Author                 Description
*    ---------   ----------   ---------------   ------------------------------------
*       1.0      28/03/2024    Kieron Garvey     1. Created ALB Module
******************************************************************************************************/
module "alb" {
    source = "terraform-aws-modules/alb/aws"

    name = "${local.prefix}-alb"
    load_balancer_type = "application"
    vpc_id = module.vpc.vpc_id
    subnets = module.vpc.public_subnets
    enable_deletion_protection = false
    create_security_group = false
    
    security_groups = [module.http_security_group.security_group_id, module.egress_security_group.security_group_id]

    tags = merge(
        var.default_tags,
        {
            ALB-Name = "${local.prefix}-alb"
        }
    )    
}

# ALB Target Group
resource "aws_lb_target_group" "tg-http" {
  name     = "kg-tg"
  port     = 80  
  protocol = "HTTP"
  target_type      = "instance"
  vpc_id   = module.vpc.vpc_id

  # health check
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 4
    interval            = 30    
    matcher             = "200-399"
  }
}

# ALB Listener
resource "aws_lb_listener" "ln-http" {
  load_balancer_arn = module.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-http.arn
  }
}

/****************************************************************************************************
*  Section : Create Bastion Host
*
*  Desc: This Section is used to create the Bastion Host
*
*  URL: https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest
*
*  REVISIONS:
*       Ver         Date          Author                 Description
*    ---------   ----------   ---------------   ------------------------------------
*       1.0      30/03/2024    Kieron Garvey     1. Created ALB Module
******************************************************************************************************/
module "bastion_host" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "${local.prefix}-bastion-host"
  ami                         = local.bastion_ami
  instance_type               = "t2.nano"
  key_name                    = module.key_pair.key_pair_name
  vpc_security_group_ids      = [module.ssh_security_group.security_group_id, module.egress_security_group.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  tags = merge(
    var.default_tags,
    {
        Bastion-Host-Name = "${local.prefix}-bastion-host"
    }
  )
}

/***************************************************************************************************
*  Section : Create Auto Scaling Group
*
*  Desc: This Section is used to create the Auto Scaling Group & related resources
*
* URL: https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest
*
*  REVISIONS:
*       Ver         Date          Author                 Description
*    ---------   ----------   ---------------   ------------------------------------
*       1.0      28/03/2024    Kieron Garvey     1. Created ASG Module
******************************************************************************************************/
module "auto_scaling_group" {
    source = "terraform-aws-modules/autoscaling/aws"

    name = "${local.prefix}-asg"
    min_size = 1
    max_size = 3
    desired_capacity = 1
    vpc_zone_identifier = module.vpc.private_subnets

    target_group_arns = [aws_lb_target_group.tg-http.arn]
    
    health_check_type = "ELB"
    health_check_grace_period = 30

    # Launch template
    launch_template_name        = "${local.prefix}-Launch-Template"
    launch_template_description = "Launch template for RugbyClubPOI application"
    launch_template_version = "$Latest"

    security_groups = [
            module.http_security_group.security_group_id, 
            module.ssh_bastion_security_group.security_group_id,
            module.egress_security_group.security_group_id
        ]

    image_id      = local.app_ami
    instance_type = "t2.nano"
    user_data                   = base64encode(local.user_data)
    key_name = module.key_pair.key_pair_name
    enable_monitoring = true
    
    create_iam_instance_profile = false
    iam_instance_profile_arn    = local.roles.instance_profile_arn

    # Tags
    tags = merge(
        var.default_tags,
        {
            ASG-Name = "${local.prefix}-asg"
        }
    )
}

# scale up policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${local.prefix}-asg-scale-up"
  autoscaling_group_name = module.auto_scaling_group.autoscaling_group_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1" #increasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale down policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${local.prefix}-asg-scale-down"
  autoscaling_group_name = module.auto_scaling_group.autoscaling_group_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

/***************************************************************************************************
*  Section : Create CloudWatch Alarms
*
*  Desc: This Section is used to create the CloudWatch Alarms. Alarm will trigger the ASG policy 
*        (scale/down) based on the metric (CPUUtilization), comparison_operator, threshold.
*
* URL: https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest
*
*  REVISIONS:
*       Ver         Date          Author                 Description
*    ---------   ----------   ---------------   ------------------------------------
*       1.0      28/03/2024    Kieron Garvey     1. Created ASG Module
******************************************************************************************************/
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "${local.prefix}-high-cpu-alarm"
  alarm_description   = "Monitors CPU utilization on the EC2 instances and triggers the ASG policy to scale up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  datapoints_to_alarm = 4
  dimensions = {
    "AutoScalingGroupName" = module.auto_scaling_group.autoscaling_group_name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up.arn]
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "${local.prefix}-low-cpu-alarm"
  alarm_description   = "Monitors CPU utilization on the EC2 instances and triggers the ASG policy to scale down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 25
  datapoints_to_alarm = 4
  dimensions = {
    "AutoScalingGroupName" = module.auto_scaling_group.autoscaling_group_name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down.arn]
}