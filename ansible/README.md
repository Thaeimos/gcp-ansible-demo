# Description
Ansible configs for VMs in GCP.


# Make this work
- Configure the proper project and service account values [here](./inventory/app.gcp.yml).
- Execute the following commands:

```bash
# List hosts
ansible-inventory --list

# Ping hosts
ansible -i hosts all -m ping

# Random ad-hoc command to all hosts
ansible all -i hosts --limit host2 -a "/bin/echo hello"

# Execute playbook
ansible-playbook playbooks/intro-playbook.yml

# Init role
ansible-galaxy init rafa-test

# Start at a given task
ansible-playbook playbooks/instance-init.yml --start-at-task="web-init : Install UFW"
```