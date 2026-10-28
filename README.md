# AWS Three-Tier Infrastructure with Terraform

A learning project that provisions an AWS VPC with public and private subnets, public and internal Application Load Balancers, one NAT Gateway, four EC2 instances, and an IAM instance profile for Systems Manager Session Manager.

## Architecture

- 1 public EC2 test web server
- 1 private frontend EC2 instance
- 1 private backend EC2 instance listening on TCP 8080
- 1 private database placeholder EC2 instance (MySQL is not installed)
- Public ALB forwarding HTTP to the frontend
- Internal ALB forwarding HTTP to the backend on port 8080
- Two subnets per tier across two Availability Zones, ready to be used when building ASGs later
- One NAT Gateway and a shared private route table for outbound internet access from private subnets
- EC2 IAM role with `AmazonSSMManagedInstanceCore`, attached through an instance profile

## Requirements

- Terraform installed
- AWS CLI installed and configured, or another supported AWS credential method
- AWS permissions to create VPC, EC2, IAM, Elastic IP, NAT Gateway, security groups, and load balancers

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

After apply, retrieve the public application URL:

```bash
terraform output frontend_application_url
```

Open the URL in a browser. To test backend forwarding, append `/api` to the URL.

For SSM access, open AWS Systems Manager → Fleet Manager → Managed nodes. Instances need a running SSM Agent and network access to Systems Manager endpoints. The private instances use the NAT Gateway for outbound connectivity.

## Clone later

After pushing this project to a GitHub repository, clone it with:

```bash
git clone https://github.com/YOUR-GITHUB-USERNAME/YOUR-REPOSITORY.git
cd YOUR-REPOSITORY
terraform init
terraform validate
terraform plan
```

Replace the example repository URL with your own.

## Important notes

- This is a learning lab, not a production-ready architecture.
- A NAT Gateway and load balancers incur charges while provisioned. Review AWS pricing and destroy resources when finished if you no longer need them.
- The database EC2 instance is only a placeholder; it does not run MySQL or provide a real database service.
- The single NAT Gateway is a potential availability bottleneck.
- The current configuration creates standalone EC2 instances, not Auto Scaling Groups. The paired subnets are available for the future ASG exercise.
- Do not commit AWS access keys, private keys, Terraform state, or secrets to GitHub.
- The AWS provider constraint is `< 6.65.0`, matching this project's requested constraint.
