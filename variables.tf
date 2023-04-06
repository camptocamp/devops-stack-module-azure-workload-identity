#######################
## Standard variables
#######################

variable "cluster_name" {
  description = "Name given to the cluster. Value used for naming some the resources created by the module."
  type        = string
}

variable "base_domain" {
  type = string
}

variable "argocd_namespace" {
  description = "Namespace used by Argo CD where the Application and AppProject resources should be created."
  type        = string
}

variable "target_revision" {
  description = "Override of target revision of the application chart."
  type        = string
  default     = "v0.1.0" # x-release-please-version
}

variable "namespace" {
  type    = string
  default = "workload-identity"
}

variable "helm_values" {
  description = "Helm chart value overrides. They should be passed as a list of HCL structures."
  type        = any
  default     = []
}

variable "dependency_ids" {
  description = "IDs of the other modules on which this module depends on."
  type        = map(string)
  default     = {}
}

variable "app_autosync" {
  description = "Automated sync options for the Argo CD Application resource."
  type = object({
    allow_empty = optional(bool)
    prune       = optional(bool)
    self_heal   = optional(bool)
  })
  default = {
    allow_empty = false
    prune       = true
    self_heal   = true
  }
}

#######################
## Module variables
#######################

variable "workload_identities" {
  description = "Azure User Assigned Identities to create."
  type = list(object({
    namespace = string
    name      = string
  }))
  default = []
}

variable "node_resource_group_name" {
  description = "The Resource Group of the node pools. It will be used for new Managed Identities."
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "Cluster OIDC issuer url."
  type        = string
}

