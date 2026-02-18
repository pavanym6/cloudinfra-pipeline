# --- Project Context ---
variable "aws-region" {
  description = "The AWS region to deploy resources"
}

variable "cluster-name" {
  description = "Name of the EKS cluster"
}

variable "vpc-name" {
  description = "Name of the VPC"
}

variable "env" {
  description = "Deployment environment (e.g., dev, prod)"
}

# --- Network Configuration ---
variable "cidr-block" {
  description = "VPC CIDR block"
}

variable "igw-name" {
  description = "Name of the Internet Gateway"
}

# Public Subnets
variable "pub_subnet_count" {
  type = number
}

variable "pub_cidr_block" {
  type = list(string)
}

variable "pub_availability_zone" {
  type = list(string)
}

variable "pub_sub_name" {
  description = "Prefix for public subnet names"
}

# Private Subnets
variable "pri_subnet_count" {
  type = number
}

variable "pri_cidr_block" {
  type = list(string)
}

variable "pri_availability_zone" {
  type = list(string)
}

variable "pri_subnet_name" {
  description = "Prefix for private subnet names"
}

# Routing & Security
variable "public_rt_name" {}
variable "private_rt_name" {}
variable "eip-name" {}
variable "ngw_name" {}
variable "eks_sg" {}

# --- IAM & EKS Configuration ---
variable "is_eks_role_enabled" {
  type = bool
}

variable "is_eks_nodegroup_role_enabled" {
  type = bool
}

variable "cluster_version" {
  description = "Kubernetes version"
}

variable "endpoint_private_access" {
  type = bool
}

variable "endpoint_public_access" {
  type = bool
}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
}

# --- Node Group Scaling ---
variable "ondemand_instance_types" {
  type = list(string)
}

variable "desired_capacity_on_demand" {
  type = number
}

variable "min_capacity_on_demand" {
  type = number
}

variable "max_capacity_on_demand" {
  type = number
}

variable "spot_instance_types" {
  type = list(string)
}

variable "desired_capacity_spot" {
  type = number
}

variable "min_capacity_spot" {
  type = number
}

variable "max_capacity_spot" {
  type = number
}