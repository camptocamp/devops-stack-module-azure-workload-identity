locals {
  helm_values = [{
    workload-identity = {
      workloadIdentities = [for v in var.workload_identities :
        tomap({
          name      = v.name
          namespace = v.namespace
          clientID  = azurerm_user_assigned_identity.this[format("%s.%s", v.namespace, v.name)].client_id
        })
      ]
    }
  }]
}
