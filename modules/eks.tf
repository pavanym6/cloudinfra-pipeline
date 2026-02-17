#-------------------------------------------------------------------EKS CLUSTER
resource "aws_eks_cluster" "eks" {
    count    = var.is_eks_role_enabled ? 1 : 0
    name     = var.cluster-name
    role_arn = aws_iam_role.eks_cluster_role[count.index].arn
    version  = var.cluster_version

    vpc_config {
        # Using [*].id makes this dynamic so it doesn't break if you change subnet counts
        subnet_ids = aws_subnet.private_subnet[*].id 
        
        endpoint_private_access = var.endpoint_private_access
        endpoint_public_access  = var.endpoint_public_access
        security_group_ids      = [aws_security_group.eks-cluster-sg.id]
    }

    access_config {
        authentication_mode                         = "CONFIG_MAP"
        bootstrap_cluster_creator_admin_permissions = true
    }

    tags = {
      Name = var.cluster-name
      Env  = var.env
    }
}

#-------------------------------------------------------------------NODE GROUP: ON-DEMAND
resource "aws_eks_node_group" "ondemand_node" {
  count           = var.is_eks_nodegroup_role_enabled ? 1 : 0
  cluster_name    = aws_eks_cluster.eks[0].name # Added [0] index
  node_group_name = "${var.cluster-name}-on-demand-nodes"
  node_role_arn   = aws_iam_role.eks_nodegroup_role[0].arn
  
  # Ensure nodes are placed in the subnets we configured for the IGW
  subnet_ids      = aws_subnet.private_subnet[*].id

  scaling_config {
    desired_size = var.desired_capacity_on_demand
    max_size     = var.max_capacity_on_demand
    min_size     = var.min_capacity_on_demand
  }

  instance_types = var.ondemand_instance_types
  capacity_type  = "ON_DEMAND"

  tags = {
    "Name" = "${var.cluster-name}-ondemand-nodes"
  }

  depends_on = [aws_eks_cluster.eks]
}

#-------------------------------------------------------------------NODE GROUP: SPOT
resource "aws_eks_node_group" "spot_node" {
    count           = var.is_eks_nodegroup_role_enabled ? 1 : 0
    cluster_name    = aws_eks_cluster.eks[0].name # Added [0] index
    node_group_name = "${var.cluster-name}-spot-nodes"
    node_role_arn   = aws_iam_role.eks_nodegroup_role[0].arn
    subnet_ids      = aws_subnet.private_subnet[*].id

    scaling_config {
        desired_size = var.desired_capacity_spot
        min_size     = var.min_capacity_spot
        max_size     = var.max_capacity_spot
    }

    instance_types = var.spot_instance_types
    capacity_type  = "SPOT"

    labels = {
        type      = "spot"
        lifecycle = "spot"
    }

    disk_size = 50
    depends_on = [aws_eks_cluster.eks]
}

#-------------------------------------------------------------------ADDONS
resource "aws_eks_addon" "eks_addons" {
  # Use a conditional for_each so it doesn't try to run if the cluster isn't created
  for_each      = var.is_eks_role_enabled ? { for idx, addon in var.addons : idx => addon } : {}
  cluster_name  = aws_eks_cluster.eks[0].name
  addon_name    = each.value.name
  addon_version = each.value.version

  depends_on = [
    aws_eks_node_group.ondemand_node,
    aws_eks_node_group.spot_node
  ]
}