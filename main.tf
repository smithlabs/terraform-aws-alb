# ---------------------------------------------------------------------------------------------------------------------
# VERSIONING
# This project was written for Terraform 0.13.x
# See 'Upgrading to Terraform v0.13' https://www.terraform.io/upgrade-guides/0-13.html
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.13"
}

# ---------------------------------------------------------------------------------------------------------------------
# PROVIDER - DELETE LATER
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "us-east-1"

  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE APPLICATON LOAD BALANCER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb" "alb" {
  name            = var.alb_name
  security_groups = [aws_security_group.alb.id]
  subnets         = var.subnet_ids
}

# ---------------------------------------------------------------------------------------------------------------------
# HTTP LISTENER - REDIRECT ALL HTTP -> HTTPS WITH 301 REDIRECT
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb_listener" "alb_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# HTTPS LISTENER - SEND TRAFFIC TO BACKEND APPLICATION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb_listener" "alb_https" {
  load_balancer_arn = aws_alb.alb.arn
  certificate_arn   = var.acm_arn
  port              = "443"
  protocol          = "HTTPS"

  # Default action, 
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.backend.arn
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ALB TARGET GROUP - BACKEND SERVERS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_alb_target_group" "backend" {
  name     = "${var.alb_name}-backend"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  deregistration_delay = 0

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = "3"
    port                = "8080"
    path                = "/health"
    protocol            = "HTTP"
    interval            = 10
    matcher             = "200"
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP THAT CONTROLS WHAT TRAFFIC CAN GO IN AND OUT OF THE ALB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name = var.alb_name
}

# ---------------------------------------------------------------------------------------------------------------------
# ADDITIONAL CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
