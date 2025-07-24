output "master-nodes-ips" {
  value = aws_instance.master[*].public_ip
}

output "ha-proxy" {
  value = aws_instance.load-balancer[*].public_ip
}

output "worker-nodes-ips" {
  value = aws_instance.workers[*].public_ip
}

output "etcd-nodes-ips" {
  value = aws_instance.etcd[*].public_ip
}
