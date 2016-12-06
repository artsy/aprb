# Terraform

Install and configure Terraform as documented [here](https://github.com/artsy/infrastructure#terraform)

Install Terragrunt as documented [here](https://github.com/gruntwork-io/terragrunt#install)

- Make changes to `*.tf` files describing changes to resources rather than modifying them directly in EC2.

- To stage changes before applying, run `terragrunt plan -out=./changes.tfplan`

- To apply changes, run `terragrunt apply changes.tfplan`
