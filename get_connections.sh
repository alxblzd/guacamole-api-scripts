#!/bin/bash
set -euo pipefail

GUACAMOLE_URL="http://localhost:8080/guacamole"
USERNAME="api_user"
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

echo "Token obtained: $AUTH_TOKEN"
echo "Associated data source: $DATA_SOURCE"

echo "Retrieving connections..."
CONNECTIONS=$(curl -s -X GET "${GUACAMOLE_URL}/api/session/data/${DATA_SOURCE}/connections" \
    -H "Guacamole-Token: ${AUTH_TOKEN}")

echo "Available connections list:"
echo "$CONNECTIONS" | jq