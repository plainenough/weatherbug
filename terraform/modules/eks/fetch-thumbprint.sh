#!/bin/bash

OIDC_URL=$1
DOMAIN=$(echo "${OIDC_URL}" | sed -e 's/^https:\/\///' -e 's/\/.*$//')

# Fetch certificate with a timeout of 10 seconds
CERT=$(timeout 10s openssl s_client -showcerts -servername "${DOMAIN}" -connect "${DOMAIN}:443" < /dev/null 2>/dev/null | openssl x509)
if [ -z "$CERT" ]; then
  echo "Error: Failed to fetch certificate from ${DOMAIN}"
  exit 1
fi

# Extract thumbprint
THUMBPRINT=$(echo "$CERT" | openssl x509 -fingerprint -noout -sha1 | sed 's/^.*=//' | sed 's/://g')
if [ -z "$THUMBPRINT" ]; then
  echo "Error: Failed to extract thumbprint"
  exit 1
fi
# Check thumbprint length
if [ ${#THUMBPRINT} -ne 40 ]; then
  echo "Error: Thumbprint length is not 40 characters. Got: ${#THUMBPRINT}"
  exit 1
fi

echo "{\"thumbprint\": \"${THUMBPRINT}\"}" 