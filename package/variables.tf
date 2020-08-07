variable ec2user {}

variable "userdata_logging" {
  type = string
  default = <<EOF
#!/bin/bash -xe
exec > >(tee -a /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
EOF
}
