# Beginner's Guide: Build an AWS DevOps Project from Scratch



A practical, step-by-step tutorial for beginners learning AWS, Terraform, and DevOps.



**Project:** AWS Infrastructure Automation with Terraform and GitHub Actions  

**Difficulty:** Beginner to Intermediate  

**Cloud Region Used in This Example:** `ap-south-1` (Mumbai)



---



## 1. What Will You Build?



In this project, you will create a simple web application hosted on AWS using Infrastructure as Code (IaC).



Instead of manually creating every AWS resource through the console, you will use Terraform to define and manage your infrastructure.



### What the project includes



- A VPC with public and private subnets.

- An Internet Gateway and NAT Gateway.

- EC2 instances managed by an Auto Scaling Group.

- An Application Load Balancer (ALB).

- HTTPS using AWS Certificate Manager (ACM).

- A private Amazon RDS MySQL database.

- AWS Secrets Manager for database credentials.

- S3 buckets for application storage and ALB logs.

- IAM roles and security groups.

- GitHub Actions for Terraform formatting and validation.



**Important:** The demo website in this repository is a static page. The RDS database and Secrets Manager are provisioned as infrastructure but are not connected to the demo page's application logic.



## 2. Understand the Basic Concepts



Before starting, understand these services:



| Service | Purpose |
|---|---|
| AWS | Cloud platform used to run infrastructure |
| VPC | Private, isolated network in AWS |
| Subnet | A smaller network inside a VPC |
| EC2 | Virtual machine that runs the web server |
| Auto Scaling Group | Maintains the configured number of EC2 instances |
| ALB | Distributes incoming requests to application instances |
| ACM | Manages TLS certificates for HTTPS |
| RDS | Managed relational database |
| Secrets Manager | Stores sensitive values such as database credentials |
| S3 | Object storage |
| IAM | Controls permissions for users and AWS services |
| Terraform | Creates and manages infrastructure through configuration files |
| GitHub Actions | Runs automated workflows when repository events occur |



### How the request flows



1\. A visitor opens your website.

2\. DNS directs the request to the Application Load Balancer.

3\. The ALB handles HTTPS using an ACM certificate.

4\. The ALB forwards traffic to a healthy EC2 instance in a private application subnet.

5\. Nginx serves the web page.



The private RDS database is a separate component and is not queried by the current static demo page.



## 3. Prerequisites



You need:



- An AWS account with permission to create the required resources.

- A GitHub account.

- Git installed on your computer.

- Terraform installed.

- AWS CLI installed.

- A code editor such as Visual Studio Code or Notepad.

- A domain name if you want to configure your own public HTTPS URL.



Use an IAM identity with only the permissions required for this project. Do not use root-account access keys for routine CLI operations.



### Important cost warning



This project creates resources that may incur charges, including NAT Gateway, ALB, RDS, EC2, public IPv4 addresses, and storage.



Check AWS pricing and your available credits before deploying. Set up an AWS Budget alert, remembering that budget alerts are not hard spending limits.



For initial learning, you can first practise Terraform with small configurations and avoid applying the complete project until you understand the cost implications.



## 4. Install and Verify the Tools



Open Windows CMD and check the installations:



```cmd

git --version

terraform -version

aws --version

```



If a command is not recognized, install the corresponding tool and reopen CMD.



## 5. Configure AWS CLI



Configure an IAM identity for the AWS CLI using your organization's recommended authentication method. For a beginner environment using IAM user credentials, AWS CLI supports:



```cmd

aws configure

```



Enter the requested access key, secret key, default region (`ap-south-1`), and output format (`json`).



Never share your secret access key or commit credentials to GitHub.



Verify your identity:



```cmd

aws sts get-caller-identity --no-cli-pager

```



This command should return the AWS account and identity associated with your CLI session.



## 6. Get the Project Code



Clone the repository:



```cmd

git clone https://github.com/hetshah-188/aws-terraform-devops-assessment.git

cd aws-terraform-devops-assessment

```



Inspect the project structure:



```cmd

dir

dir terraform

dir .github\\workflows

```



Review the Terraform files before deploying anything.



## 7. Understand the Terraform Files



The `terraform` directory contains the infrastructure configuration.



| File | Responsibility |
|---|---|
| `provider.tf` | Terraform requirements and AWS provider configuration |
| `main.tf` | VPC, subnets, gateways, and route tables |
| `nat.tf` | NAT Gateway and private application routes |
| `security_groups.tf` | Network access rules |
| `compute.tf` | EC2 Launch Template and Auto Scaling Group |
| `alb.tf` | Load balancer, listeners, target group, and related settings |
| `acm.tf` | TLS certificate configuration |
| `database.tf` | RDS MySQL and database secret configuration |
| `iam.tf` | EC2 role and permissions |
| `s3.tf` | Application storage and ALB log buckets |



Read each file to understand the resources, dependencies, and configured values.



## 8. Customize the Configuration



Do not assume this repository can be deployed unchanged in every AWS account.



Before deploying:



1\. Choose your AWS region.

2\. Review resource names and tags.

3\. Configure your own domain if you want a custom URL.

4\. Update the ACM certificate configuration and DNS validation records for your domain.

5\. Check IAM permissions and security-group rules.

6\. Review instance types, database size, backup settings, and networking costs.

7\. Confirm that S3 bucket names are unique where required.



The current configuration uses `devops.life4u.me` and the Mumbai region. A learner using a different domain must update the relevant configuration and DNS records. The ACM certificate must be issued for the domain used by the ALB HTTPS listener.



## 9. Initialize Terraform



Move into the Terraform directory:



```cmd

cd terraform

```



Initialize Terraform:



```cmd

terraform init

```



Initialization downloads the required providers and prepares the working directory.



Format the configuration:



```cmd

terraform fmt -recursive

```



Validate the configuration:



```cmd

terraform validate

```



Formatting checks style. Validation checks the configuration's syntax and internal consistency; it does not guarantee that AWS permissions, quotas, or resource creation will succeed.



## 10. Review the Deployment Plan



Run:



```cmd

terraform plan

```



Read the proposed changes before continuing.



Terraform will show which resources it intends to create, change, or destroy.



**Do not blindly approve a plan.** Review the resource types and estimated operational impact, particularly NAT Gateways, load balancers, databases, and public IP addresses.



If Terraform reports an error, fix the underlying issue and run validation and planning again.



## 11. Deploy the Infrastructure



When the plan is understood and the costs and configuration are acceptable, run:



```cmd

terraform apply

```



Review the plan presented by Terraform and confirm the operation when prompted.



Wait for Terraform to finish. Some resources, such as RDS and load balancers, can take several minutes to become available.



If deployment fails, read the error carefully. A failure may be caused by missing IAM permissions, an unavailable resource name, a quota, invalid configuration, or a resource dependency.



Do not repeatedly apply changes without checking the existing Terraform state and AWS resources.



## 12. Verify the Deployment



### A. Check the Terraform state



```cmd

terraform state list

```



This lists the resources tracked by the current Terraform state. It does not independently prove that every service is healthy.



### B. Check the website



Open your configured application URL in a browser.



If using your own domain, verify that its DNS records point to the correct load balancer and that the ACM certificate is issued for the hostname.



### C. Check the ALB target group



In the AWS Console:



1\. Open EC2.

2\. Select Load Balancers.

3\. Open your application load balancer.

4\. Open its associated target group.

5\. Select the Targets tab.



Wait for the registered target to become `Healthy`.



If it is unhealthy, inspect the health-check path, target port, security groups, instance status, and web server logs.



### D. Check the database



In the RDS Console, verify that the database is available and that **Publicly accessible** is set to **No**.



The database security group should allow MySQL traffic only from the intended application security group.



## 13. Configure Git and GitHub



If you are creating a new repository rather than cloning this one, initialize Git in your project directory and create a GitHub repository.



For an existing cloned repository, inspect the current state:



```cmd

git status

git remote -v

```



After making safe documentation or configuration changes:



```cmd

git add README.md docs/architecture.md

git commit -m "Update project documentation"

git push origin main

```



Use the correct files for your changes. If the remote and local branches diverge, integrate the remote changes safely before pushing.



Never commit `.tfstate` files, database passwords, AWS access keys, secret values, or Terraform plan files containing sensitive information.



## 14. Understand the GitHub Actions Workflow



The repository includes a GitHub Actions workflow under:



`.github/workflows/terraform.yml`



The current workflow performs:



1\. Checkout of the repository.

2\. Terraform setup.

3\. Terraform formatting checks.

4\. Terraform initialization without configuring a remote backend.

5\. Terraform validation.



This is a **Continuous Integration (CI) validation workflow**. It does not automatically provision AWS infrastructure because it does not run `terraform apply`.



A future enhancement could introduce a controlled deployment workflow with secure AWS authentication, such as GitHub Actions OIDC, protected environments, and an appropriately configured Terraform backend.



Do not add long-lived AWS credentials directly to workflow files.



## 15. Troubleshooting Common Problems



### Terraform command is not recognized



Install Terraform and ensure its installation directory is included in the Windows PATH. Reopen CMD and check `terraform -version`.



### AWS credentials or permissions error



Run:



```cmd

aws sts get-caller-identity --no-cli-pager

```



If identity resolution fails, check your CLI authentication. If an AWS action is denied, review the exact missing permission and grant only the necessary access.



### ACM certificate remains pending validation



Confirm that the DNS validation CNAME record matches the values supplied by ACM and is published at your DNS provider.



### ALB target is unhealthy



Check that the EC2 instance is running, Nginx is serving the expected page, the health-check path is correct, and the application security group allows traffic from the ALB security group.



### Website cannot be reached



Check the DNS record, ALB listeners, certificate status, target health, route tables, and security groups.



### Terraform reports an existing resource



Check the AWS Console and Terraform state before making changes. Never import, replace, or delete a resource without understanding who manages it.



## 16. Clean Up the Resources



When the project is no longer needed, first save screenshots and confirm that the live URL is no longer required.



From the Terraform directory, inspect the current state and planned changes. If the state is complete and the environment is dedicated to this project, use:



```cmd

terraform plan -destroy

```



Review the proposed destruction carefully. If you are certain it is safe, run:



```cmd

terraform destroy

```



Confirm the operation when prompted.



Do not destroy shared resources or resources managed by another Terraform state. If the state is incomplete or resources were created outside Terraform, investigate and reconcile them first.



After cleanup, inspect the AWS Console for leftover resources and continue monitoring billing.



## 17. Suggested Learning Improvements



After completing the project, try these enhancements:



- Add CloudWatch monitoring and alarms.

- Add a remote Terraform backend with encryption and state locking.

- Implement secure GitHub Actions deployment with OIDC.

- Connect a real application to RDS using Secrets Manager.

- Add automated application tests.

- Explore multi-AZ resilience and the trade-offs of multiple NAT Gateways.

- Improve cost monitoring and cleanup automation.



## 18. Interview Questions for Beginners



**Why use Terraform?**  

Terraform allows infrastructure to be defined as code, reviewed, version-controlled, and recreated consistently.



**Why use private subnets for EC2?**  

Private application instances are not directly exposed to inbound internet traffic. Users access them through the ALB.



**Why use an ALB?**  

It distributes incoming requests to registered targets and supports health checks and HTTPS termination.



**What does an Auto Scaling Group do?**  

It maintains the configured number of EC2 instances and can replace unhealthy instances according to its configuration.



**Why is RDS private?**  

A private database reduces direct exposure and allows access to be restricted to trusted application resources.



**What is the difference between CI and CD?**  

CI checks and validates changes. CD automates delivery or deployment. This repository's current workflow performs CI validation; infrastructure provisioning is separate.



**What is Terraform state?**  

It records Terraform's mapping between configuration and managed resources. It may contain sensitive information and must be protected.



---



## Final Advice



Build the project in stages, understand each resource, review every Terraform plan, and verify the deployment before moving to the next step.



The purpose is not simply to make the website work. It is to understand how networking, compute, storage, security, automation, and cost management fit together in a real cloud environment.




