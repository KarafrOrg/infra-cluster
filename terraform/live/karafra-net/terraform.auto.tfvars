proxmox_api_url  = "https://198.27.70.67:8006"
proxmox_user     = "terraform@pve"
proxmox_password = "ChangeMe123!"

proxmox_node_ips = [
  "198.27.70.67",    # proxmox-node1
  "135.125.223.213", # proxmox-node3
  "37.187.159.125",  # proxmox-node4
  "37.187.157.64",   # proxmox-node5
]

talos_image_name = "talos.iso"
talos_image_url  = "https://factory.talos.dev/image/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba/v1.12.6/nocloud-amd64.iso"

control_plane = {
  node_count     = 5
  vm_name_prefix = "talos-cp-"
  spec = {
    memory = {
      dedicated = 4096
      floating  = 0
    }
    disk_size = 20
    cpu_cores = 4
  }
}
