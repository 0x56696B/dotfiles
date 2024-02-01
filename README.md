# Commands

## Discover hosts:

```bash
ansible *host_name* -m ping --ask-vault-password -i inventory/hosts.yaml
```

## Run a playbook against host

```bash
ansible-playbook -K --ask-vault-password -i inventory/hosts.yaml -l *group_from_hosts_file playbooks/*playbook*
```
