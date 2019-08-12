# resource "aws_lb" "services_nlb" {
#   internal           = false
#   load_balancer_type = "network"
#   subnets            = aws_subnet.terrakube_public_subnets.*.id
#   tags = {
#     Name = "terrakube-services-nlb"
#   }
# }

# resource "aws_lb_listener" "services_nlb_listener" {
#   load_balancer_arn = aws_lb.services_nlb.arn
#   port              = 80
#   protocol          = "TCP"
# #   certificate_arn   = aws_acm_certificate.services_alb_acm_certificate.arn
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.traefik_target_group.arn
#   }
# }

# resource "aws_lb_target_group" "traefik_target_group" {
#   name     = "terrakube-traefik-target-group"
#   port     = 30035
#   protocol = "TCP"
#   vpc_id   = aws_vpc.terrakube_vpc.id
#   health_check {
#     protocol = "TCP"
#     port = 30035
#     interval = 10
#     healthy_threshold = 2
#     unhealthy_threshold = 2
#   }
# }

# resource "aws_lb_target_group_attachment" "services_nlb_attachment" {
#   count = var.worker_count
#   target_group_arn = aws_lb_target_group.traefik_target_group.arn
#   target_id        = aws_instance.kube_worker.*.id[count.index]
#   port             = 30035
# }