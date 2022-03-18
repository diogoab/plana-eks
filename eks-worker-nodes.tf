#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "plana-ch2-cluster-nodes" {
  name = "plana-ch2-cluster-nodes"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "plana-ch2-cluster-nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.plana-ch2-cluster-nodes.name
}

resource "aws_iam_role_policy_attachment" "plana-ch2-cluster-nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.plana-ch2-cluster-nodes.name
}

resource "aws_iam_role_policy_attachment" "plana-ch2-cluster-nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.plana-ch2-cluster-nodes.name
}

resource "aws_eks_node_group" "plana-ch2-nodes" {
  cluster_name    = aws_eks_cluster.plana-ch2-cluster.name
  node_group_name = "plana-ch2-nodes"
  node_role_arn   = aws_iam_role.plana-ch2-cluster-nodes.arn
  subnet_ids      = aws_subnet.plana-ch2-subnet[*].id

  scaling_config {
    desired_size = 2
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.plana-ch2-cluster-nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.plana-ch2-cluster-nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.plana-ch2-cluster-nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}
