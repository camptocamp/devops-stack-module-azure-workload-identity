resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

data "azurerm_resource_group" "this" {
  name = var.node_resource_group_name
}

data "azurerm_subscription" "primary" {}

resource "azurerm_user_assigned_identity" "this" {
  for_each = {
    for k, v in var.workload_identities :
    format("%s.%s", v.namespace, v.name) => v
  }
  resource_group_name = var.node_resource_group_name
  location            = data.azurerm_resource_group.this.location
  name                = format("%s-%s-%s", each.value.namespace, each.value.name, var.cluster_name)
}

resource "azurerm_federated_identity_credential" "this" {
  for_each = {
    for k, v in var.workload_identities :
    format("%s.%s", v.namespace, v.name) => v
  }
  name                = format("%s-%s-%s-wkid", each.value.namespace, each.value.name, var.cluster_name)
  resource_group_name = var.node_resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.cluster_oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.this[format("%s.%s", each.value.namespace, each.value.name)].id
  subject             = "system:serviceaccount:${each.value.namespace}:${each.value.name}"
}

resource "argocd_project" "this" {
  metadata {
    name      = "workload-identities"
    namespace = var.argocd_namespace
    annotations = {
      "devops-stack.io/argocd_namespace" = var.argocd_namespace
    }
  }

  spec {
    description  = "workload-identities application project"
    source_repos = ["https://github.com/camptocamp/devops-stack-module-azure-workload-identity.git"]

    destination {
      name      = "in-cluster"
      namespace = "*"
    }

    orphaned_resources {
      warn = true
    }

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }
  }
}

data "utils_deep_merge_yaml" "values" {
  input = [for i in concat(local.helm_values, var.helm_values) : yamlencode(i)]
}

resource "argocd_application" "this" {
  metadata {
    name      = "workload-identity"
    namespace = var.argocd_namespace
  }

  wait = var.app_autosync == { "allow_empty" = tobool(null), "prune" = tobool(null), "self_heal" = tobool(null) } ? false : true

  spec {
    project = argocd_project.this.metadata.0.name

    source {
      repo_url        = "https://github.com/camptocamp/devops-stack-module-azure-workload-identity.git"
      path            = "charts/workload-identity"
      target_revision = var.target_revision
      helm {
        values = data.utils_deep_merge_yaml.values.output
      }
    }

    destination {
      name      = "in-cluster"
      namespace = var.namespace
    }


    sync_policy {
      automated = var.app_autosync

      retry {
        backoff = {
          duration     = ""
          max_duration = ""
        }
        limit = "0"
      }

      sync_options = [
        "CreateNamespace=true"
      ]
    }
  }

  depends_on = [
    resource.null_resource.dependencies,
  ]
}

resource "null_resource" "this" {
  depends_on = [
    resource.argocd_application.this,
  ]
}
