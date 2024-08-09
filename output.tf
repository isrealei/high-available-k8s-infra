output "master-nodes-ip" {
  value = aws_instance.master[1].public_ip
}

output "master-nodes-ip-2" {
  value = aws_instance.master[0].public_ip
}

output "ha-proxy" {
  value = aws_instance.ha-proxy[0].public_ip
}

output "worker-nodes-ip-0" {
  value = aws_instance.workers[0].public_ip
}

output "worker-nodes-ip-1" {
  value = aws_instance.workers[1].public_ip
}


output "worker-nodes-ip-2" {
  value = aws_instance.workers[2].public_ip
}

output "cluster-entry-point" {
  value = aws_instance.cluster-entry-point.public_ip
}