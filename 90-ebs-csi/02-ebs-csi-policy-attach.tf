# Resource: Attach AWS Managed Policy for EBS CSI Driver
resource "aws_iam_role_policy_attachment" "ebs_csi_managed_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_role.name
}

resource "aws_iam_role_policy_attachment" "eso_secrets_policy_attachment" {
  role       = aws_iam_role.eso_role.name
  policy_arn = aws_iam_policy.eso_secrets_policy.arn
}
