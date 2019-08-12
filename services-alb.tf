resource "aws_lb" "kubernetes_services_alb" {
  name               = "terrakube-services-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [ aws_security_group.services_alb_sg.id ]
  subnets            = aws_subnet.terrakube_public_subnets.*.id
  tags = {
    Name = "terrakube-services-alb"
  }
}

resource "aws_lb_listener" "kube_services_alb_listener" {
  load_balancer_arn = aws_lb.kubernetes_services_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.services_alb_acm_certificate.arn
  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.kube_services_alb_target_group_traefik.arn
  }
}

resource "aws_lb_target_group" "kube_services_alb_target_group_traefik" {
  name     = "terrakube-services-tg-traefik"
  port     = 30035
  protocol = "HTTP"
  vpc_id   = aws_vpc.terrakube_vpc.id
  health_check {
    port = 30036
    matcher = "200"
    interval = 10
    path = "/ping"
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "traefik_alb_attachment" {
  count = var.worker_count
  target_group_arn = aws_lb_target_group.kube_services_alb_target_group_traefik.arn
  target_id        = aws_instance.kube_worker.*.id[count.index]
  port             = 30035
}
