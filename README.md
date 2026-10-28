# AWS Three-Tier Infrastructure with Terraform

A learning project that provisions an AWS VPC with public and private subnets, public and internal Application Load Balancers, a NAT Gateway, four EC2 instances, and an IAM instance profile for Systems Manager Session Manager.

## Architecture & Technology Stack

```
[ Internet / Clients ]
          |
[ Public ALB (HTTP:80) ]
          |
   [ Public Subnet ] ------> Public EC2 (Test Web Server)
          |
  [ Frontend Subnet ] ----> Frontend EC2 (Nginx Reverse Proxy)
          |
[ Internal ALB (HTTP:80) ]
          |
  [ Backend Subnet ] -----> Backend EC2 (Python Flask REST API on Port 8080)
          |
 [ Database Subnet ] ----> Database EC2 (MariaDB/MySQL Database Server)
```

- **Frontend Tier:** Nginx web server configured as a reverse proxy, serving web requests and routing `/api` traffic through the internal ALB.
- **Backend Tier:** Python Flask REST application listening on port `8080`, connected to the database tier.
- **Database Tier:** MariaDB/MySQL server isolated in a private database subnet.
- **Load Balancing:** Public ALB for external access to the frontend, and Internal ALB for internal traffic between frontend and backend.
- **Networking & Outbound Access:** Public and private subnets across two Availability Zones with a NAT Gateway providing secure outbound internet access for private instances.
- **Management:** Systems Manager Session Manager (SSM) support via attached IAM instance profile.

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

Review the execution plan before approving `terraform apply`.

## Test

After deployment, retrieve the public load balancer URL:

```bash
terraform output frontend_application_url
```

1. **Frontend Test:** Open the output URL in a browser. You should see the response from the **Nginx Frontend Server**.
2. **Backend & Database Test:** Append `/api` to the URL (e.g., `http://<ALB-DNS>/api`) to verify that Nginx proxies the request through the internal ALB to your Flask backend.

For SSM access to your EC2 instances, navigate to **AWS Systems Manager → Fleet Manager → Managed nodes** in the AWS Console.

## Clone Repository

Clone this repository using:

```bash
git clone https://github.com/manojkumarsahoo-dev/aws-three-tier-terraform.git
cd aws-three-tier-terraform
terraform init
terraform validate
terraform plan
```

## Important Notes

- **Learning Environment:** Designed for learning and architectural demonstration.
- **Cost Warning:** NAT Gateways and Application Load Balancers incur hourly AWS charges. Run `terraform destroy` when done to clean up resources and prevent unwanted charges.
- **Security:** Do not commit AWS credentials, `.tfstate` files, or private keys to source control.
- **AWS Provider:** Provider constraint is set to `> 6.65.0`.
