variable "aws-region" {}
variable "cluster-name" {}
variable "vpc-name" {}
variable "env" {}
variable "cidr-block" {}
variable "igw-name" {}

variable "pub_subnet_count" {}
variable "pub_cidr_block" { type = list(string) }
variable "pub_availability_zone" { type = list(string) }
variable "pub_sub_name" {}

variable "pri_subnet_count" {}
variable "pri_cidr_block" { type = list(string) }
variable "pri_availability_zone" { type = list(string) }
variable "pri_subnet_name" {}

variable "public_rt_name" {}
variable "private_rt_name" {}
variable "eip-name" {}
variable "ngw_name" {}
variable "eks_sg" {}

variable "is_eks_role_enabled" { type = bool }
variable "is_eks_nodegroup_role_enabled" { type = bool }
variable "cluster_version" {}
variable "endpoint_private_access" { type = bool }
variable "endpoint_public_access" { type = bool }

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
}

variable "ondemand_instance_types" { type = list(string) }
variable "desired_capacity_on_demand" {}
variable "min_capacity_on_demand" {}
variable "max_capacity_on_demand" {}

variable "spot_instance_types" { type = list(string) }
variable "desired_capacity_spot" {}
variable "min_capacity_spot" {}
variable "max_capacity_spot" {}