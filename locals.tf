locals {
  helm_values = [{
    metricsEnabled = var.metrics_enabled
    workload-identity-webhook = {
      azureTenantID = var.azure_tenant_id
    }
  }]
}
