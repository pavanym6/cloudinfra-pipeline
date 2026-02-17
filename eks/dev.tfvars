aws-region   = "us-east-1"
env          = "dev"
cluster-name = "mypym-eks"
vpc-name     = "mypym-vpc"
cidr-block   = "10.0.0.0/16"
igw-name     = "mypym-igw"

pub_subnet_count      = 3
pub_cidr_block        = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
pub_availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]
pub_sub_name          = "mypym-public-subnet"

pri_subnet_count      = 3
pri_cidr_block        = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
pri_availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]
pri_subnet_name       = "mypym-private-subnet"

public_rt_name  = "mypym-public-rt"
private_rt_name = "mypym-private-rt"
eip-name        = "mypym-eip"
ngw_name        = "mypym-ngw"
eks_sg          = "mypym-eks-sg"

is_eks_role_enabled           = true
is_eks_nodegroup_role_enabled = true
cluster_version               = "1.30"
endpoint_private_access       = true
endpoint_public_access        = true

addons = [
  { name = "vpc-cni", version = "v1.18.1-eksbuild.3" },
  { name = "kube-proxy", version = "v1.30.0-eksbuild.3" }
]

ondemand_instance_types    = ["t3.medium"]
desired_capacity_on_demand = 1
min_capacity_on_demand     = 1
max_capacity_on_demand     = 2

spot_instance_types    = ["t3.medium"]
desired_capacity_spot  = 1
min_capacity_spot      = 1
max_capacity_spot      = 2