<<<<<<< HEAD
# TERRAFORM REQUIRED PROVIDERS
provider "aws" {
  region  = "us-east-1"
  profile = "terraform"
}
    
# VPC MODULE
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  name                 = "trend-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets      = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway   = true
}

# EC2 INSTANCE FOR JENKINS
resource "aws_instance" "jenkins" {
  ami           = "ami-0fa3fe0fa7920f68e"  # Amazon Linux 2
  instance_type = "t3.medium"
  subnet_id     = module.vpc.public_subnets[0]

  user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
curl -fsSL https://pkg.jenkins.io/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
sudo systemctl start jenkins
EOF

  tags = {
    Name = "jenkins-server"
=======
# PROVIDER

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "trend-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a","us-east-1b","us-east-1c"]
  public_subnets  = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# IAM ROLE FOR EC2 (Jenkins)

resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_attach" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}

# SECURITY GROUP FOR EC2

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow HTTP, SSH"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
>>>>>>> 2736d7d (Initial commit of Trend_app)
  }
}


<<<<<<< HEAD
# EKS CLUSTER MODULE
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10.0"

  name               = "trend-eks"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets
  kubernetes_version = "1.29"
}


# IAM ROLE FOR EKS NODE GROUP
=======
# EC2 INSTANCE FOR JENKINS
resource "aws_instance" "jenkins" {
  ami           = "ami-0fa3fe0fa7920f68e"
  instance_type = "t3.micro"
  key_name      = "finalproject_kp"

  subnet_id = element(module.vpc.public_subnets, 0)

  vpc_security_group_ids = [
    aws_security_group.jenkins_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

  tags = {
    Name = "Jenkins-Server"
  }
}

# IAM ROLE FOR EKS NODE GROUP

>>>>>>> 2736d7d (Initial commit of Trend_app)
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
<<<<<<< HEAD
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach managed policies for worker nodes
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}


# EKS NODE GROUP
resource "aws_eks_node_group" "default" {
  cluster_name    = module.eks.cluster_id
  node_group_name = "default"
=======
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group_attach" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# EKS CLUSTER

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10.0"   

  name                  = "trend-eks"
  kubernetes_version    = "1.29"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnets
}

# EKS NODE GROUP

resource "aws_eks_node_group" "default" {
  cluster_name    = module.eks.cluster_name     # FIXED
  node_group_name = "default"

>>>>>>> 2736d7d (Initial commit of Trend_app)
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

<<<<<<< HEAD
  instance_types = ["t3.medium"]
  ami_type       = "AL2_x86_64"
}
=======
  instance_types = ["t3.micro"]     
  ami_type       = "AL2_x86_64"
}



# OUTPUTS

output "jenkins_public_ip" {
  description = "Jenkins EC2 public IP"
  value       = aws_instance.jenkins.public_ip
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}


>>>>>>> 2736d7d (Initial commit of Trend_app)
