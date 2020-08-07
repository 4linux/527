CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';
GRANT SELECT ON wordpress.* TO '{{name}}'@'%';
