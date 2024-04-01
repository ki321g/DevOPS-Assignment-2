# Define input variables here

locals {
    prefix = "kg"
    region           = "us-east-1"
    app_ami      = "ami-003808981856dbc93"
    # app_ami      = "ami-008834ba05baadb91"
    bastion_ami  = "ami-00b7d1af43d11cb91" 
    instance_type = "t3.nano"   
    user_data     = <<EOT
        #!/bin/bash
        cd Rugby-Club-POI
        TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 
        curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id >> .env
        EOT

        #echo "INSTANCE_ID:" > .env
  #   user_data     = <<EOT
  #       #!/bin/bash
  #       echo "<b>Instance ID:</b> " > /var/www/html/id.html
  #       TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 
  #       curl -H "X-aws-ec2-metadata-token: $TOKEN"
  #       http://169.254.169.254/latest/meta-data/instance-id/ >> /var/www/html/id.html
  # EOT

  
  roles = {
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