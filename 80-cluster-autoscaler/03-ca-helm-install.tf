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

  # 👉 Use a recent stable chart 
  version = "9.35.0"  # compatible with your k8s version: 1.33  (safe modern chart, works with newer k8s)

  create_namespace = false

  values = [
    yamlencode({
      replicaCount = 1

      cloudProvider = "aws"
      awsRegion     = var.region

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

      # 🔥 IMPORTANT → force correct autoscaler version
      image = {
        repository = "registry.k8s.io/autoscaling/cluster-autoscaler"
        tag        = "v1.33.0"
      }

      extraArgs = {
        cluster-name = local.eks_cluster_name
        balance-similar-node-groups    = "true"
        skip-nodes-with-system-pods    = "false"
        skip-nodes-with-local-storage  = "false"
        expander                       = "least-waste"

        node-group-auto-discovery = "asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${local.eks_cluster_name}"
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
    })
  ]

  depends_on = [
    aws_iam_role.cluster_autoscaler_role,
    aws_iam_role_policy_attachment.cluster_autoscaler_policy_attachment
  ]
}
