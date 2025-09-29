# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix = [var.resource_suffix]
}

resource "azurerm_resource_group" "example" {
  location = "southeastasia"
  name     = "rg-${var.resource_suffix}"
}

resource "azurerm_service_plan" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "FC1" # Flex Consumption, 1 vCPU, 2 GB RAM
  worker_count        = 1
  tags = {
    app = module.naming.function_app.name_unique
  }
}

resource "azurerm_storage_account" "example" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example.name

  public_network_access_enabled = false
  shared_access_key_enabled = false
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass = []
    // bypass         = ["AzureServices"]
  }
}

# Storage container for Flex Consumption deployments
resource "azurerm_storage_container" "deployments" {
  name                  = "function-deployments"
  storage_account_id    = azurerm_storage_account.example.id
  container_access_type = "private"
}

# Private endpoint for Storage Account

# TODO: "azurerm_private_endpoint" "storage" -> "azurerm_private_endpoint" "storage_blob"
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-${azurerm_storage_account.example.name}-blob"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.snet_private_endpoint.id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.example.name}"
    private_connection_resource_id = azurerm_storage_account.example.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

# Private endpoint for Storage Account - queue
resource "azurerm_private_endpoint" "storage_queue" {
  name                = "pe-${azurerm_storage_account.example.name}-queue"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.snet_private_endpoint.id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.example.name}-queue"
    private_connection_resource_id = azurerm_storage_account.example.id
    subresource_names              = ["queue"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "storage_queue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_queue" {
  name                  = "${azurerm_virtual_network.example.name}-storage-queue-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_queue.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_dns_a_record" "storage_queue" {
  name                = azurerm_storage_account.example.name
  zone_name           = azurerm_private_dns_zone.storage_queue.name
  resource_group_name = azurerm_resource_group.example.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.storage_queue.private_service_connection[0].private_ip_address]
}

# Private endpoint for Storage Account - table
resource "azurerm_private_endpoint" "storage_table" {
  name                = "pe-${azurerm_storage_account.example.name}-table"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.snet_private_endpoint.id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.example.name}-table"
    private_connection_resource_id = azurerm_storage_account.example.id
    subresource_names              = ["table"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "storage_table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_table" {
  name                  = "${azurerm_virtual_network.example.name}-storage-table-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_table.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_dns_a_record" "storage_table" {
  name                = azurerm_storage_account.example.name
  zone_name           = azurerm_private_dns_zone.storage_table.name
  resource_group_name = azurerm_resource_group.example.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.storage_table.private_service_connection[0].private_ip_address]
}

# Private endpoint for Storage Account - file
resource "azurerm_private_endpoint" "storage_file" {
  name                = "pe-${azurerm_storage_account.example.name}-file"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.snet_private_endpoint.id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.example.name}-file"
    private_connection_resource_id = azurerm_storage_account.example.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "storage_file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_file" {
  name                  = "${azurerm_virtual_network.example.name}-storage-file-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_file.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_dns_a_record" "storage_file" {
  name                = azurerm_storage_account.example.name
  zone_name           = azurerm_private_dns_zone.storage_file.name
  resource_group_name = azurerm_resource_group.example.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.storage_file.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  name                  = "${azurerm_virtual_network.example.name}-storage-blob-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_dns_a_record" "storage_blob" {
  name                = azurerm_storage_account.example.name
  zone_name           = azurerm_private_dns_zone.storage_blob.name
  resource_group_name = azurerm_resource_group.example.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address]
}

# -- Inbound Private Endpoint
locals {
  azurerm_private_dns_zone_resource_name = "privatelink.${local.reformatted_subdomain}"
  #default_host_name                      = module.avm_res_web_site.resource_uri
  default_host_name                      = azurerm_function_app_flex_consumption.example.default_hostname
  reformatted_subdomain                  = join(".", slice(local.split_subdomain, 1, length(local.split_subdomain)))
  split_subdomain                        = split(".", local.default_host_name)
}


resource "azurerm_private_dns_zone" "example" {
  name                = local.azurerm_private_dns_zone_resource_name
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "${azurerm_virtual_network.example.name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  resource_group_name   = azurerm_resource_group.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
}


resource "azurerm_role_assignment" "example" {
  principal_id         = azurerm_function_app_flex_consumption.example.identity[0].principal_id
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Owner"
}

# Azure Function Flex Consumption
resource "azurerm_function_app_flex_consumption" "example" {
  name                = module.naming.function_app.name_unique
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  service_plan_id     = azurerm_service_plan.example.id

  # Flex Consumption storage configuration
  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.example.primary_blob_endpoint}${azurerm_storage_container.deployments.name}"
  storage_authentication_type = "SystemAssignedIdentity" #"StorageAccountConnectionString"
  # storage_access_key          = azurerm_storage_account.example.primary_access_key
  
  # disable public access
  public_network_access_enabled = false


  # Runtime configuration
  runtime_name    = "node"
  runtime_version = "22"
  
  # Flex Consumption specific settings
  maximum_instance_count = 40 # minimum allowed value for testing
  instance_memory_in_mb  = 2048

  app_settings = {
    # https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings#website_contentovervnet
    WEBSITE_CONTENTOVERVNET = 1
    /*
    "AzureWebJobsStorage" = "" //workaround until https://github.com/hashicorp/terraform-provider-azurerm/pull/29099 gets released
    "AzureWebJobsStorage__accountName" = azurerm_storage_account.storageAccount.name
    */
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {}

  # VNET Integration for Function App Flex Consumption
  virtual_network_subnet_id = azurerm_subnet.snet_vnet_integration.id

  depends_on = [ 
    azurerm_storage_account.example,
    azurerm_storage_container.deployments,
    azurerm_private_dns_a_record.storage_blob,
    azurerm_private_dns_a_record.storage_queue,
    azurerm_private_dns_a_record.storage_table,
    azurerm_private_dns_a_record.storage_file
   ]
}


# Inbound Private endpoint for Function App
resource "azurerm_private_endpoint" "function_app" {
  name                = "pe-${azurerm_function_app_flex_consumption.example.name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.snet_internal_load_balancer.id

  private_service_connection {
    name                           = "psc-${azurerm_function_app_flex_consumption.example.name}"
    private_connection_resource_id = azurerm_function_app_flex_consumption.example.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}
resource "azurerm_private_dns_a_record" "function_app" {
  name                = azurerm_function_app_flex_consumption.example.name
  zone_name           = azurerm_private_dns_zone.example.name
  resource_group_name = azurerm_resource_group.example.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.function_app.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_a_record" "function_app_scm" {
  name                = "${azurerm_function_app_flex_consumption.example.name}.scm"
  zone_name           = azurerm_private_dns_zone.example.name
  resource_group_name = azurerm_resource_group.example.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.function_app.private_service_connection[0].private_ip_address]
}



# This is the module call
/*
module "avm_res_web_site" {
  source  = "Azure/avm-res-web-site/azurerm"

  kind     = "functionapp"
  location = azurerm_resource_group.example.location
  name     = module.naming.function_app.name_unique
  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.example.os_type
  resource_group_name      = azurerm_resource_group.example.name
  service_plan_resource_id = azurerm_service_plan.example.id
  enable_telemetry         = var.enable_telemetry
  managed_identities = {
    system_assigned = true
  }

  app_settings = {
    //"FUNCTIONS_WORKER_RUNTIME" = "node"
    //"FUNCTIONS_EXTENSION_VERSION" = "~4"
  }

  site_config = {
    application_stack = {
      node = {
        node_version              = "22"
      }
      # dotnet = {
      #   dotnet_version              = "9.0"
      #   use_dotnet_isolated_runtime = true
      # }

      # java = {
      #   java_version              = "21"
      # }
      
      # python = {
      #   python_version              = "3.13"
      # }
    }
  }

  public_network_access_enabled = false
  private_endpoints = {
    # Use of private endpoints requires Standard SKU
    primary = {
      name                          = "primary-interfaces"
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.example.id]
      subnet_resource_id            = azurerm_subnet.example.id

      tags = {
        webapp = "${module.naming.function_app.name_unique}-interfaces"
      }

    }

  }

  # Uses an existing storage account
  storage_account_name          = azurerm_storage_account.example.name
  storage_uses_managed_identity = true
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}
*/