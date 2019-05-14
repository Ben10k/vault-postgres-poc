#!/bin/bash
# Creates SSL certificates need for postgres

OUTPUT_FOLDER="$(dirname "$0")/../config"

mkdir -p $OUTPUT_FOLDER

OUTPUT_FOLDER="$(cd "$(dirname "$OUTPUT_FOLDER")"; pwd)/$(basename "$OUTPUT_FOLDER")"

echo "SSL files output folder [$OUTPUT_FOLDER]"


OPENSSL_COMMAND="docker run --rm -it -w /out -v $OUTPUT_FOLDER:/out svagi/openssl"

echo -e "\n\n### Create CA ###"
$OPENSSL_COMMAND req -new -x509 -nodes -newkey rsa -out ca.pem -keyout ca-key.pem -set_serial 01 -batch -subj "/CN=ssl-server"
$OPENSSL_COMMAND rsa -in ca-key.pem -out ca-key.pem

echo -e "\n\n### Create vault server key ###"
$OPENSSL_COMMAND req -new -newkey rsa -keyout server-key.pem -out server-req.pem -passout pass:abcd -subj "/CN=localhost"
$OPENSSL_COMMAND rsa -in server-key.pem -out server-key.pem -passin pass:abcd
$OPENSSL_COMMAND x509 -req -in server-req.pem -CA ca.pem -CAkey ca-key.pem -set_serial 02 -out server-cert.pem

chmod 0600 $OUTPUT_FOLDER/*
