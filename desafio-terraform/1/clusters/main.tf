resource "kind_cluster" "default" {
    name = var.cluster_name
    node_image = var.kubernetes_version      

    kind_config  {
        kind        = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"              

        node {
            role = "infra"           
            taints = [
                {
                  key    = "dedicated"
                  value  = "statefulset"
                  effect = "NO_SCHEDULE"
                }
            ] 
        }           
                    
        node {
            role =  "app"
        }
    } 
}

module "metrics-server" {
    source  = "iplabs/metrics-server/kubernetes"
    version = "1.0.0"
}