# Create vote all in one resource group
resource "azurerm_resource_group" "rsg" {
  name     = "rsg_jenkinsci"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks_jenkins"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
  dns_prefix          = "jenkins"
  #api_server_authorized_ip_ranges = local.aks_whitelisted_ips

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "Standard"
  }

  default_node_pool {
    name       = "jenkins"
    node_count = "2"
    vm_size    = "Standard_D2s_v3"
    #os_disk_size_gb = "var.agent_pool_disk_size"
    #vnet_subnet_id  = module.pattern_network.aks_subnet_id
  }

  service_principal {
    client_id     = azuread_application.main.application_id
    client_secret = azuread_service_principal_password.main.value
  }

  linux_profile {
    admin_username = "testadmin"
    ssh_key {
      key_data = tls_private_key.ssh.public_key_openssh
    }
  }

  kubernetes_version = "1.15.10"

  # Azure needs a non-existent resource group for provisioning of the kubernetes service.
  node_resource_group = "aks_node_jenkins"

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }
}

# Create key to add to Nodes
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

# Create AzureAD application
resource "azuread_application" "main" {
  name                    = "aksJenkinsAuthentication"
  group_membership_claims = "All"
}

# Create AzureAD Service Principle
resource "azuread_service_principal" "main" {
  application_id = azuread_application.main.application_id
}

# Generate random string to be used for service principal password
resource "random_string" "password" {
  length = 32
}

# Create service principal password
resource "azuread_service_principal_password" "main" {
  service_principal_id = azuread_service_principal.main.id
  value                = random_string.password.result
  end_date_relative    = "8760h"
}

# Get our current subscription
data "azurerm_subscription" "subscription" {}

# Add Container Pull permissions.
resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.main.id
}

# Grant AKS service principal access to join AKS subnet
resource "azurerm_role_assignment" "subnet" {
  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.main.id
}