locals {
  helm_values = [{
    workload-identity-webhook = {
      azureTenantID = var.azure_tenant_id
    }
  }]
}
