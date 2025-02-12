# ECS Infrastructure with Terraform

This project implements a multi-environment AWS infrastructure using Terraform, featuring ECS Fargate services with service discovery, application load balancing, and secure networking.

## Project Structure

```
.
├── environments/
│   ├── dev/           # Development environment configuration
│   └── prod/          # Production environment configuration
├── modules/
│   ├── networking/    # VPC, subnets, and routing configuration
│   ├── middleware/    # ALB and Route53 configuration
│   └── app/          # ECS cluster, tasks, and services
└── versions.tf       # Terraform and provider versions
```

## Modules

### Networking Module
- VPC with public and private subnets across multiple AZs
- Internet Gateway for public subnets
- NAT Gateway for private subnet internet access
- Route tables for public and private subnet routing

### Middleware Module
- Application Load Balancer (ALB) with HTTP/HTTPS listeners
- ACM certificate integration for HTTPS
- Route53 DNS record (terraform.patrone.click)
- Security groups for ALB access

### App Module
- ECS Fargate cluster with two services:
  - Public service (tf-svc1) integrated with ALB
  - Private service (tf-svc2) in private subnets
- Service Connect enabled for service discovery
- CloudWatch logging
- ECS Exec enabled for both services
- IAM roles and policies for task execution and runtime

## Features

- Multi-environment support (dev/prod)
- Secure networking with public/private subnets
- HTTPS termination with ACM certificates
- Service discovery using ECS Service Connect
- Container logging to CloudWatch
- Task debugging with ECS Exec
- Load balancing with health checks
- Automated DNS configuration

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0.0
- AWS provider >= 4.0.0
- Valid ACM certificate for patrone.click
- Route53 hosted zone for patrone.click

## Usage

1. Navigate to the desired environment directory:
   ```bash
   cd environments/dev  # or environments/prod
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Infrastructure Details

### Networking
- Dev VPC CIDR: 10.0.0.0/16
- Prod VPC CIDR: 10.1.0.0/16
- Dev AZs: us-east-1a, us-east-1b
- Prod AZs: us-east-1a, us-east-1b, us-east-1c

### Container Configuration
- Image: ubuntu/nginx
- Memory: 4GB
- vCPUs: 2
- Port: 80

### Service Discovery
- Namespace: tf-ns
- Service Names: tf-svc1, tf-svc2
- Internal DNS resolution enabled

### Security
- ALB with HTTPS termination
- Private tasks in isolated subnets
- Separate security groups for ALB and tasks
- IAM roles following least privilege principle