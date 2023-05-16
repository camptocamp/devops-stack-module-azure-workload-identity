output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "helm_values" {
  description = "Helm values applied to the module's chart"
  value       = data.utils_deep_merge_yaml.values.output
}

output "azure_identities" {
  description = "Azure User Assigned Identities created"
  value = { for v in var.azure_identities :
    format("%s.%s", v.namespace, v.name) => {
      name         = v.name
      namespace    = v.namespace
      resource_id  = azurerm_user_assigned_identity.this[format("%s.%s", v.namespace, v.name)].id
      client_id    = azurerm_user_assigned_identity.this[format("%s.%s", v.namespace, v.name)].client_id
      principal_id = azurerm_user_assigned_identity.this[format("%s.%s", v.namespace, v.name)].principal_id
    }
}
