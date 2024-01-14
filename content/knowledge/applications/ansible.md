---
title: Ansible
summary: Notes on working with Ansible
---

## Run playbook without inventory file

```sh
ansible-playbook --connection=local --inventory xxx.xxx.xxx.xxx, playbook.yml # be aware of the comma
ansible all -i localhost, -m setup -c local
```

## Output shell command

```yaml
- name: debug
  shell: ls -al /var/www/
  register: out

- name: out
  debug:
    var: out.stdout_lines
```

## Get a list of facts

```sh
ansible -m setup localhost | sed '1c {' | jq '.ansible_facts | keys'
# alternatively | python -mjson.tool
```

## Ansible playbook waiting for reboot of target

{{< alert >}}
UPDATE: Since Ansible 2.7 there is a [reboot module](https://docs.ansible.com/ansible/devel/modules/reboot_module.html)
{{< /alert >}}

Sometimes a reboot of a machine during Ansible operation is required. Reboot results in a lost ssh connection.

Here is a way how to properly tell Ansible to handle a machines reboot in the middle of its operation without failing.

The following playbook snippet reconfigures the network (especially the IP), performs a reboot of the server while waiting for it to come back with its new IP address. `host_name` and `ip_address` must be provided from a external call.

```yaml
---
- name: Configure interface
  template:
    src: etc/interfaces.j2
    dest: /etc/network/interfaces
    owner: root
    group: root
    mode: "u=rw,g=r,o=r"

- name: Set hostname
  hostname:
    name: "{{ host_name }}"
  tags: [hostname]

- name: Reboot Machine
  shell: sleep 2 && shutdown -r now "Ansible reboot"
  async: 1
  poll: 0
  ignore_errors: true

- name: Wait for the remote network interface to come back up
  local_action:
    module: wait_for
    host: "{{ ip_address }}"
    port: 22
    delay: 30
    timeout: 300
    state: started
  become: false
  register: wait_result

- name: Change ansible_ssh_host to new ip for further connections
  set_fact:
    ansible_ssh_host: "{{ ip_address }}"

- name: Interface configuration finished
  debug:
    msg: "Interface configuration finished"
  when: wait_result|succeeded
```

## Ansible role testing with Docker and Molecule

### Requirements

1. Ansible
1. Docker
1. pip install molecule, docker-py, testinfra

### Big Picture

{{< mermaid class="text-center">}}
graph LR
A[Ansible Role] --> B((Molecule))
click A "https://www.ansible.com/" "Ansible Homepage"
click B "https://github.com/metacloud/molecule" "Molecule Homepage"
B --> C[Docker Container]
click B "https://www.docker.com/" "Docker Homepage"
B --> D[Play Playbook]
B --> E[Testinfra]
click B "https://github.com/philpep/testinfra" "Testinfra Homepage"
B --> F[Clean up]
{{< /mermaid >}}

### molecule.yml

```yml
---
dependency:
  name: galaxy
driver:
  name: docker
lint:
  name: yamllint
platforms:
  - name: foo
    image: centos/systemd
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    privileged: true
    override_command: false
    exposed_ports:
      - 80/udp
      - 80/tcp
    published_ports:
      - 0.0.0.0:8080:80/udp
      - 0.0.0.0:8080:80/tcp
    networks:
      - name: foo
    pre_build_image: false
  - name: foo-db
    image: mysql:5.7
    override_command: false
    env:
      MYSQL_ROOT_PASSWORD: admin
      MYSQL_DATABASE: admin
      MYSQL_USER: admin
      MYSQL_PASSWORD: admin
    exposed_ports:
      - 3306/udp
      - 3306/tcp
    networks:
      - name: foo
    pull: true
    pre_build_image: true
scenario:
  name: default
  test_sequence:
    - lint
    - destroy
    - dependency
    - syntax
    - create
    - prepare
    - converge
    - idempotence
    - side_effect
    - verify
    - destroy
provisioner:
  name: ansible
  lint:
    name: ansible-lint
verifier:
  name: testinfra
  lint:
    name: flake8
```
