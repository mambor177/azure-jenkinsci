# Create AzureAD application
resource "azuread_application" "jenkins_aad_auth" {
  name                       = "jenkins_aad_auth"
  reply_urls                 = ["https://jenkins-lb.jenkins.svc.cluster.local/securityRealm/finishLogin"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false # Implicit grant - Access Token
  group_membership_claims    = "All"
  type                       = "webapp/api"
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type = "Scope"
    }
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    }
  }
  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"
    resource_access {
      id   = "5778995a-e1bf-45b8-affa-663a9f3f4d04"
      type = "Scope"
    }
    resource_access {
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
    resource_access {
      id   = "5778995a-e1bf-45b8-affa-663a9f3f4d04"
      type = "Role"
    }
  }
}

# Create AzureAD Service Principle
resource "azuread_service_principal" "jenkins_aad_auth" {
  application_id = azuread_application.jenkins_aad_auth.application_id
}

# Generate random string to be used for service principal password
resource "random_string" "jenkins_aad_auth" {
  length = 32
}

# Create service principal password
resource "azuread_service_principal_password" "jenkins_aad_auth" {
  service_principal_id = azuread_service_principal.jenkins_aad_auth.id
  value                = random_string.jenkins_aad_auth.result
  end_date_relative    = "8760h"
}