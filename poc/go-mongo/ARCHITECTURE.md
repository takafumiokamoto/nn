# App Runner Architecture & Security Patterns

This document outlines the architectural patterns for securing AWS App Runner services, specifically focusing on the use case of connecting to a private database while restricting public access to specific IP ranges.

## Problem Statement

We need to deploy a Go application on **AWS App Runner** that meets two critical network requirements:
1.  **Backend Connectivity**: The app must connect to a **MongoDB (AWS DocumentDB)** cluster residing in a **Private Subnet** (no public IP).
2.  **Frontend Security**: The app must be accessible from the internet, but **restricted** to a specific set of allowed IP addresses (e.g., Office VPN, Home IP).

## Core Concepts

### 1. App Runner VPC Connector
App Runner services run in a secure, AWS-managed VPC isolated from your infrastructure. To access resources in your private subnets (like DocumentDB), we use a **VPC Connector**.
*   **Function**: It acts as a bridge, creating a network interface (ENI) inside your private subnet.
*   **Result**: Outbound traffic from your App Runner service appears as local traffic inside your VPC, allowing it to reach your private database.

### 2. Public vs. Private App Runner Services
*   **Public Service**: Has a public URL resolvable from the internet. Inbound traffic comes directly from the web.
*   **Private Service**: Has a URL that resolves to a private IP inside your VPC (via VPC Interface Endpoint). It is **not** reachable from the internet directly.

---

## Solution 1: Public Service + AWS WAF (Selected Strategy)

This is the implemented solution for this Proof of Concept (POC). It balances simplicity, cost, and security effectiveness.

### Architecture
1.  **Inbound (Security)**: The App Runner service is **Public**. Access is controlled by **AWS WAF (Web Application Firewall)** attached to the service.
2.  **Outbound (Database)**: The service uses a **VPC Connector** attached to the Private Subnets to reach DocumentDB.
3.  **Internal Loopback**: A **NAT Gateway** is deployed in the Public Subnet. If private resources need to talk to the App Runner URL, they go out via NAT. The NAT Gateway's Elastic IP is whitelisted in the WAF.

### Traffic Flow
*   **Authorized User**: `User (Allowed IP)` → `AWS WAF (Allow)` → `App Runner` → `VPC Connector` → `DocumentDB`
*   **Unauthorized User**: `Hacker (Random IP)` → `AWS WAF (Block 403)` → ❌ *App Runner is never touched*

### Pros & Cons
| Feature | Description |
| :--- | :--- |
| **Simplicity** | No Load Balancers or complex routing required. |
| **Cost** | WAF is generally cheaper than running an always-on ALB. |
| **Maintenance** | Managed rule sets; no OS/instance to patch. |
| **Limit** | Public endpoint exists (though blocked by WAF), which might not satisfy strict "dark site" compliance policies. |

---

## Solution 2: Private Service + ALB (Alternative Strategy)

This solution is "Strictly Private." The App Runner service itself has NO public presence.

### Architecture
1.  **App Runner**: Configured as a **Private Service**. It is only accessible via a **VPC Interface Endpoint** inside your VPC.
2.  **Ingress**: An **Internet-Facing Application Load Balancer (ALB)** is placed in the Public Subnet.
3.  **Security**: A **Security Group** on the ALB restricts inbound traffic to allowed CIDRs.
4.  **Routing**: The ALB forwards traffic to the private IP addresses of the App Runner Interface Endpoint.

### Traffic Flow
`User (Allowed IP)` → `ALB (Public Subnet)` → `App Runner Endpoint (Private Subnet)` → `App Runner Service`

### Pros & Cons
| Feature | Description |
| :--- | :--- |
| **Security** | "Air-gapped" from the public internet. Zero public footprint for the app itself. |
| **Flexibility** | ALB allows advanced routing, custom TLS policies, and integration with legacy VPC tools. |
| **Complexity** | Requires managing ALB, Target Groups, PrivateLink, and internal DNS. |
| **Cost** | Higher due to ALB hourly costs + Data Processing charges for VPC Endpoints. |

---

## Implementation Details

### Infrastructure (`infra.yaml`)
*   **Network**: VPC, Public/Private Subnets, NAT Gateway (for static outbound IP).
*   **Database**: AWS DocumentDB in private subnets, secured with a random password in **Secrets Manager**.
*   **Registry**: ECR Repository for the Docker image.

### Service (`service.yaml`)
*   **Compute**: App Runner Service connected to ECR.
*   **Connectivity**: `VpcConnector` enabled for database access.
*   **Security**: 
    *   **IAM Role** grants permission to read the database secret.
    *   **WAF WebACL** attached to the service, configured to **BLOCK ALL** except:
        1.  The provided `AllowedIPs` list.
        2.  The `NatGatewayIP` (to allow internal tools to reach the API).
