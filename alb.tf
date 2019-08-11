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
  port              = "8443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.services_alb_acm_certificate.arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Internal server error"
      status_code  = "500"
    }
  }
}

resource "aws_lb_target_group" "kube_services_alb_target_group_traefik" {
  name     = "terrakube-services-tg-traefik"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.terrakube_vpc.id
}

resource "aws_lb_target_group_attachment" "traefik_alb_attachment" {
  count = var.worker_count
  target_group_arn = aws_lb_target_group.kube_services_alb_target_group_traefik.arn
  target_id        = aws_instance.kube_worker.*.id[count.index]
  port             = 8080
}



resource "aws_lb_target_group" "kube_services_alb_target_group_dashboard" {
  name     = "terrakube-services-tg-dashboard"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.terrakube_vpc.id
}

resource "aws_lb_target_group_attachment" "dashboard_alb_attachment" {
  count = var.worker_count
  target_group_arn = aws_lb_target_group.kube_services_alb_target_group_dashboard.arn
  target_id        = aws_instance.kube_worker.*.id[count.index]
  port             = 443
}

resource "aws_lb_listener_rule" "alb_forward_to_traefik" {
  listener_arn = aws_lb_listener.kube_services_alb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kube_services_alb_target_group_traefik.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/traefik/*"]
  }
}

resource "aws_lb_listener_rule" "alb_forward_to_dashboard" {
  listener_arn = aws_lb_listener.kube_services_alb_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kube_services_alb_target_group_dashboard.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/dashboard/*"]
  }
}