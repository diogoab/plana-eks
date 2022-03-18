#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "plana-ch2-cluster" {
  name = "plana-ch2-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "plana-ch2-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.plana-ch2-cluster.name
}

resource "aws_iam_role_policy_attachment" "plana-ch2-vpc-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.plana-ch2-cluster.name
}

resource "aws_security_group" "plana-ch2" {
  name        = "plana-ch2-sg-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.plana-ch2-vpc.id 
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "plana-ch2-cluster"
    Env = "dev"
  }
}

#resource "aws_security_group_rule" "eks-ingress" {
#  from_port                = 443
#  protocol                 = "tcp"
#  security_group_id        = "aws_security_group.plana-ch2.id"
#  to_port                  = 443
#  type                     = "ingress"
#}

resource "aws_eks_cluster" "plana-ch2-cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.plana-ch2-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.plana-ch2.id]
    subnet_ids         = aws_subnet.plana-ch2-subnet[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.plana-ch2-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.plana-ch2-vpc-AmazonEKSVPCResourceController,
  ]
}
