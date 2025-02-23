#!/bin/bash
set -euo pipefail

GUACAMOLE_URL="http://localhost:8080/guacamole"
USERNAME="guacadmin"
PASSWORD="CHANGEPASSWORD"

for cmd in jq curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "$cmd is not installed. Installing..."
        sudo apt update && sudo apt install -y "$cmd"
    fi
done

echo "Authenticating..."
TOKEN_RESPONSE=$(curl -s -X POST "${GUACAMOLE_URL}/api/tokens" \
    -d "username=${USERNAME}" \
    -d "password=${PASSWORD}")

AUTH_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.authToken')
DATA_SOURCE=$(echo "$TOKEN_RESPONSE" | jq -r '.dataSource')

if [ "$AUTH_TOKEN" == "null" ] || [ -z "$AUTH_TOKEN" ]; then
    echo "Authentication error. Please check your credentials."
    exit 1
fi

echo "Token obtained: ${AUTH_TOKEN}"
echo "Associated data source: ${DATA_SOURCE}"

echo "Retrieving the list of connections..."
CONNECTIONS_JSON=$(curl -s -X GET "${GUACAMOLE_URL}/api/session/data/${DATA_SOURCE}/connections" \
    -H "Guacamole-Token: ${AUTH_TOKEN}")

echo "Existing connections list:"
echo "$CONNECTIONS_JSON" | jq

CONNECTION_IDS=$(echo "$CONNECTIONS_JSON" | jq -r 'keys[]')

for id in $CONNECTION_IDS; do
    echo "Deleting connection with ID: $id"
    DELETE_RESPONSE=$(curl -s -X DELETE "${GUACAMOLE_URL}/api/session/data/${DATA_SOURCE}/connections/${id}" \
        -H "Guacamole-Token: ${AUTH_TOKEN}")
    echo "Response: $DELETE_RESPONSE"
done

echo "All connections have been deleted."
