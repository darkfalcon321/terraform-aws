add-content -path C:/Users/LENOVO/Documents/Code/Terraform/config -value @'

Host ${hostname}
  HostName ${hostname}
  User ${user}
  IdentityFile ${identityfile}
'@