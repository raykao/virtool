# Terraform Infrastructure Provisioning

This script in its current form will stampdown your enivronment in Azure with the following resources:
- Resource Groups
    - core-virtool
    - web-virtool
    - api-virtool
    - job-virtool
    - mongo-virtool
    - admin
- Virtual Network
    - vnet-virtool
    - Subnets:
        - AzureFirewallSubnet
        - web
        - api
        - job
        - admin
        - mongo
- Public IP Prefixes
    - Sets a small range of static public IP address to use
    - Helps to have consistent range for security (consisten white-listing), scale and high availability POV
- Load Balancers
    - web
    - api
    - job
    - admin
- Private DNS
    - domain name: virtool.ca
- Azure Firewall
    - Application (HTTP/HTTPS) Rules (Allow specific web traffic out of the network)
        - Required Ubuntu Update FQDNs
        - Required Docker FQDNs
        - Required Virtool Specific FQDNs
            - Used
        - Required LetsEncrypt FQDNs
            - Used for obtaining SSL/TLS Certificates via LetsEncrypt
    - DNAT Rules (Whitelist specific inbound ports -> specific private IPs/subnets)
        - 80 (HTTP) -> Web LB
        - 443 (HTTPS) -> Web LB
        - 22 (SSH) -> Admin VM
    - Network Rules (Whitelist specific outbound ports/destinations for specific source IPs)
        - Admin Subnet -> (Any IP):(Any Port) Unrestricted Access outbound
- User Defined Route (UDR aka Route Table)
    - Forces traffic to internet via Firewall
    - Associated to all Subnets as the default route

```bash
terraform init
terraform plan -out tfplan
terraform apply --auto-approve tfplan
```