path "dbs/creds/mydb-admin" {
  capabilities = ["read"]
}
path "dbs/creds/mydb-admin/*" {
  capabilities = ["read"]
}