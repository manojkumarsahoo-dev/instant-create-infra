# AWS Three-Tier Infrastructure with Terraform

A production-style AWS 3-tier web architecture provisioned using Terraform. This setup configures a dedicated Amazon VPC with public and private subnets, dual Application Load Balancers (Public and Internal), Nginx reverse proxying on the frontend, a Python Flask API on the backend, and a MariaDB/MySQL database tier—all managed safely with AWS Systems Manager (SSM) Session Manager.

---

> 📌 **IMPORTANT REMINDER: PLACEHOLDER REPLACEMENT**
>
> The infrastructure is provisioned with basic test scripts. Before deploying to production or completing your stack, **you must replace the user_data scripts in Terraform**:
>
> 1. **Frontend Server (`aws_instance.frontend_1`):** Replace the basic Python server with **Nginx** configured as a reverse proxy forwarding `/api` requests to the internal ALB (`aws_lb.internal`).
> 2. **Backend Server (`aws_instance.backend_1`):** Replace the placeholder script with a real application (e.g., **Python Flask** listening on port `8080`) that connects to the database.
> 3. **Database Server (`aws_instance.database_1`):** Replace the empty placeholder instance by installing **MariaDB / MySQL** on port `3306` and creating the application database/users.

---

## 🏗️ Architecture Overview

```
[ Internet / Clients ]
          │
          ▼
┌────────────────────────────────────────────────────────┐
│               Public ALB (Port 80)                     │
└─────────────────────────┬──────────────────────────────┘
                          │
                          ▼
┌────────────────────────────────────────────────────────┐
│ Frontend Tier (Nginx Web Server / Reverse Proxy)       │
│ • Subnet: Public / Private Frontend Subnet             │
│ • Listens on Port 80                                  │
│ • Forwards /api traffic to Internal ALB               │
└─────────────────────────┬──────────────────────────────┘
                          │
                          ▼
┌────────────────────────────────────────────────────────┐
│               Internal ALB (Port 80)                   │
└─────────────────────────┬──────────────────────────────┘
                          │
                          ▼
┌────────────────────────────────────────────────────────┐
│ Backend Tier (Python Flask Web API)                   │
│ • Subnet: Private Backend Subnet                       │
│ • Listens on TCP Port 8080                             │
│ • Connects to MariaDB Database on TCP Port 3306        │
└─────────────────────────┬──────────────────────────────┘
                          │
                          ▼
┌────────────────────────────────────────────────────────┐
│ Database Tier (MariaDB / MySQL Database Server)        │
│ • Subnet: Private Database Subnet                      │
│ • Listens on TCP Port 3306                             │
└─────────────────────────┬──────────────────────────────┘
```

## 🚀 Key Components & Tech Stack

1. **Frontend Tier (`frontend_1`):**
   * **Software:** Nginx
   * **Role:** Serves frontend landing pages and proxies `/api` endpoints directly to the internal Application Load Balancer (`aws_lb.internal`).

2. **Backend Tier (`backend_1`):**
   * **Software:** Python 3, Flask, PyMySQL
   * **Role:** Runs a RESTful API listening on **TCP Port 8080**, receiving requests from the internal ALB and communicating with the MySQL/MariaDB database server.

3. **Database Tier (`database_1`):**
   * **Software:** MariaDB 10.5 / MySQL
   * **Role:** Relational database server running on **TCP Port 3306**, accessible exclusively from the backend security group.

4. **Network & IAM Infrastructure:**
   * **Networking:** VPC across 2 Availability Zones with dedicated public, frontend, backend, and database subnets.
   * **Egress Traffic:** 1 NAT Gateway providing outbound internet access for private instances to download packages and system updates.
   * **Management & Security:** AWS Systems Manager (SSM) Session Manager enabled on all EC2 instances via `AmazonSSMManagedInstanceCore` attached through an IAM instance profile (eliminating the need for open SSH ports).

## 🔐 Security Group Rules Summary

* **Public ALB SG:** Inbound HTTP (80) from `0.0.0.0/0`.
* **Frontend SG:** Inbound HTTP (80) from Public ALB SG.
* **Internal ALB SG:** Inbound HTTP (80) from Frontend SG.
* **Backend SG:** Inbound TCP (8080) from Internal ALB SG.
* **Database SG:** Inbound MySQL/MariaDB (3306) from Backend SG.

## 📋 Requirements

* [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.0+)
* [AWS CLI](https://aws.amazon.com/cli/) installed and configured with appropriate IAM privileges (VPC, EC2, IAM, EIP, NAT Gateway, Security Groups, ALB).
* AWS provider constraint: `< 6.65.0`.

## 🛠️ How to Deploy

1. Clone your repository locally:
   ```bash
   git clone https://github.com/manojkumarsahoo-dev/aws-three-tier-terraform.git
   cd aws-three-tier-terraform
   ```

2. Format, initialize, and validate the Terraform code:
   ```bash
   terraform fmt -recursive
   terraform init
   terraform validate
   ```

3. Review the execution plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration to provision the stack on AWS:
   ```bash
   terraform apply
   ```

## 🧪 Testing the Application

1. Retrieve your public application endpoint output from Terraform:
   ```bash
   terraform output frontend_application_url
   ```

2. **Frontend Check:** Open the output URL in your web browser. You should see the response served by the **Nginx** web server.
3. **Backend API Check:** Append `/api` to the URL in your browser (e.g., `http://<ALB-DNS-NAME>/api`). Nginx will proxy the request through the internal ALB down to the **Python Flask API** running on port 8080.
4. **SSM Access:** To manage or troubleshoot any instance, navigate to **AWS Systems Manager → Fleet Manager → Managed Nodes** to open an interactive session without SSH keys.

## ⚠️ Important Notes

* **Cost Notice:** NAT Gateways and Application Load Balancers incur hourly AWS charges while active. Run `terraform destroy` when you are done testing to tear down all resources.
* **Production Readiness:** This configuration uses standalone EC2 instances for learning purposes. For production high availability, replace single EC2 instances with **Auto Scaling Groups (ASGs)** spanning multiple Availability Zones.
* **Secrets Management:** Ensure sensitive database passwords and state files are never committed directly to public source control.
