#!/usr/bin/env bash
JQ_COMMAND="docker run -i --rm asannou/jq"
#brew install vault
#TODO convert to vault to docker
VAULT_ADDR="https://localhost:8200/"
VAULT_KEYS=$(vault operator init -tls-skip-verify -format=json | ${JQ_COMMAND} .)

echo "Store this information privately"
echo ${VAULT_KEYS}

echo "Unsealing vault"
vault operator unseal -tls-skip-verify $(echo ${VAULT_KEYS} | ${JQ_COMMAND} -r .unseal_keys_b64[0])
vault operator unseal -tls-skip-verify $(echo ${VAULT_KEYS} | ${JQ_COMMAND} -r .unseal_keys_b64[1])
vault operator unseal -tls-skip-verify $(echo ${VAULT_KEYS} | ${JQ_COMMAND} -r .unseal_keys_b64[2])
echo "vault is unsealed"

echo "Login to vault"
echo ${VAULT_KEYS} | ${JQ_COMMAND} -r .root_token | vault login -tls-skip-verify -

echo "Enabling database plugin"
vault secrets enable -tls-skip-verify -path=dbs database

echo "Adding postgres connection information"
vault write -tls-skip-verify dbs/config/mydb \
  plugin_name=postgresql-database-plugin \
  connection_url='postgresql://{{username}}:{{password}}@database:5432/mydb' \
  allowed_roles=mydb-admin,mydb-user \
  username="admin" \
  password="secret" \
  verify_connection=false

echo "Adding admin role"
vault write -tls-skip-verify dbs/roles/mydb-admin \
  db_name=mydb \
  default_ttl=5m \
  max_ttl=1h \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' \
                         VALID UNTIL '{{expiration}}'; \
                         GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"

echo "Adding user role"
vault write -tls-skip-verify dbs/roles/mydb-user \
  db_name=mydb \
  default_ttl=1h \
  max_ttl=24h \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' \
                         VALID UNTIL '{{expiration}}'; \
                         GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"

echo "Create database admin policy"
vault policy write -tls-skip-verify database-admin ./config/db_admin_policy.hcl

echo "Create database user policy"
vault policy write -tls-skip-verify database-user ./config/db_user_policy.hcl

