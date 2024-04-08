# Define input variables here

locals {
    prefix = "kg"
    email = "96358157@mail.wit.ie"
    region           = "us-east-1"
    app_ami      = "ami-01141e746aa544571"
    bastion_ami  = "ami-00b7d1af43d11cb91" 
    instance_type = "t3.nano"   
    
    user_data = <<-EOF
      #!/bin/bash
      TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 
      INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
      AWS_REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')
      AVAILABILITY_ZONE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
              
      sed -i "15i <strong>InstanceID =</strong> $INSTANCE_ID\n<br><strong>AWS_REGION =</strong> $AWS_REGION\n<br><strong>AVAILABILITY_ZONE =</strong> $AVAILABILITY_ZONE " /home/ec2-user/Rugby-Club-POI/src/views/about-view.hbs
      EOF
  
  iam_roles = {
    role_arn             = "arn:aws:iam::650210063090:role/LabRole"
    instance_profile_arn = "arn:aws:iam::650210063090:instance-profile/LabInstanceProfile"
  }
}

variable "default_tags" {
  default = {
    Student = "Kieron Garvey"
    Assignment = "DevOPS Assignment 2"
    StudentID = "96358157"
    Email = "96358157@mail.wit.ie"
    DeployedWith = "Terraform"
    Terraform = "true"
    Environment = "dev"
  }
  type = map(string)
}


