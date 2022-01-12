module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets

  manage_worker_iam_resources = false
  manage_cluster_iam_resources = false
  cluster_iam_role_name = "eksClusterRole"

  tags = {
    Environment = "training"
  }

  workers_group_defaults = {
    instance_type    = "t3.micro"
    root_volume_type = "gp2"
    root_volume_size = "10"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.small"
      asg_desired_capacity          = 2
      asg_max_capacity              = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      iam_instance_profile_name     = "eksWorkerNodeRole"
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
