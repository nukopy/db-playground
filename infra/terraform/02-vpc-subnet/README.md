# 02-vpc-subnet

- 前提

```sh
cd step02-vpc-subnet
terraform init -var-file="dev.tfvars"
terraform plan -var-file="dev.tfvars"

# apply
terraform apply -var-file="dev.tfvars"

# apply with auto approve
terraform apply -var-file="dev.tfvars" -auto-approve

# destroy
terraform destroy -var-file="dev.tfvars"

# destroy with auto approve
terraform destroy -var-file="dev.tfvars" -auto-approve
```
