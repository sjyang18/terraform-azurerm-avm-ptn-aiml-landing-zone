# NPE (Non-Production Environment) AI/ML Landing Zone Example

This example demonstrates how to deploy the AI/ML Landing Zone module with a non-production configuration that enables essential AI/ML services while using basic/standard SKUs and minimal configurations suitable for development, testing, and staging environments.

## What's Included (NPE-Optimized)

### Core Infrastructure
- **Virtual Network**: Compatible address space (192.168.0.0/23) with subnets for AI Foundry
- **Log Analytics Workspace**: Basic monitoring with minimal retention (30 days)
- **Resource Group**: Container for all resources

### AI/ML Services (Basic SKUs)
- **AI Foundry Hub**: Enabled with basic S0 SKU
- **AI Projects**: Single project with connections to supporting services
- **AI Model Deployment**: Single GPT-3.5-Turbo model with minimal capacity
- **AI Agent Service**: Enabled

### Supporting Services (Cost-Optimized)
- **Azure Container Registry**: Basic SKU (instead of Premium)
- **Cosmos DB**: Standard offering with Session consistency
- **Key Vault**: Standard SKU
- **Storage Accounts**: Standard LRS replication (cheapest option)
- **App Configuration**: Standard SKU

### Knowledge Services
- **AI Search**: Basic SKU (instead of Standard/Premium)
- **Bing Grounding**: Enabled

### Platform Services (Minimal Configuration)
- **API Management**: Developer SKU (cost-effective for testing)
- **Azure Bastion**: Basic SKU
- **Container App Environment**: Enabled with minimal diagnostics
- **Jump VM**: Standard_B2s (small, cost-effective VM size)

## What's Disabled (Additional Cost Savings)

- **Application Gateway**: Disabled (can be expensive)
- **Azure Firewall**: Disabled (expensive)
- **Build VM**: Disabled (not essential for basic AI workloads)
- **Zone Redundancy**: Disabled on Container Registry
- **Diagnostic Settings**: Disabled on most services to reduce Log Analytics costs

## Cost Expectations (NPE Environment)

This configuration provides a balance between functionality and cost for non-production workloads:

**Estimated monthly costs:**
- AI Foundry Hub (S0): ~$20-50/month
- AI Search (Basic): ~$10-20/month
- Container Registry (Basic): ~$5/month
- Storage Accounts (LRS): ~$2-10/month
- Key Vault (Standard): ~$1-5/month
- Cosmos DB: ~$5-25/month (depending on usage)
- API Management (Developer): ~$50/month
- Jump VM (B2s): ~$30/month
- Other services: ~$10-30/month

**Total estimated cost: ~$130-200/month** (compared to $300-500+/month for production configurations)

> **Note**: AI model usage (token consumption) will incur additional costs based on actual usage.

## Usage

1. **Prerequisites**:
   - Azure CLI installed and authenticated
   - Terraform >= 1.9 installed
   - Sufficient Azure subscription quotas

2. **Deploy**:
   ```bash
   # Navigate to the NPE example directory
   cd examples/npe

   # Initialize Terraform
   terraform init

   # Review the plan
   terraform plan

   # Apply the configuration
   terraform apply
   ```

3. **Customize** (optional):
   ```bash
   # Override the default location
   terraform apply -var="location=westus2"

   # Disable telemetry
   terraform apply -var="enable_telemetry=false"
   ```

4. **Clean up**:
   ```bash
   terraform destroy
   ```

## Expanding the Configuration

If you want to gradually enable more services, you can modify the `main.tf` file:

### Enable Log Analytics with longer retention:
```hcl
law_definition = {
  deploy                             = true
  retention_in_days                 = 90  # Increase retention
  internet_ingestion_enabled        = true
  internet_query_enabled            = true
}
```

### Enable basic storage (relatively low cost):
```hcl
genai_storage_account_definition = {
  deploy = true
  sku    = "Standard_LRS"  # Cheapest option
}
```

### Enable Key Vault (low cost):
```hcl
genai_key_vault_definition = {
  deploy                        = true
  sku                          = "standard"  # Cheapest option
  public_network_access_enabled = true
}
```

## Important Notes

- **NPE environment**: This configuration is optimized for development, testing, and staging workloads
- **Non-production**: Ideal for testing Terraform configurations, development workflows, and pre-production validation
- **Scalable foundation**: Creates a foundation that can be promoted to production with configuration changes
- **Region constraints**: Defaults to `australiaeast` due to capacity limits in test subscriptions

## Next Steps

Once you've validated this low-cost deployment:
1. Review the [default example](../default/) for a hub-and-spoke pattern
2. Check the [standalone example](../standalone/) for full AI/ML capabilities
3. Gradually enable services based on your requirements and budget

## Security Considerations

- Network security groups are configured with basic rules
- Private endpoints subnet is created but not used (no private endpoints deployed)
- Consider enabling Azure Security Center for production workloads

## Troubleshooting

- **Quota issues**: Try a different region if you encounter capacity constraints
- **Permission errors**: Ensure your Azure account has Contributor access to the subscription
- **Network conflicts**: The default IP range (10.10.0.0/24) should not conflict with existing networks