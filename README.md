# ansible-dcos

NOTE: This setup assumes pre-existing VPC, with designated security groups, Azs, subnets. However, you can modify it to also create all pre-requistites (VPC, ELB, SGs etc ...).

This ansible playbook installs DC/OS and should run on CentOS/RHEL 7. The installation steps are based on the [Advanced Installation Guide](https://docs.mesosphere.com/latest/administration/installing/custom/advanced/) of DC/OS.

## Steps for installation

- (on a MacOS) `brew install terraform` && `brew install ansible`

- (on Linux) Manually install Terraform and Ansible before continuing

- Create an SSH keypair in AWS CLI (IAM) and download .pem file

- Copy `{keypair}.pem` file to `~/.ssh` and `chmod 0600 {keypair}.pem`

- Execute `ssh-add {keypair}.pem`

- Copy `./ansible.cfg.example` to `./ansible.cfg`

- Add the line `ssh_args = -i ~/.ssh/{keypair}.pem` to the file `./ansible.cfg` to specify the ssh key for Ansible

- Copy the directory `group_vars/all.example` to `group_vars/all`.

- The file `group_vars/all/setup.yaml` is for configuring DC/OS. You have to fill in the variables that match your preferred configuration. The variables are explained within the example below:

```
---
# Name of the DC/OS Cluster
cluster_name: demo

# Download URL for DC/OS (You may need to modify the URL to pin the version you want to unstall!)
dcos_download: https://downloads.dcos.io/dcos/stable/dcos_generate_config.sh

# Install latest operating system updates
# options: true, false
system_updates: false

# Configuration for the Exhibitor Storage Backend
# options: aws_s3, static
exhibitor: static

# AWS S3 Credentials (only needed for exhibitor: aws_s3)
aws_access_key_id: "******"
aws_secret_access_key: "******"
aws_region: us-west-2
s3_bucket: bucket-name

# This parameter specifies your desired security mode. (only for Mesosphere Enterprise DC/OS)
# options: disabled, permissive, strict
security: permissive

# Configure rexray to enable support of external volumes (only for Mesosphere Enterprise DC/OS)
# Note: Set rexray_config_method: file and edit ./roles/workstation/templates/rexray.yaml.j2 for a custom rexray configuration
# options: empty, file
rexray_config_method: empty

# Enterprise or OSS? Depends on whether you've bought the license or not ;-)
enterprise_dcos: false

# Customer Key (only for Mesosphere Enterprise DC/OS)
customer_key: "########-####-####-####-############"

# DC/OS credentials (only for Mesosphere Enterprise DC/OS)
superuser_username: admin
superuser_password_hash: "$6$rounds=656000$8CXbMqwuglDt3Yai$ZkLEj8zS.GmPGWt.dhwAv0.XsjYXwVHuS9aHh3DMcfGaz45OpGxC5oQPXUUpFLMkqlXCfhXMloIzE0Xh8VwHJ." # Password: admin
```

- Copy `terraform/aws.example.tf` to `./aws.tf`

- Run `terraform get` to retrieve the modules

- Run `terraform apply` to create the nodes on AWS. (Note: That command will automatically trigger a script `prepare-ansible.sh` to retrieve the IP configuration for your nodes.)

- Run `ansible-playbook install.yml` to apply the Ansible playbook

- Run `ansible-playbook configure.yml` to apply additional roles (e.g. Install Marathon-LB)

## Steps for uninstallation

This uninstall playbook runs a cleanup script on the nodes.

- Run `ansible-playbook uninstall.yml`

You can delete the AWS stack by running the command below.

- Run `terraform destroy`
