resource "local_file" "hosts_data" {
  content = data.template_file.hosts_data.rendered
  filename = "scripts/hosts.txt"
}