resource "aws_key_pair" "terrakube-keypair" {
  key_name = "terrakube-keypair"
  public_key = "${file(var.public_key_path)}"
}
