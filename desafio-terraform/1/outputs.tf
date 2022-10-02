output "api_endpoint" {
  description = "API Endpoint."
  value       = module.clusters.api_endpoint    
}

output "kubeconfig" {
  description = "Path to the kubeconfig file."
  value       = module.clusters.kubeconfig 
}

output "client_certificate" {
  description = "Client Certificate."
  value       = module.clusters.client_certificate
}

output "client_key" {
  description = "Client Key."
  value       = module.clusters.client_key
}

output "cluster_ca_certificate" {
  description = "CA Certificate."
  value       = module.clusters.cluster_ca_certificate
}