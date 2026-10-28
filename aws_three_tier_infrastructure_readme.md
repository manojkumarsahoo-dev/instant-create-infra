# AWS Three-Tier Infrastructure with Terraform

A learning project that provisions an AWS VPC with public and private subnets, public and internal Application Load Balancers, one NAT Gateway, four EC2 instances, and an IAM instance profile for Systems Manager Session Manager.

## Architecture

```
[ Internet ]
      |
[ Public ALB ]
      |
[ Public Subnet ] ----> Public EC2 Test Web Server
      |
[ Frontend Subnet ] --> Frontend EC2 (Python/Nginx HTTP Server)
      |
 [ Internal ALB ] ----> Routes /api traffic
      |
[ Backend Subnet ] ---> Backend EC2 (Python App listening on Port 8080)
      |
[ Database Subnet ] -> Database EC2 Placeholder (Isolated Data Tier)
```

- **1 Public EC2 test web server**
- **1 Private Frontend EC2 instance**
- **1 Private Backend EC2 instance** listening on TCP 8080
- **1 Private Database placeholder EC2 instance** (MySQL is not installed)
- **Public ALB** forwarding HTTP traffic to the frontend
- **Internal ALB** forwarding HTTP traffic to the backend on port 8080
- **Two subnets per tier** across two Availability Zones, ready for Auto Scaling Groups (ASGs)
- **One NAT Gateway** and a shared private route table for outbound internet access from private subnets
- **EC2 IAM Role** with `AmazonSSMManagedInstanceCore` attached through an instance profile for Systems Manager access

## Requirements

- Terraform installed
- AWS CLI installed and configured
- AWS permissions to create VPC, EC2, IAM, Elastic IP, NAT Gateway, Security Groups, and Load Balancers

## Deploy

From this directory:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply
```

Review the plan before approving `terraform apply`.

## Test

After apply completes, retrieve the public application URL:

```bash
terraform output frontend_application_url
```

1. Open the output URL in a browser. You should see the response from the **Frontend EC2 server**.
2. Append `/api` to the URL (e.g., `http://<ALB-DNS>/api`) to test backend forwarding through the Internal ALB. You should see:
   `Backend EC2 server is running`

For SSM access, navigate to **AWS Systems Manager → Fleet Manager → Managed nodes** in the AWS Console.

## Clone Later

After pushing this project to your repository, clone it with:

```bash
git clone https://github.com/manojkumarsahoo-dev/aws-three-tier-terraform.git
cd aws-three-tier-terraform
terraform init
terraform validate
terraform plan
```

## Important Notes

- **Learning Lab:** This is an architecture template designed for testing and learning, not a production-ready environment.
- **Cost Warning:** NAT Gateways and Application Load Balancers incur hourly AWS charges. Run `terraform destroy` when you are done to avoid unexpected costs.
- **Database Tier:** The database instance is an EC2 placeholder. No database software is installed yet.
- **Single NAT Gateway:** A single NAT Gateway is used for cost reduction during testing, creating a single point of failure for outbound traffic.
- **Security:** Never commit AWS credentials, `.tfstate` files, or SSH keys to version control.
- **AWS Provider:** The AWS provider constraint is set to `< 6.65.0`.