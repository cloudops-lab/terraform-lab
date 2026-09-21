aws_profile = "dev"

aws_region = "us-east-2"

vpc_cidr = "192.168.0.0/16"

vpc_name = "private-eks-vpc"

availability_zones = [
  "us-east-2a",
  "us-east-2b",
  "us-east-2c"
]

eks_cluster_name = "private-eks"

eks_version = "1.36"

node_instance_types = [
  "t3.medium"
]

node_desired_size = 3

node_min_size = 3

node_max_size = 6