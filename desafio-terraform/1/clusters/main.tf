terraform {
  required_providers {
    kind =  {
    source = "kyma-incubator/kind"
    version = "0.0.11"
    }
  }
}

resource "kind_cluster" "default" {
    name = var.cluster_name
    node_image = var.kubernetes_version      

    kind_config  {
        kind        = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"              

        node {
            role = "infra"      
        }
                    
        node {
            role =  "app"
        }
    } 
}
