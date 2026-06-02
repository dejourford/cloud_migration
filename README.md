# Cloud Migration

## Objective
This project simulates migrating a company's legacy applications and databases to AWS (Amazon Web Services). The goal is to modernize the infrastructure, improve security, and build a system capable of scaling with demand.

The migration involves provisioning a virtual server (EC2), installing a LAMP stack (Linux, Apache, MySQL, PHP), and deploying WordPress as the web platform.

## Architecture
- **Cloud Provider:** AWS
- **Compute:** EC2 (t3.micro)
- **Web Server:** Apache
- **Database:** MySQL
- **Language:** PHP
- **Platform:** WordPress
- **Infrastructure as Code:** Terraform

## Procedure

1. Provisioned AWS infrastructure using Terraform
![Terraform Apply](screenshots/terraform_apply.png)

2. SSH'd into EC2 instance
![SSH Connection](screenshots/ssh_ec2.png)

3. Installed and configured Apache web server
![Apache Default Page](screenshots/apache_default.png)

4. Installed and secured MySQL
![MySQL Status](screenshots/mysql_status.png)

5. Installed PHP and required extensions

6. Deployed WordPress
![WordPress Install](screenshots/wordpress_install.png)

7. Confirmed WordPress site live
![WordPress Live](screenshots/wordpress_live.png)

## Results
![WordPress Site](screenshots/index_page.png)

Successfully deployed a fully functional WordPress site on AWS. The LAMP stack (Linux, Apache, MySQL, PHP) was configured on an EC2 instance provisioned with Terraform, and WordPress was accessible via the public IP over HTTP.


## Lessons Learned
*To be completed.*
