# HELM Provider
provider "helm" {
  kubernetes = {
    host                   = local.eks_host
    cluster_ca_certificate = base64decode(local.eks_cluster_ca_certificate)
    token                  = local.eks_token 
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"

  # Optional but recommended
  create_namespace = false

  # Pin version (important for stability)
  version = "9.29.0" # adjust based on your k8s version

  values = [
    yamlencode({
      replicaCount = 1

      cloudProvider = "aws"

      awsRegion = var.region

      autoDiscovery = {
        clusterName = local.eks_cluster_name
      }

      rbac = {
        create = true
        serviceAccount = {
          create = true
          name   = "cluster-autoscaler"
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler_role.arn
          }
        }
      }

      extraArgs = {
        "balance-similar-node-groups"      = "true"
        "skip-nodes-with-system-pods"      = "false"
        "skip-nodes-with-local-storage"   = "false"
        "expander"                        = "least-waste"
        "node-group-auto-discovery"       = "asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${local.eks_cluster_name}"
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "300Mi"
        }
        limits = {
          cpu    = "200m"
          memory = "600Mi"
        }
      }

      tolerations = [
        {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }
      ]
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.cluster_autoscaler_policy_attachment
  ]
}
