
## Infrastructure Setup Instructions

1. **Create Virtual Private Cloud (VPC) with the following requirements:**
    - Auto-create subnets should be disabled.
    - Routing mode should be set to regional.
    - No default routes should be created.

2. **Create subnets in VPC:**
    - There are 2 subnets in the VPC, the first one named `webapp` and the second one named `db`.
    - Each subnet has a /24 CIDR address range.
    - Add a route explicitly to `0.0.0.0/0` with the next hop to the Internet Gateway and attach it to your VPC.
