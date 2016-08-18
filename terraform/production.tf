resource "aws_opsworks_stack" "aprb-production" {
    name = "aprb-production"
    region = "us-east-1"
    service_role_arn = "arn:aws:iam::585031190124:role/aws-opsworks-service-role"
    default_instance_profile_arn = "arn:aws:iam::585031190124:instance-profile/aws-opsworks-ec2-role"
    berkshelf_version = ""
    color = "rgb(45, 114, 184)"
    configuration_manager_version = "12"
    default_os = "Ubuntu 14.04 LTS"
    default_root_device_type = "ebs"
    default_ssh_key_name = "artsyow"
    default_subnet_id = "${terraform_remote_state.infrastructure.output.vpc_production_private_subnet_1b_id}"
    use_custom_cookbooks = "1"
    vpc_id = "${terraform_remote_state.infrastructure.output.vpc_production_id}"
    custom_json = "${file("${path.module}/production.json")}"
    custom_cookbooks_source = {
      type = "s3"
      url = "https://s3.amazonaws.com/artsy-cookbooks/aprb-production.tgz"
    }
}

resource "aws_opsworks_custom_layer" "aprb-backend" {
    name = "aprb-backend"
    short_name = "aprb-backend"
    stack_id = "${aws_opsworks_stack.aprb-production.id}"
    custom_security_group_ids = ["${terraform_remote_state.infrastructure.output.vpc_production_default_sg_id}"]
    elastic_load_balancer = "${aws_elb.aprb-production-http.name}"
    install_updates_on_boot = false
    custom_setup_recipes = ["artsy_apr::setup", "artsy_apr::configure"]
    custom_configure_recipes = ["artsy_apr::configure"]
    custom_deploy_recipes = ["artsy_apr::deploy"]
}

resource "aws_opsworks_application" "aprb-production" {
    name = "aprb"
    stack_id = "${aws_opsworks_stack.aprb-production.id}"
    type = "other"
}

resource "aws_elb" "aprb-production-http" {
    name                        = "aprb-production-http"
    subnets                     = [
                                    "${terraform_remote_state.infrastructure.output.vpc_production_public_subnet_1b_id}",
                                    "${terraform_remote_state.infrastructure.output.vpc_production_public_subnet_1c_id}",
                                    "${terraform_remote_state.infrastructure.output.vpc_production_public_subnet_1d_id}",
                                    "${terraform_remote_state.infrastructure.output.vpc_production_public_subnet_1e_id}"
                                  ]
    cross_zone_load_balancing   = true
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 60
    security_groups             = [
                                    "${terraform_remote_state.infrastructure.output.vpc_production_default_sg_id}",
                                    "${terraform_remote_state.infrastructure.output.production-elb-security-group}"
                                  ]

    listener {
        instance_port      = 80
        instance_protocol  = "tcp"
        lb_port            = 80
        lb_protocol        = "tcp"
    }

    health_check {
        healthy_threshold   = 4
        unhealthy_threshold = 2
        interval            = 30
        target              = "TCP:80"
        timeout             = 10
    }

    depends_on              = ["aws_opsworks_stack.aprb-production"]

}

resource "aws_proxy_protocol_policy" "aprb-production-http-proxy-protocol" {
  load_balancer = "${aws_elb.aprb-production-http.name}"
  instance_ports = ["80"]
}

resource "aws_opsworks_instance" "aprb-production-backend" {
  stack_id = "${aws_opsworks_stack.aprb-production.id}"
  layer_ids = [
    "${aws_opsworks_custom_layer.aprb-backend.id}",
  ]
  instance_type = "t2.small"
  state         = "running"

}
