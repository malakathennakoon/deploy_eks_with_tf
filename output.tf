output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_region" {
  value = local.region
}
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}