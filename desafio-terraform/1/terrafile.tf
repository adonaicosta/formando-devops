module "clusters" {
  source             = "./clusters"
  cluster_name       = "ClusterFormandoDevOps1"
  kubernetes_version = "kindest/node:v1.18.4"
}