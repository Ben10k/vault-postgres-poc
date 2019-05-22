#!/usr/bin/env bash
JQ_COMMAND="docker run -i --rm asannou/jq"
#brew install vault
#TODO convert to vault to docker
export VAULT_ADDR="http://localhost:8200/"
export VAULT_KEYS=$(vault operator init -format=json | ${JQ_COMMAND} .)

echo "Store this information privately"
echo ${VAULT_KEYS}

echo "Unsealing vault"
vault operator unseal $(echo ${VAULT_KEYS} | ${JQ_COMMAND} -r .unseal_keys_b64[0])
vault operator unseal $(echo ${VAULT_KEYS} | ${JQ_COMMAND} -r .unseal_keys_b64[1])
vault operator unseal $(echo ${VAULT_KEYS} | ${JQ_COMMAND} -r .unseal_keys_b64[2])
echo "vault is unsealed"

echo "Login to vault"
echo ${VAULT_KEYS} | ${JQ_COMMAND} -r .root_token | vault login -

echo "Enabling database plugin"
vault secrets enable -path=dbs database

echo "Adding postgres connection information"
vault write dbs/config/mydb \
  plugin_name=postgresql-database-plugin \
  connection_url='postgresql://{{username}}:{{password}}@database:5432/mydb' \
  allowed_roles=mydb-admin,mydb-user \
  username="admin" \
  password="secret" \
  verify_connection=false

echo "Adding admin role"
vault write dbs/roles/mydb-admin \
  db_name=mydb \
  default_ttl=5m \
  max_ttl=1h \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' \
                         VALID UNTIL '{{expiration}}'; \
                         GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"

echo "Adding user role"
vault write dbs/roles/mydb-user \
  db_name=mydb \
  default_ttl=1h \
  max_ttl=24h \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' \
                         VALID UNTIL '{{expiration}}'; \
                         GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"

echo "Create database admin policy"
vault policy write database-admin ./config/db_admin_policy.hcl

echo "Create database user policy"
vault policy write database-user ./config/db_user_policy.hcl

echo "Create app admin policy"
vault policy write app-admin ./config/app_admin_policy.hcl

echo "Create app developer user policy"
vault policy write app-dev ./config/app_developer_policy.hcl

echo "Enable ssh plugin"
vault secrets enable ssh

echo "Enable ssh otp for developer"
vault write ssh/roles/developer key_type=otp default_user=administrator cidr_list=0.0.0.0/0

echo "Enable ssh otp for root"
vault write ssh/roles/admin key_type=otp default_user=root cidr_list=0.0.0.0/0

echo "Enable userpass"
vault auth enable userpass

echo "Create db_admin user"
vault write auth/userpass/users/db_admin password=Password1 policies=database-admin

echo "Create app_admin user"
vault write auth/userpass/users/app_admin password=Password1 policies=app-admin

echo "Create developer user"
vault write auth/userpass/users/developer password=Password1 policies=app-dev,database-user
