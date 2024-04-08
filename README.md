<a name="readme-top"></a>


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/ki321g/DevOPS-Assignment-2">
    <img src="images/aws_logo.png" alt="Logo" width="200" height="125">
  </a>

  <h3 align="center">DevOPS Assignment #2</h3>

  <p align="center">
    The objective of my second DevOPS assignment is to demonstrate the deployment and automated management of a load-balanced auto-scaling web application in an AWS Academy account.
    <br /><br />
    <a href="https://github.com/ki321g/DevOPS-Assignment-2">View Demo</a>
    ·
    <a href="https://github.com/ki321g/DevOPS-Assignment-2/issues">Report Bug</a>
    ·
    <a href="https://github.com/ki321g/DevOPS-Assignment-2/issues">Request Feature</a>
  </p>
</div>

<!-- ABOUT THE PROJECT -->
## About The Project

The diagram below illustrates the infrastructure and services created for this assignment. The system comprises a Virtual Private Cloud (VPC) spanning three availability zones, each with private and public subnets.

Within the private subnets, application instance scaling is managed by an auto-scaling group. These application instances are registered with a load balancer’s target group and made publicly accessible via the load balancer.

Throughout this report, we will provide detailed descriptions of all infrastructure and services used.
[![Product Name Screen Shot][product-screenshot]](https://example.com)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Core assignment specification
Your demonstration should include the following:
1. Creation and configuration of a “master” instance of a web application. You may choose any web application, ideally one that relies on a third party or backend service. Note: any backend services/databases chosen should require minimal resources, e.g. use of nano instances and small amounts of storage. At a minimum you should implement auto-scaling of the application server and discuss issues relating to the scaling of a backend if you don't implement one.
2. Creation of a custom AMI based on your master instance, to be used by EC2 auto-scaling within your VPC infrastructure.
3. Creation of a VPC with subnets into which your application will be deployed. Creation of suitable security groups.
4. Creation of an elastic load balancer. Creation of a launch template based on your custom AMI. Creation of an auto-scaling group based on your launch template and linked to your load balancer.
5. Configuration of dynamic scaling policies (using simple or step scaling) based on CloudWatch alarms to cause an increase in resources when required and also a decrease in resources when conditions return to normal. You must justify your choice of metric(s) in your report.
6. Generation of test traffic to the load balancer – e.g. using curl/wget or a web testing tool.
7. Show that the load is distributed across more than one web server – e.g. by viewing web server or other logs. Include screenshots and a brief explanation in your report.
8. Use of your own script to monitor custom metrics on your servers and push these to CloudWatch. For example this could be web server

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Additional functionality (at least one)
The above is the core assignment specification. In addition you are expected to explore one or more other tasks. The following are some examples of additional tasks:
* Use one or more security services.
Automate the basic specification, or part of it, using Python/boto.
* Install/Integrate a database on EC2 instance(s) in private subnet(s) with an App Frontend.
* Capture your configuration using your own customised Cloud Formation script
* Use AWS Lambda functions in your architecture solution.
* Implement a secure load balancer
* Scaling based on SQS

<p align="right">(<a href="#readme-top">back to top</a>)</p>


### Built With Terraform
<p align="center">
<img src="images/terraform.png" alt="Logo" width="360" height="100">
</p> 

Terraform is an open-source Infrastructure as Code (IaC) software tool created by HashiCorp. It allows developers to define and provision data center infrastructure using a declarative configuration language. This means you describe your desired state of infrastructure, and Terraform will figure out how to achieve that state.

With Terraform, you can manage a wide variety of service providers as well as custom in-house solutions. It has a pluggable architecture with providers to support a large number of infrastructure services such as AWS, Google Cloud, Azure, and many others.

Terraform keeps track of the current state of your infrastructure and applies incremental changes, making it efficient for versioning and collaboration. It also supports modules for creating reusable components, improving the maintainability and testability of your infrastructure code.

Terraform is widely used in DevOps practices for automating infrastructure setup and consistently replicating environments, making it a key tool in the realm of cloud automation and orchestration.



<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CONTACT -->
## Contact

Kieron Garvey

Project Link: [https://github.com/ki321g/DevOPS-Assignment-2](https://github.com/ki321g/DevOPS-Assignment-2)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Use this space to list resources you find helpful and would like to give credit to. I've included a few of my favorites to kick things off!

* [Terraform Modules](https://registry.terraform.io/search/modules?namespace=terraform-aws-modules)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
[product-screenshot]: images/screenshot.png