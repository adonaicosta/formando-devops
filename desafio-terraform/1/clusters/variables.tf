variable "cluster_name" {
  description = "Cluster Name"
  type        = string
  default     = "demo-local"
}

variable "kubernetes_version" {
  description = "Kubernetes Version"
  type        = string
  default     = "kindest/node:v1.16.1"
}
