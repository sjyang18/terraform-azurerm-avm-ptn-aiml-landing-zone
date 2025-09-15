# AI Model Configuration Guide

## Overview

This guide provides information about the AI models configured in this Azure AI/ML Landing Zone pattern module and helps you choose the most appropriate model for your needs.

## Current Model Configurations

### By Example

| Example | Model Name | Model Version | Scale Type | Purpose |
|---------|------------|---------------|------------|---------|
| NPE (Non-Production Environment) | gpt-35-turbo | 0125 | Standard | Cost-conscious development |
| Default | gpt-4.1 | 2025-04-14 | GlobalStandard | Full-featured deployment |
| Standalone | gpt-4.1 | 2025-04-14 | GlobalStandard | Standalone deployment |

## AI Model Evolution and Latest Available Models

### Current State Analysis

Based on the configurations in this repository:

- **NPE Example**: Uses `gpt-35-turbo` version `0125` (January 2024 release - updated from older 0613)
- **Default/Standalone Examples**: Use `gpt-4.1` version `2025-04-14` (Future-dated version indicating latest available)

### Model Recommendations by Use Case

#### 1. Cost-Conscious Development (NPE Example)
- **Current**: `gpt-35-turbo` version `0125`
- **Status**: Updated to more recent version for better performance while remaining cost-effective
- **Alternative**: `gpt-4o-mini` (if available) for better cost-performance balance

#### 2. Production Deployments (Default/Standalone Examples)
- **Current**: `gpt-4.1` version `2025-04-14`
- **Status**: This appears to be configured with the latest available model
- **Alternative Models**: `gpt-4o`, `gpt-4-turbo` (depending on availability in your region)

## How to Update AI Models

### Step 1: Check Available Models
Before updating models, verify what's available in your Azure region:

```bash
# Using Azure CLI (if available)
az cognitiveservices account list-models --kind OpenAI --location <your-region>
```

### Step 2: Update Model Configuration
Modify the `ai_model_deployments` section in your configuration:

```hcl
ai_model_deployments = {
  "your-model-key" = {
    name = "your-deployment-name"
    model = {
      format  = "OpenAI"
      name    = "model-name"        # e.g., "gpt-4o", "gpt-4-turbo"
      version = "model-version"     # e.g., "2024-08-06", "0125"
    }
    scale = {
      type     = "Standard"         # or "GlobalStandard" for global models
      capacity = 1
    }
  }
}
```

### Step 3: Validate Configuration
Run the AVM validation tools:

```bash
export PORCH_NO_TUI=1
./avm pre-commit
./avm pr-check
```

## Model Selection Guidelines

### For Development/Testing
- Use cost-effective models like `gpt-35-turbo` or `gpt-4o-mini`
- Standard scaling is usually sufficient
- Lower capacity settings to minimize costs

### for Production
- Use latest `gpt-4o` or `gpt-4-turbo` models for best performance
- Consider GlobalStandard scaling for better availability
- Monitor usage and adjust capacity as needed

### Regional Considerations
- Not all models are available in all Azure regions
- Check model availability in your target deployment region
- Consider backup model options for disaster recovery

## Latest Model Information Sources

To find the most current AI model information:

1. **Azure OpenAI Service Documentation**: 
   - https://docs.microsoft.com/en-us/azure/cognitive-services/openai/

2. **OpenAI Model Documentation**:
   - https://platform.openai.com/docs/models

3. **Azure AI Studio**:
   - Check available models in your Azure AI Studio instance

4. **Azure CLI**:
   ```bash
   az cognitiveservices account list-models --kind OpenAI
   ```

## Common Model Versions (as of last update)

| Model Family | Latest Version | Release Date | Capabilities |
|--------------|----------------|---------------|-------------|
| gpt-35-turbo | 0125 | January 2024 | Cost-effective, good for most tasks |
| gpt-4o | 2024-08-06 | August 2024 | Latest multimodal model |
| gpt-4-turbo | 2024-04-09 | April 2024 | High performance text model |
| gpt-4.1 | 2025-04-14 | Future release | Next-generation model |

**Note**: The `gpt-4.1` version `2025-04-14` in the default examples appears to be a placeholder for the latest available model. Verify actual availability in your Azure subscription.

## Migration Path from Older Models

If you're currently using older models (like `gpt-35-turbo` version `0613`), consider this migration path:

1. **Phase 1**: Update to latest `gpt-35-turbo` (0125 or newer)
2. **Phase 2**: Evaluate `gpt-4o-mini` for cost-performance balance
3. **Phase 3**: Migrate to `gpt-4o` or `gpt-4-turbo` for production workloads

## Troubleshooting

### Common Issues
- **Model not available**: Check regional availability
- **Quota exceeded**: Request quota increase in Azure portal
- **Version deprecated**: Update to supported version

### Validation Steps
1. Terraform plan succeeds without errors
2. Model deployment shows as healthy in Azure AI Studio
3. Model responds to test queries correctly

## Contributing

When updating this guide:
1. Verify model availability in multiple regions
2. Test configurations before documenting
3. Update version tables with actual release information
4. Include regional availability notes