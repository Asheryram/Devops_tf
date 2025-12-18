# Terraform Project Assignment: 3-Tier Architecture Using Modules

## Project Duration: 1 week
## Difficulty Level: Intermediate

## 1. Project Overview

In this project, you will design and deploy a complete **3-Tier AWS Architecture** using **Terraform modules**. The architecture must include modular components for networking, compute, load balancing, and database layers.

### Architecture Layers
1. **Presentation Layer (Tier 1)**
   - Public Subnets
   - Application Load Balancer (ALB)

2. **Application Layer (Tier 2)**
   - Private Subnets
   - EC2 Auto Scaling Group (ASG) OR one EC2 instance

3. **Data Layer (Tier 3)**
   - Private DB Subnets
   - RDS MySQL/PostgreSQL database instance

You must create your own Terraform modules (no registry modules).

## 2. Required Architecture Diagram

```
                         ┌─────────────────────────────┐
                         │     Application Load        │
                         │        Balancer (ALB)       │
                         └──────────────┬──────────────┘
                                        │
               ┌────────────────────────────────────────────────┐
               │                                                │
        Public Subnet A                                  Public Subnet B
               │                                                │
               ▼                                                ▼
        ┌─────────────┐                                  ┌─────────────┐
        │  Web/App    │                                  │  Web/App    │
        │   EC2/ASG   │                                  │   EC2/ASG   │
        └─────────────┘                                  └─────────────┘
               ▼                                                ▼
        ┌────────────────────────────────────────────────────────────────┐
        │                        RDS MySQL/PostgreSQL DB                 │
        │                      (Private DB Subnets)                      │
        └────────────────────────────────────────────────────────────────┘
```

## 3. Project Requirements

### A. Folder Structure

```
3tier-project/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alb/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── database/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```

## 4. Module Requirements

### Module 1: VPC
Must include:
- VPC
- 2 Public Subnets
- 2 Private App Subnets
- 2 Private DB Subnets
- Internet Gateway
- NAT Gateway
- Route Tables

Outputs:
- VPC ID
- Subnets per tier
- Route table IDs

### Module 2: Security
Must include:
- 3 Security Groups (Web, App, and DB)
- Ingress Rules for Allowed Traffic Per Tier

Outputs:
- Security Group IDs

### Module 3: ALB
Must include:
- ALB
- Listener (HTTP 80 or HTTPS 443)
- Target Group
- Target attachments
- Reference Web Security Group

Outputs:
- ALB DNS name
- Target group ARN

### Module 4: Compute Layer
Choose one:

**Option A (Preferred)**  
- Auto Scaling Group  
- Launch Template  
- Reference APP Security Groups  

**Option B (Beginner)**  
- Two EC2 instances in private subnets  

AMI must come from a data source:
Example:

```
data "aws_ssm_parameter" "amzn2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
```

Outputs:
- Instance IDs or ASG name
- Launch template ID

### Module 4: RDS Layer

Must include:
- RDS instance
- DB subnet group
- DB security group

Outputs:
- RDS endpoint
- Port

## 5. Project Constraints

- No hardcoding inside modules
- All configurations parameterized
- Modules must be reusable
- Use tagging convention:

Example
```
Environment = "dev"
Project     = "3tier-iac"
Owner       = "<your_name>"
```

## 6. Root Module Outputs

```
output "alb_dns" {
  value = module.alb.alb_dns
}

output "rds_endpoint" {
  value = module.db.address
}

output "asg_name" {
  value = module.compute.asg_name
}
```

## 7. Deliverables

### 1. GitHub Repository
Containing all Terraform module code.

### 2. README.md
Including:
- Architecture explanation
- Deployment instructions
- Module descriptions
- Variables and outputs

### 3. Architecture Diagram (Use Lucidchart, Draw.io, or Digram tool of your choice)

### 4. Screenshots
- ALB
- A screenshot of a successful ICMP (ping) response from the ALB target or a bastion connected to an application server.
- EC2/ASG
- RDS
- VPC/Subnets
- Output from `terraform apply`

## Hints:
- For a Bastion connection, you need a jump server in the presentation layer
- Ensure that both the web security group and app security group include an ingress rule that allows ICMP traffic from the appropriate source