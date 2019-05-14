# Saugus PostgreSQL diegimas naudojant Docker konteinerizacij1 bei Hashicorp Vault

Darbas susideda iš trijų komponenų:
* **postgres-docker** direktorijoje yra scriptai PostgreSQL DBVS SSL
  sertifikatų sugeneraimui bei inicializavimui bei docker-compose failas
  skirtas paleisti pačią DBVS

* **vault-docker** direktorijoje yra scriptas sugeneruoti Vault
  reikalingus SSL sertifikatus bei Vault konfigūracijos failai,
  docker-compose failas skirtas paleisti patį Vault bei scriptas Vault
  inicializavimui ir sukonfigūravimui

* **vault-example** direktorijoje yra pavyzdinis java projektas skirtas
  išbandyti šią Vault bei PostgreSQL integraciją

## PostgreSQL diegimas
* Įeiname į **postgres-docker** direktoriją 
```bash
cd postgres-docker
```

* Paleidžiame SSL generavimo skriptą
```bash
./scripts/setup-ssl
```

* Paleidžiame DBVS 
```bash
docker-compose up
```

## Hashicorp Vault diegimas
* Įeiname į **vault-docker** direktoriją 
```bash
cd vault-docker
```

* Paleidžiame SSL generavimo skriptą
```bash
./scripts/setup-ssl.sh
```

* Paleidžiame Vault 
```bash
docker-compose up
```

* Paleidžiame Vault diegimo scriptą
```bash
docker-compose ./setup-vault.sh
```

## Pavyzdinės programos paleidimas
* Įeiname į **vault-example** direktoriją 
```bash
cd vault-docker
```
* Paleidžiame programą pirma sugeneruodami Vault prieigos žetoną
```bash
VAULT_TOKEN=$(vault token create -tls-skip-verify -policy=database-user -format=json|jq -r .auth.client_token) ./gradlew run
```
