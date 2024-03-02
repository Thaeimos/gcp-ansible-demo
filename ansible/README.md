# Description
Ansible configs for VMs in GCP.


# Make this work
- Configure the proper project and service account values [here](./inventory/app.gcp.yml).
- Execute the following commands:

```bash
ansible-inventory --list
ansible -i hosts all -m ping
ansible all -i hosts --limit host2 -a "/bin/echo hello"
ansible-playbook playbooks/intro-playbook.yml
ansible-galaxy init rafa-test
```