# The EKS Cluster itself — this is the Kubernetes control plane
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster" # names it "eks-2048-cluster"
  role_arn = var.cluster_role_arn          # the IAM role we created in the IAM module
  version  = "1.31"                        # Kubernetes version

  vpc_config {
    subnet_ids              = var.private_subnets # control plane lives in private subnets
    endpoint_private_access = true                # cluster API accessible from inside VPC
    endpoint_public_access  = true                # cluster API also accessible from internet
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  # ensures IAM role is fully created before the cluster
  depends_on = [var.cluster_role_arn]

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

# The Node Group — the EC2 worker nodes that run your pods
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name # attaches to the cluster above
  node_group_name = "${var.project_name}-nodes"
  node_role_arn   = var.node_role_arn   # IAM role for the nodes
  subnet_ids      = var.private_subnets # nodes live in private subnets

  instance_types = ["t3.medium"] # 2 vCPU, 4GB RAM — enough for this project

  scaling_config {
    desired_size = 2 # start with 2 nodes
    min_size     = 1 # scale down to 1 if needed
    max_size     = 3 # scale up to 3 under load
  }

  update_config {
    max_unavailable = 1 # only take down 1 node at a time during updates
  }

  # ensures cluster and IAM role exist before creating nodes
  depends_on = [
    aws_eks_cluster.main,
    var.node_role_arn
  ]

  tags = {
    Name = "${var.project_name}-nodes"
  }
}

# Security Group for the EKS cluster control plane
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project_name}-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id # lives inside our VPC

  # allow all outbound traffic from the cluster
  egress {
    from_port   = 0             # all ports
    to_port     = 0             # all ports
    protocol    = "-1"          # all protocols
    cidr_blocks = ["0.0.0.0/0"] # to anywhere
  }

  tags = {
    Name = "${var.project_name}-cluster-sg"
  }
}

# Security Group for the worker nodes
resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_name}-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  # nodes can talk to each other freely
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true # "self" means other resources in this same security group
  }

  # allow control plane to talk to nodes
  ingress {
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  # allow all outbound traffic from nodes
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-nodes-sg"
  }
}

# OIDC Provider — needed for service accounts to assume IAM roles
# This is required for ExternalDNS, CertManager, and AWS Load Balancer Controller
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}