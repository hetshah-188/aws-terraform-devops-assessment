
# AWS DevOps Assessment — Architecture

## Overview

The infrastructure is provisioned using Terraform in AWS Mumbai (`ap-south-1`).

## Architecture Diagram

```mermaid
flowchart TB
    U[Internet Users]
    DNS[devops.life4u.me]
    ALB[Application Load Balancer<br/>HTTPS :443<br/>HTTP to HTTPS Redirect]
    ACM[AWS Certificate Manager]
    ASG[EC2 Auto Scaling Group]
    EC2[EC2 Instances<br/>Private App Subnets<br/>Nginx]
    NAT[NAT Gateway]
    IGW[Internet Gateway]
    RDS[(RDS MySQL<br/>Private DB Subnets)]
    SM[AWS Secrets Manager]
    S3A[(S3 App Storage)]
    S3L[(S3 ALB Access Logs)]

    U --> DNS
    DNS --> ALB
    ACM -. TLS Certificate .-> ALB
    ALB --> EC2
    ASG -. Manages .-> EC2
    EC2 --> RDS
    EC2 -. Authorized secret access .-> SM
    EC2 --> S3A
    ALB -. Access Logs .-> S3L
    ALB --> IGW
    EC2 -. Outbound Internet .-> NAT
    NAT --> IGW
```

## Network Design

- One VPC with CIDR `10.0.0.0/16`.
- Two public subnets for internet-facing infrastructure.
- Two private application subnets for EC2 instances.
- Two private database subnets for RDS.
- Internet Gateway for public subnet connectivity.
- NAT Gateway for outbound connectivity from private application subnets.
- Security groups restrict application and database traffic.

## Request Flow

1. A user visits `https://devops.life4u.me`.
2. DNS directs the request to the Application Load Balancer.
3. The ALB terminates HTTPS using the ACM certificate.
4. The ALB forwards requests to healthy EC2 targets over HTTP.
5. Nginx serves the demo application from the private EC2 instances.

## Database and Storage

- RDS MySQL is configured as a private database.
- Database credentials are stored in AWS Secrets Manager.
- An EC2 IAM role permits access to the configured database secret.
- S3 buckets provide application storage and ALB access-log storage.

**Important:** The current demo page is static. The diagram shows configured infrastructure relationships and intended capabilities; it does not mean the demo application currently queries RDS or reads Secrets Manager credentials.

## CI Workflow

GitHub Actions performs Terraform formatting checks, initialization, and validation. Infrastructure provisioning is performed separately; the current workflow does not automatically run `terraform apply`.

## Verification

- HTTPS website accessible.
- HTTP redirects to HTTPS.
- ALB target group reports one healthy target.
- RDS is not publicly accessible.
- Terraform state tracks the main infrastructure resources.
