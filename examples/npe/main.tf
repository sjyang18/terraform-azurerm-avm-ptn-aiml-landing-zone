terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
    cognitive_account {
      purge_soft_delete_on_destroy = true
    }
  }
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.3.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

# Get the deployer IP address to allow for public access to key vault during testing
data "http" "ip" {
  url = "https://api.ipify.org/"
  retry {
    attempts     = 5
    max_delay_ms = 1000
    min_delay_ms = 500
  }
}

# NPE (Non-Production Environment) AI/ML Landing Zone deployment
# This example demonstrates a development/test deployment with AI services enabled
# using basic/standard SKUs and minimal configurations suitable for NPE workloads.
module "test" {
  source = "../../"

  # Basic configuration
  location            = var.location
  resource_group_name = "rg-aiml-lz-npe-${substr(module.naming.unique-seed, 0, 5)}"
  name_prefix        = "engifrnpe"
  enable_telemetry   = var.enable_telemetry

  # Set to false to avoid platform landing zone dependencies
  flag_platform_landing_zone = false

  # Tags for cost tracking
  tags = {
    Environment = "npe"
    CostProfile = "npe"
    Example     = "npe"
  }

  # Minimal VNet configuration - using address space compatible with AI Foundry
  vnet_definition = {
    name          = "vnet-aiml-npe"
    address_space = "192.168.0.0/23"  # Required for AI Foundry capability host injection
    dns_servers   = []
    subnets = {
      default = {
        enabled        = true
        name          = "snet-default"
        address_prefix = "192.168.0.0/26"
      }
      private_endpoints = {
        enabled        = true
        name          = "snet-pe"
        address_prefix = "192.168.0.64/26"
      }
    }
  }

  # ENABLE AI FOUNDRY SERVICES (with cost-conscious settings)
  ai_foundry_definition = {
    create_byor      = true
    purge_on_destroy = true  # Allows cleanup in testing
    ai_foundry = {
      create_ai_agent_service = true
      sku                    = "S0"  # Use basic SKU
    }
    # Single AI model deployment (cost-conscious)
    ai_model_deployments = {
      "gpt-35-turbo" = {
        name = "gpt-35-turbo"
        model = {
          format  = "OpenAI"
          name    = "gpt-35-turbo"
          version = "0613"
        }
        scale = {
          type     = "Standard"
          capacity = 1  # Minimal capacity
        }
      }
    }
    # Single AI project
    ai_projects = {
      project_1 = {
        name                       = "npe-project"
        description                = "NPE AI project for development and testing"
        display_name               = "NPE Project"
        create_project_connections = true
        cosmos_db_connection = {
          new_resource_map_key = "this"
        }
        ai_search_connection = {
          new_resource_map_key = "this"
        }
        storage_account_connection = {
          new_resource_map_key = "this"
        }
      }
    }
    # Supporting AI Foundry services with minimal configurations
    ai_search_definition = {
      this = {
        enable_diagnostic_settings = false
        sku                        = "basic"  # Use basic SKU
      }
    }
    cosmosdb_definition = {
      this = {
        enable_diagnostic_settings = false
        consistency_level          = "Session"
        offer_type                = "Standard"
      }
    }
    key_vault_definition = {
      this = {
        enable_diagnostic_settings = false
        sku                        = "standard"  # Use standard SKU
      }
    }
    storage_account_definition = {
      this = {
        enable_diagnostic_settings = false
        shared_access_key_enabled  = true
        account_tier              = "Standard"
        account_replication_type  = "LRS"  # Cheapest replication
        endpoints = {
          blob = {
            type = "blob"
          }
        }
      }
    }
  }

  # ENABLE GENAI SUPPORTING SERVICES (with cost-conscious settings)
  genai_app_configuration_definition = {
    deploy = true
    sku    = "standard"  # Use standard SKU
  }

  genai_container_registry_definition = {
    deploy                        = true
    enable_diagnostic_settings    = false
    sku                          = "Basic"  # Use basic SKU instead of Premium
    zone_redundancy_enabled      = false   # Disable for cost savings
  }

  genai_cosmosdb_definition = {
    deploy                      = true
    enable_diagnostic_settings  = false
    consistency_level          = "Session"
    offer_type                = "Standard"
  }

  genai_key_vault_definition = {
    deploy                        = true
    enable_diagnostic_settings    = false
    sku                          = "standard"  # Use standard SKU
    public_network_access_enabled = true      # For testing purposes
    network_acls = {
      bypass   = "AzureServices"
      ip_rules = ["${data.http.ip.response_body}/32"]
    }
  }

  genai_storage_account_definition = {
    deploy                      = true
    enable_diagnostic_settings  = false
    account_tier               = "Standard"
    account_replication_type   = "LRS"  # Cheapest replication
  }

  # ENABLE KNOWLEDGE SOURCES (with basic SKU)
  ks_ai_search_definition = {
    deploy                      = true
    enable_diagnostic_settings  = false
    sku                        = "basic"  # Use basic SKU instead of standard
  }

  ks_bing_grounding_definition = {
    deploy = true
  }

  # ENABLE API MANAGEMENT (with basic SKU)
  apim_definition = {
    deploy    = true
    sku_name  = "Developer_1"  # Use developer SKU for cost savings
  }

  # ENABLE NETWORKING COMPONENTS
  app_gateway_definition = {
    deploy = false  # Keep disabled as requested
  }

  bastion_definition = {
    deploy = true
    sku    = "Basic"  # Use basic SKU
  }

  firewall_definition = {
    deploy = false  # Keep disabled for cost savings
  }

  # ENABLE COMPUTE SERVICES (with minimal configurations)
  container_app_environment_definition = {
    deploy                      = true
    enable_diagnostic_settings  = false
  }

  buildvm_definition = {
    deploy = false  # Keep disabled as requested
  }

  jumpvm_definition = {
    deploy    = true
    vm_size   = "Standard_B2s"  # Use smaller, cheaper VM size
  }

  # KEEP MINIMAL MONITORING (Log Analytics Workspace is relatively cheap)
  law_definition = {
    deploy                             = true
    sku                               = "PerGB2018"
    retention_in_days                 = 30
    internet_ingestion_enabled        = false
    internet_query_enabled            = false
    reservation_capacity_in_gb_per_day = null
  }
}
