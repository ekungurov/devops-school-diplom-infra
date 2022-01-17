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
  manage_aws_auth = false

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

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name             = "aws-auth"
    namespace        = "kube-system"
    labels           = {
      "app.kubernetes.io/managed-by" = "Terraform"
      "terraform.io/module"          = "root"
    }
  }

  data = {
    mapAccounts   = jsonencode([])
    mapRoles      = <<EOT
- rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eksWorkerNodeRole
  username: system:node:{{EC2PrivateDNSName}}
  groups:
  - system:bootstrappers
  - system:nodes
  EOT
    mapUsers      = <<EOT
- userarn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/yk-eks-developer
  username: eks-release-engineer
  EOT
  }
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
