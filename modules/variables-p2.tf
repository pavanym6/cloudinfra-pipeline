# --- Project Context ---
variable "cluster-name" {}
variable "vpc-name" {}
variable "env" {}

# --- Network Configuration ---
variable "cidr-block" {}
variable "igw-name" {}

# Public Subnets
variable "pub_subnet_count" { type = number }
variable "pub_cidr_block" { type = list(string) }
variable "pub_availability_zone" { type = list(string) }
variable "pub_sub_name" {}

# Private Subnets
variable "pri_subnet_count" { type = number }
variable "pri_cidr_block" { type = list(string) }
variable "pri_availability_zone" { type = list(string) }
variable "pri_subnet_name" {}

# Routing & Security
variable "public_rt_name" {}
variable "private_rt_name" {}
variable "eip-name" {}
variable "ngw_name" {}
variable "eks_sg" {}

# --- IAM Roles ---
variable "is_eks_role_enabled" { type = bool }
variable "is_eks_nodegroup_role_enabled" { type = bool }

# --- EKS Cluster Settings ---
variable "cluster-version" {}
variable "endpoint-private-access" { type = bool }
variable "endpoint-public-access" { type = bool }
variable "is-eks-cluster-enabled" {
  type        = bool
  description = "Toggle to enable or disable the EKS cluster creation"
}


variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
}

# --- Node Group Scaling ---
variable "ondemand_instance_types" { type = list(string) }
variable "desired_capacity_on_demand" { type = number }
variable "min_capacity_on_demand" { type = number }
variable "max_capacity_on_demand" { type = number }

variable "spot_instance_types" { type = list(string) }
variable "desired_capacity_spot" { type = number }
variable "min_capacity_spot" { type = number }
variable "max_capacity_spot" { type = number }