output "api_endpoint" {
  description = "API Endpoint."
  value       = kind_cluster.default.endpoint
}

output "kubeconfig" {
  description = "Path to the kubeconfig file."
  value       = kind_cluster.default.kubeconfig
  
}

output "client_certificate" {
  description = "Client Certificate."
  value       = kind_cluster.default.client_certificate
}

output "client_key" {
  description = "Client Key."
  value       = kind_cluster.default.client_key
}

output "cluster_ca_certificate" {
  description = "CA Certificate."
  value       = kind_cluster.default.cluster_ca_certificate
}

