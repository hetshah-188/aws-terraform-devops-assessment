# AWS DevOps Infrastructure Assessment

## Project Overview

This project demonstrates AWS infrastructure provisioning using Terraform, with GitHub Actions for continuous integration and validation. The application is hosted on private EC2 instances behind an internet-facing Application Load Balancer with HTTPS enabled.

**Live Application:** https://devops.life4u.me  
**AWS Region:** Asia Pacific (Mumbai) — `ap-south-1`

## Technology Stack

- **Cloud:** AWS
- **Infrastructure as Code:** Terraform
- **CI:** GitHub Actions
- **Networking:** VPC, public and private subnets, Internet Gateway, NAT Gateway, route tables
- **Compute:** EC2 Launch Template and Auto Scaling Group
- **Load Balancing:** Application Load Balancer
- **TLS:** AWS Certificate Manager (ACM)
- **Database:** Amazon RDS for MySQL
- **Secrets:** AWS Secrets Manager
- **Storage and Logs:** Amazon S3
- **Web Server:** Nginx

## Architecture

1. Users access the application through the public Application Load Balancer.
2. HTTP traffic is redirected to HTTPS using an ACM certificate.
3. The ALB forwards HTTP traffic to Nginx on EC2 instances in private application subnets.
4. An Auto Scaling Group manages the EC2 instances and uses load balancer health checks.
5. RDS MySQL is deployed in private database subnets and is not publicly accessible.
6. Database credentials are stored in AWS Secrets Manager.
7. S3 provides application storage and a destination for ALB access logs.
8. Terraform defines the infrastructure, while GitHub Actions checks formatting and validates the Terraform configuration.

## Security Features

- Separate public, application-private, and database-private subnets.
- Security groups restrict application traffic to the ALB and database traffic to the application security group.
- HTTPS termination at the ALB.
- Private RDS deployment with storage encryption enabled.
- S3 public access blocks and server-side encryption.
- An EC2 IAM role with scoped permission to retrieve the database secret.

## Repository Structure

```text
aws-terraform-devops-assessment/
├── .github/
│   └── workflows/
│       └── terraform.yml
├── app/
│   └── index.html
├── docs/
│   └── architecture.md
├── terraform/
│   ├── provider.tf
│   ├── main.tf
│   ├── nat.tf
│   ├── security_groups.tf
│   ├── compute.tf
│   ├── alb.tf
│   ├── acm.tf
│   ├── database.tf
│   ├── iam.tf
│   └── s3.tf
├── .gitignore
└── README.md
```

## CI Workflow

The GitHub Actions workflow runs on relevant pushes and pull requests to the main branch, and can also be triggered manually.

It performs:
- Terraform formatting checks.
- Terraform initialization without configuring a remote backend.
- Terraform configuration validation.

**Note:** This workflow validates Terraform; it does not automatically apply or deploy infrastructure. Infrastructure provisioning is performed separately using Terraform.

## Deployment Verification

The following checks were completed in AWS:

- Application URL loads over HTTPS.
- HTTP redirects to HTTPS.
- ALB target group reports one healthy target.
- Auto Scaling Group is at its desired capacity.
- RDS MySQL is available and not publicly accessible.
- S3 storage and ALB log buckets exist.
- GitHub Actions CI checks completed successfully.

## Limitations and Future Improvements

- Connect the demo application to RDS if database functionality is required.
- Implement an automated deployment workflow with securely configured AWS authentication, such as GitHub Actions OIDC.
- Consider a remote Terraform backend with state locking and encryption.
- Consider multi-AZ NAT Gateway deployment for improved availability.
- Add application monitoring, alerting, and automated tests.

## Cost and Cleanup

AWS resources such as NAT Gateways, load balancers, RDS instances, and public IPv4 addresses may incur charges.

After assessment and evidence collection, review the Terraform state and remove resources that are no longer required. Never commit Terraform state files, database passwords, AWS credentials, or other secrets to Git.
