# Terraform

Install and configure Terraform as documented [here](https://github.com/artsy/infrastructure#terraform)

- Make changes to `*.tf` files describing changes to resources rather than modifying them directly in EC2.

- To stage changes before applying, run `terraform plan -out=./changes.tfplan`

- To apply changes, run `terraform apply changes.tfplan`
