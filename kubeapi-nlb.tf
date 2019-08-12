resource "aws_lb" "kubeapi_nlb" {
  internal           = false
  load_balancer_type = "network"
  name               = "terrakube-kubeapi-nlb"
  subnets            = aws_subnet.terrakube_public_subnets.*.id
  tags = {
    Name = "terrakube-kubeapi-nlb"
  }
}

resource "aws_lb_listener" "kubeapi_nlb_listener" {
  load_balancer_arn = aws_lb.kubeapi_nlb.arn
  port              = var.kubeapi_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kube_api.arn
  }
}

resource "aws_lb_target_group" "kube_api" {
  name     = "terrakube-kubeapi-target-group"
  port     = 6443
  protocol = "TCP"
  vpc_id   = aws_vpc.terrakube_vpc.id
  health_check {
    protocol = "TCP"
    port = 6443
    interval = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "kube_api_lb_attachment" {
  count = var.master_count
  target_group_arn = aws_lb_target_group.kube_api.arn
  target_id        = aws_instance.kube_master.*.id[count.index]
  port             = 6443
}