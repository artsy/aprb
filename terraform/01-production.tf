resource "aws_db_instance" "aprb-production" {
    identifier = "aprb-production"
    name = "aprb_production"

    engine = "postgres"
    engine_version = "9.5.2"

    instance_class = "db.t2.micro"
    storage_type = "gp2"

    allocated_storage = "5"
    multi_az = false

    auto_minor_version_upgrade = true

    option_group_name = "default:postgres-9-5"
    parameter_group_name = "default.postgres9.5"

    db_subnet_group_name = "${data.terraform_remote_state.infrastructure.vpc_production_default_db_subnet_group_id}"
    vpc_security_group_ids = [
        "${data.terraform_remote_state.infrastructure.vpc_production_default_sg_id}"
    ]
    publicly_accessible = true

    username = "aprb_prod"
    # password = ""

    skip_final_snapshot = true

    tags = {
        "workload-type" = "production"
    }

}
