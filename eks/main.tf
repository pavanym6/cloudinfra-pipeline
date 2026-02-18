module "eks_stack" {
  source = "../modules"

  # Project & VPC
  cluster-name          = var.cluster-name
  vpc-name              = var.vpc-name
  env                   = var.env
  cidr-block            = var.cidr-block
  igw-name              = var.igw-name
  
  # Subnets
  pub_subnet_count      = var.pub_subnet_count
  pub_cidr_block        = var.pub_cidr_block
  pub_availability_zone = var.pub_availability_zone
  pub_sub_name          = var.pub_sub_name
  
  pri_subnet_count      = var.pri_subnet_count
  pri_cidr_block        = var.pri_cidr_block
  pri_availability_zone = var.pri_availability_zone
  pri_subnet_name       = var.pri_subnet_name

  # Routing & Gateways
  public_rt_name        = var.public_rt_name
  private_rt_name       = var.private_rt_name
  eip-name              = var.eip-name
  ngw_name              = var.ngw_name
  eks_sg                = var.eks_sg

  # IAM & EKS Configuration (Mapping Root Variables to Module Skeleton)
  is-eks-cluster-enabled        = var.is_eks_role_enabled
  is_eks_role_enabled           = var.is_eks_role_enabled 
  is_eks_nodegroup_role_enabled = var.is_eks_nodegroup_role_enabled
  cluster-version               = var.cluster_version
  endpoint-private-access       = var.endpoint_private_access
  endpoint-public-access        = var.endpoint_public_access
  addons                        = var.addons

  # Node Groups
  ondemand_instance_types    = var.ondemand_instance_types
  desired_capacity_on_demand = var.desired_capacity_on_demand
  min_capacity_on_demand     = var.min_capacity_on_demand
  max_capacity_on_demand     = var.max_capacity_on_demand

  spot_instance_types    = var.spot_instance_types
  desired_capacity_spot  = var.desired_capacity_spot
  min_capacity_spot      = var.min_capacity_spot
  max_capacity_spot      = var.max_capacity_spot
}