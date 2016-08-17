# Terraform

Install Terraform >= v0.6.16

- Put your user AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in your ~/.bash_profile. And source it (`source ~/.bash_profile`).  It should look something like:

```
export AWS_ACCESS_KEY_ID=ASDHA2365236ASDDAS
export AWS_SECRET_ACCESS_KEY=232tgsdfsSDG/sdge3wsd/FGF59
```

- Configure remote state with `terraform remote config -backend=s3 -backend-config="bucket=artsy-terraform" -backend-config="key=aprb/terraform.tfstate" -backend-config="region=us-east-1"`

- Make changes to `*.tf` files describing changes to resources rather than modifying them directly in EC2.

- Note: To plan changes to a resource and its dependencies directly, use the flag `-target={resource}`.  I.e. to target ONLY the apr staging stack, use `-target=aws_opsworks_stack.apr-staging`

- To stage changes before applying, run `terraform plan -out=./changes.tfplan`

- To apply changes, run `terraform apply changes.tfplan`
