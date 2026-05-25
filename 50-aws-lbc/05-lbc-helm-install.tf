# Install AWS Load Balancer Controller using HELM
resource "helm_release" "loadbalancer_controller" {
  depends_on = [
    aws_iam_role.lbc_iam_role,
    aws_iam_role_policy_attachment.lbc_iam_role_policy_attach
  ]
         
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace = "kube-system" 
  # version  = "1.17.0"          # Recommended in prod, if not specified always uses latest version   

  wait            = true         # Wait for resources to become Ready
  timeout         = 600
  cleanup_on_fail = true 

  # recreate_pods   = true
  # replace         = true
  # force_update    = true

  set = [
    # Create Service Account via Helm   
    {
      name  = "serviceAccount.create"           # RBAC is created automatically, no need to set explicitly
      value = "true"
    },

    # Service Account Name 
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },

    # EKS Cluster Name
    {
      name  = "clusterName"
      value = "${local.eks_cluster_name}"
    },

    # VPC Id     
    {
      name  = "vpcId"
      value = "${local.vpc_id}"
    },

    # AWS Region
    {
      name  = "region"
      value = "${var.region}"
    },

    # Service Account annotation with IAM Role
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.lbc_iam_role.arn
    },

    # Install CRDs
    {
      name  = "crds.create"
      value = "true"
    }
  ]       
}


# Helm Release Outputs
output "helm_lbc_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value = helm_release.loadbalancer_controller.metadata
}
