resource "local_file" "kubernetes_bootstrap" {
  content = data.template_file.kubernetes_bootstrap.rendered
  filename = "scripts/kubernetes-bootstrap.sh"
}