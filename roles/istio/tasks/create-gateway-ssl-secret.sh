#!/bin/bash

set -e
sleep 10
ISTIO_INGRESS=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}');
ISTIO_INGRESS+=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}');
echo $ISTIO_INGRESS
[ -z ${secret} ] && secret=istio-ingressgateway-certs
[ -z ${casecret} ] && casecret=istio-ingressgateway-ca-certs
[ -z ${namespace} ] && namespace=istio-system
[ -z ${service} ] && service=istio-ingressgateway
[ -z ${host} ] && host=$ISTIO_INGRESS
echo service: ${service}
echo namespace: ${namespace}
echo secret: ${secret}
echo host: ${host}
if [ ! -x "$(command -v openssl)" ]; then
    echo "openssl not found"
    exit 1
fi
tmpdir=$(mktemp -d)
echo "creating certs in tmpdir ${tmpdir} "
cat <<EOF >> ${tmpdir}/csr.conf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${service}
DNS.2 = ${service}.${namespace}
DNS.3 = ${service}.${namespace}.svc
DNS.4 = ${service}.${namespace}.svc.cluster
DNS.5 = ${service}.${namespace}.svc.cluster.local

EOF
# Create CA and Server key/certificate
openssl genrsa -out ${tmpdir}/ca.key 2048
openssl req -x509 -newkey rsa:2048 -key ${tmpdir}/ca.key -out ${tmpdir}/ca.crt -days 365 -nodes -subj "/CN=${host}"

openssl genrsa -out ${tmpdir}/server.key 2048
openssl req -new -key ${tmpdir}/server.key -subj "/CN=${host}" -out ${tmpdir}/server.csr -config ${tmpdir}/csr.conf

# Self sign
openssl x509 -req -days 365 -in ${tmpdir}/server.csr -CA ${tmpdir}/ca.crt -CAkey ${tmpdir}/ca.key -CAcreateserial -out ${tmpdir}/server.crt -extfile ${tmpdir}/csr.conf

# create the secret with server cert/key
# kubectl create secret tls ${casecret} \
#         --key=${tmpdir}/ca.key \
#         --cert=${tmpdir}/ca.crt \
#         --dry-run=client -o yaml |
#     kubectl -n ${namespace} apply -f -

kubectl create secret tls ${secret} \
        --key=${tmpdir}/server.key \
        --cert=${tmpdir}/server.crt \
        --dry-run=client -o yaml |