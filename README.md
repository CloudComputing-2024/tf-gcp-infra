
## Infrastructure Setup Instructions

1. **Create Virtual Private Cloud (VPC) with the following requirements:**
    - Auto-create subnets should be disabled.
    - Routing mode should be set to regional.
    - No default routes should be created.

2. **Create subnets in VPC:**
    - There are 2 subnets in the VPC, the first one named `webapp` and the second one named `db`.
    - Each subnet has a /24 CIDR address range.
    - Add a route explicitly to `0.0.0.0/0` with the next hop to the Internet Gateway and attach it to your VPC.
   
3. **Set up firewall rules:**
   - Set up firewall rules for custom VPC/Subnet to allow traffic from internet to the port 8080 where the app listen
   - Do not allow SSH port 22 form the Internet

4. **Create an compute engine instance:**
   - Launch instance in custom VPC
   - Launch with custom image
   - Set Boot disk type to balanced
   - Set Boot size(GB): 10

5. **Create a CloudSQL Database within the CloudSQL instance:**
   - `name`: webapp
   - `instance`: Reference to the CloudSQL instance
   
6. **Create a CloudSQL Database User:**
   - `name`: webapp
   - `instance`: Reference to the CloudSQL instance
   - `password`: Randomly generated password
   - 
7. **Create a Service Account:**
   - `name`: csye6225
   - creates a project level IAM binding for Logging admin role
   - creates a project level IAM binding for Monitoring metrics writer role
   - assigns the service account to the compute instance
8. **Update Cloud DNS zone:**
   - `name`: Add or Update A record to the Cloud DNS zone so that your domain points to your VM instance and your web application is accessible at http://your-domain-name.tld:<port>/.
   - Your application must be accessible using root context i.e. http://your-domain-name.tld:<port>/ and not http://your-domain-name.tld:<port>/app-0.1/.



## Compute Engine Instance Setup
Launch a Compute Engine instance with a startup script that configures the web application's database connection using the CloudSQL instance details.

## Deployment
Run the following commands to deploy the infrastructure:
```bash
terraform init
terraform plan
terraform apply
   