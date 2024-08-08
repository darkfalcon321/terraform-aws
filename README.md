# terraform-aws

This project outlines how terraform is used to deploy Cloud resources; particularly AWS. The instance would have a script to be run upon instance initialization in `userdata.tpl`. The instance type can be changed depending upon the AMI in `datasources.tf`. Some of the instructions would be given on the assumption that this project would be done in vscode

### ARCHITECTURE


<img src="https://github.com/user-attachments/assets/73d1c00f-8c09-4f9c-8f20-db053962ffe7" width="400" height="400" />

### REQUIREMENT
* Install `AWS ToolKit` in the Extention.
* Ensure that Terraform is also installed in the Extention

### SSH KEY GENERATION 
Its automated. Check the folder `~/.ssh/mtckey`. 

### CREDENTIAL SETTING
The Credentials file would be in the folder `~/.aws`. Set your account in this folder. It would be recommended to create an account for terraform in AWS and import its access key & secret key. You can either insert through AWS ToolKit or manually in the `config` file.

```
[name_of_acc]
aws_access_key_id = access_key
aws_secret_access_key = secret_key
```

#### P.S
Ensure to download either `linux-ssh-config.tpl` or `windows-ssh-config.tpl` file based on the system being used.
