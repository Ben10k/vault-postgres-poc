path "dbs/creds/mydb-user" {
  capabilities = ["read"]
}
path "dbs/creds/mydb-user/*" {
  capabilities = ["read"]
}