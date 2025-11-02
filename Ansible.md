
start ansible from failed task
ansible-playbook -i inventory.ini playbook.yml --start-at-task="Configure WordPress using WP-CLI" \
  --become \
  --become-method=sudo \
  --become-user=root