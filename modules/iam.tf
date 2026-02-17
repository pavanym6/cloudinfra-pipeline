locals {
  cluster_name = var.cluster-name
}

# Helps avoid "Role already exists" errors if you destroy and recreate quickly
resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}

#-------------------------------------------------------------------EKS CLUSTER ROLE
resource "aws_iam_role" "eks_cluster_role" {
  count = var.is_eks_role_enabled ? 1 : 0
  name  = "${local.cluster_name}-cluster-role-${random_integer.random_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# CRITICAL: The cluster needs this to manage AWS resources on your behalf
resource "aws_iam_role_policy_attachment" "eks_AmazonEKSClusterPolicy" {
  count      = var.is_eks_role_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role[count.index].name
}

#-------------------------------------------------------------------NODE GROUP ROLE
resource "aws_iam_role" "eks_nodegroup_role" {
  count = var.is_eks_nodegroup_role_enabled ? 1 : 0
  name  = "${local.cluster_name}-nodegroup-role-${random_integer.random_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_AmazonWorkerNodePolicy" {
  count      = var.is_eks_nodegroup_role_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKS_CNI_Policy" {
  count      = var.is_eks_nodegroup_role_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEC2ContainerRegistryReadOnly" {
  count      = var.is_eks_nodegroup_role_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role[count.index].name
}

# Required for the EBS CSI Driver addon (Storage)
resource "aws_iam_role_policy_attachment" "eks_AmazonEBSCSIDriverPolicy" {
  count      = var.is_eks_nodegroup_role_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_nodegroup_role[count.index].name
}

#-------------------------------------------------------------------OIDC ROLE
# (Used for Service Accounts / IRSA)
resource "aws_iam_role" "eks_oidc_role" {
  count = var.is_eks_role_enabled ? 1 : 0
  name  = "${local.cluster_name}-oidc-role"

  # Note: Ensure you have the data source 'aws_iam_policy_document.eks_oidc_assume_role_policy' 
  # defined elsewhere in your code to make this work.
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy.json
}

resource "aws_iam_policy" "eks_oidc_lab_policy" {
  name        = "eks-lab-policy"
  description = "A safer policy for lab environments"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "s3:ListBucket",
        "s3:GetObject",
        "ec2:Describe*"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_oidc_policy_attach" {
  count      = var.is_eks_role_enabled ? 1 : 0
  role       = aws_iam_role.eks_oidc_role[count.index].name
  policy_arn = aws_iam_policy.eks_oidc_lab_policy.arn
}

# This creates the OIDC Provider in AWS so IAM can trust your EKS cluster
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks-certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks[0].identity[0].oidc[0].issuer
}