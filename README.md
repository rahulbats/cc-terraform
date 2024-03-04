

### To Run the terraform script do the following steps.


. go to the respective module ( eg : `cd modules/create-topics`)  
. validate the contents of `nonprod.tfvars`   
.  ```terraform init```   
. ```terraform plan```   *IMP : Please Validate the plan*.   
. ```terraform apply --var-file nonprod.tfvars```







