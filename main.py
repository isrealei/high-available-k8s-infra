import json 

with open('data.json', 'r') as file:
    data = json.load(file)

inventory = {
    "ha-proxy": {"hosts": data["ha-proxy"]["value"]},
    "master-nodes": {"hosts": data["master-nodes-ips"]["value"]},
    "worker-nodes": {"hosts": data["worker-nodes-ips"]["value"]},
}

with open("dynamic_inventory.json", "w") as f:
    json.dump(inventory, f, indent=2)
