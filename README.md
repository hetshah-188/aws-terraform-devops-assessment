# AWS DevOps Assessment — Terraform Infrastructure & CI/CD

## Project Overview

This project demonstrates Infrastructure as Code (IaC) using Terraform to provision a secure, scalable AWS environment. GitHub Actions automatically checks Terraform formatting and configuration validity whenever relevant changes are pushed or pull requests are opened.

**Project status:** CI pipeline verified. AWS infrastructure deployment and end-to-end application testing are pending.

## Technology Stack

- **Cloud:** Amazon Web Services (AWS)
- **Infrastructure as Code:** Terraform
- **CI/CD:** GitHub Actions
- **Compute:** Amazon EC2, Launch Template, Auto Scaling Group
- **Networking:** Amazon VPC, public/private subnets, Internet Gateway, NAT Gateway
- **Load balancing:** Application Load Balancer (ALB)
- **TLS:** AWS Certificate Manager (ACM)
- **Database:** Amazon RDS for MySQL
- **Secrets:** AWS Secrets Manager
- **Storage and logs:** Amazon S3
- **Access control:** AWS IAM and security groups

## Architecture

1. A custom VPC contains public, private application, and private database subnets across two Availability Zones.
2. The Internet Gateway provides internet connectivity to public resources.
3. The Application Load Balancer receives HTTP/HTTPS traffic in the public subnets.
4. HTTP requests are redirected to HTTPS using an ACM certificate.
5. The Auto Scaling Group manages EC2 application instances in private subnets.
6. The private MySQL database is hosted on Amazon RDS.
7. Secrets Manager stores database credentials, with an IAM role granting the EC2 instances permission to read the designated secret.
8. Amazon S3 provides private application storage and a destination for ALB access logs.
9. GitHub Actions checks Terraform formatting, initialization, and configuration validity.

## CI Pipeline

**Code change → GitHub push or pull request → GitHub Actions → Terraform format check → Terraform initialization → Terraform validation**

The current workflow validates configuration only. It does not apply Terraform or deploy AWS infrastructure.

## Security Measures

- Private application and database subnets.
- HTTPS listener with ACM certificate.
- HTTP-to-HTTPS redirection.
- Security groups restrict database access to the application tier.
- S3 public access is blocked and server-side encryption is enabled.
- EC2 IAM permissions follow the least-privilege principle.
- Terraform state and `.tfvars` files are excluded from Git.

## Repository Structure

```text
aws-terraform-devops-assessment/
├── .github/
│   └── workflows/
│       └── terraform.yml
├── app/
│   └── index.html
├── docs/
├── terraform/
│   ├── main.tf
│   ├── provider.tf
│   ├── security_groups.tf
│   ├── nat.tf
│   ├── compute.tf
│   ├── alb.tf
│   ├── database.tf
│   ├── acm.tf
│   ├── iam.tf
│   └── s3.tf
├── .gitignore
└── README.md
```

## Deployment and Verification

Before considering this project complete:

- Review the final Terraform plan.
- Provision the infrastructure only after reviewing expected AWS charges.
- Configure DNS for `devops.life4u.me` to point to the ALB without modifying unrelated root-domain records.
- Verify HTTPS, ALB target health, application access, database networking, and S3 access logs.
- Record deployment outputs and add screenshots of successful tests.

**Application URL:** `https://devops.life4u.me` — pending deployment and verification.

## Cost and Cleanup

Resources such as NAT Gateway, ALB, EC2, RDS, and S3 may incur charges. Review AWS pricing and your account's Free Tier or credit eligibility before deployment. After the assessment, remove resources only after confirming that any required data has been backed up. Terraform state contains sensitive infrastructure details and must not be committed to Git.

## Learning Outcomes

- Defining AWS infrastructure using Terraform.
- Configuring public and private networking.
- Implementing security groups and IAM roles.
- Setting up ALB, ACM, Auto Scaling, RDS, and S3.
- Automating Terraform checks with GitHub Actions.
- Documenting infrastructure architecture and validation steps.
