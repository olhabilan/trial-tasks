docker-mariadb
=========

An Ansible role to run a MariaDB server as a docker container

Requirements
------------

This role requires Ansible 2.5 or higher.

Role Variables
--------------

mariadb_port: 3036
mariadb_version: 10.2.14
mariadb_container_name: mariadb

Secrets file structure
-------
root_password: ''
mariadb_user: ''
mariadb_password: ''

Dependencies
------------

No other roles from Ansible Galaxy weren't used.

Example Playbook
----------------

An example of how to use the role:

    - hosts: servers
      roles:
         - { role: docker-mariadb, mariadb_version: 10.2.14 }

License
-------

BSD

Author Information
------------------

Olha Bilan