
# Create a VPC
resource "aws_vpc" "allianz_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
    tags = {
        Name = "allianz-vpc"
    }
}

# Create public subnets
resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.allianz_vpc.id
  cidr_block = "10.0.0.0/20"
  availability_zone = "eu-west-3a"
  map_public_ip_on_launch = true
  tags = {
        Name = "allianz-subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.allianz_vpc.id
  cidr_block = "10.0.16.0/20"
  availability_zone = "eu-west-3b"
  map_public_ip_on_launch = true
  tags = {
        Name = "allianz-subnet-2"
  }
}

resource "aws_subnet" "subnet_3" {
  vpc_id     = aws_vpc.allianz_vpc.id
  cidr_block = "10.0.32.0/20"
  availability_zone = "eu-west-3c"
  map_public_ip_on_launch = true
  tags = {
        Name = "allianz-subnet-3"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.allianz_vpc.id
  tags = {
        Name = "allianz-igw"
  }
}       

# Create a route table
resource "aws_route_table" "alllianz_rt" {
  vpc_id = aws_vpc.allianz_vpc.id
  tags = {
        Name = "allianz-public-rt"
  }
  # Create a route to the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  # local route for VPC
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
}
}
 
# Associate the route table with the subnets

resource "aws_route_table_association" "aws_route_table_association_1" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.alllianz_rt.id
}

resource "aws_route_table_association" "aws_route_table_association_2" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.alllianz_rt.id
}

resource "aws_route_table_association" "aws_route_table_association_3" {
  subnet_id      = aws_subnet.subnet_3.id
  route_table_id = aws_route_table.alllianz_rt.id
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "allianz-sales-eks-cluster"
  cluster_version = "1.33"

  cluster_endpoint_public_access = true

  vpc_id                   = aws_vpc.allianz_vpc.id
  subnet_ids               = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id, aws_subnet.subnet_3.id]
  control_plane_subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id, aws_subnet.subnet_3.id]
  tags = {
    environment = "production"
    team        = "sales"
  }
  eks_managed_node_groups = {
    sales = {
      min_size       = 1
      max_size       = 4
      desired_size   = 3
      instance_types = ["t3.medium"]
    }
  }
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::975050243656:role/eks-deployer-role"
      username = "jenkins-user"
      groups   = ["system:masters"]
    }
  ]
}


