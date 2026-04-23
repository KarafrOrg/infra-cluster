locals {
  node_ips = [
    for node_name, hosts in data.proxmox_virtual_environment_hosts.nodes : [
      for entry in hosts.entries : entry.address
      if contains(entry.hostnames, node_name)
    ][0]
  ]
}
