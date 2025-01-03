output "master-nodes-ips" {
  value = aws_instance.master[*].public_ip
}

output "ha-proxy" {
  value = aws_instance.ha-proxy[*].public_ip
}

output "worker-nodes-ips" {
  value = aws_instance.workers[*].public_ip
}


# output "ansible_inventory" {
#   value = templatefile("ansible_inventory.tftpl", {
#     ha_proxy      = aws_instance.ha-proxy[*].public_ip
#     master_nodes  = aws_instance.master[*].public_ip
#     worker_nodes  = aws_instance.workers[*].public_ip
#   })
# }


# output "ansible_inventory" {
#   value = join("\n", [
#     "[ha-proxy]",
#     join("\n", aws_instance.ha-proxy[*].public_ip),
#     "",
#     "[master-nodes]",
#     join("\n", aws_instance.master[*].public_ip),
#     "",
#     "[worker-nodes]",
#     join("\n", aws_instance.workers[*].public_ip),
#     ""
#   ])
# }

