terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
  }
}

resource "azapi_resource_action" "container_app_hostname" {
  type        = "Microsoft.App/containerApps@2023-05-02-preview"
  resource_id = var.container_app_resource_id
  method      = "PATCH"
  body = {
    properties = {
      configuration = {
        ingress = {
          customDomains = [
            {
              name = join(".", [var.name, var.zone_name])
              bindingType = "Disabled"
            }
          ]
        }
      }
    }
  }
  depends_on = [azurerm_dns_txt_record.container_app_txt, azurerm_dns_a_record.container_app_dns]
}

resource "azapi_resource" "container_app_certificate" {
  type      = "Microsoft.App/managedEnvironments/managedCertificates@2023-05-02-preview"
  name      = "managed-certificate-${var.name}-app"
  location  = var.location
  parent_id = var.container_app_environment_id
  tags      = var.tags
  body = {
    properties = {
      domainControlValidation = "HTTP"
      # It seems verification via TXT either doesn't work or it is running too long for IAC
      subjectName = join(".", [var.name, var.zone_name])
    }
  }
  depends_on = [
    azapi_resource_action.container_app_hostname
  ]
}

resource "azapi_resource_action" "container_app_custom_domain" {

  #On destroy provisioner necessary to remove domain before removing Certificate see error in comments below
  type        = "Microsoft.App/containerApps@2023-05-02-preview"
  resource_id = var.container_app_resource_id
  method      = "PATCH"
  body = {
    properties = {
      configuration = {
        ingress = {
          customDomains = [
            {
              name = join(".", [var.name, var.zone_name])
              bindingType   = "SniEnabled"
              certificateId = azapi_resource.container_app_certificate.id
            }
          ]
        }
      }
    }
  }
  depends_on = [
    azapi_resource.container_app_certificate,
  ]
}

resource "azurerm_dns_a_record" "container_app_dns" {
  name = join(".", [var.name])
  resource_group_name = var.resource_group
  ttl                 = 60
  zone_name           = var.zone_name
  records = [var.cname_target]
}

resource "azurerm_dns_txt_record" "container_app_txt" {
  name = join(".", ["asuid", var.name])
  resource_group_name = var.resource_group
  ttl                 = 60
  zone_name           = var.zone_name
  record {
    value = var.txt_verification
  }
}