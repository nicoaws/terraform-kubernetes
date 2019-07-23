resource "aws_lb" "kubeapi_nlb" {
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.terrakube_public_subnets.*.id
  # security_groups    = [ aws_security_group.terrakube_public.id,"${aws_security_group.terrakube_private.id ]
  tags = {
    name = "terrakube-kubeapi-nlb"
  }
}

resource "aws_lb_listener" "kubeapi_nlb_listener" {
  load_balancer_arn = "${aws_lb.kubeapi_nlb.arn}"
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.kube_api.arn}"
  }
}

resource "aws_lb_target_group" "kube_api" {
  name     = "terrakube-kubeapi-target-group"
  port     = 6443
  protocol = "TCP"
  vpc_id   = "${aws_vpc.terrakube_vpc.id}"
}

resource "aws_lb_target_group_attachment" "kube_api_lb_attachment" {
  count = var.master_count
  target_group_arn = aws_lb_target_group.kube_api.arn
  target_id        = aws_instance.kube_master.*.id[count.index]
  port             = 6443
}