#!/bin/bash
set -euo pipefail

GUACAMOLE_URL="http://localhost:8080/guacamole"
USERNAME="api_user"
PASSWORD="CHANGEPASSWORD"


usage() {
    echo "Usage: $0 -f /path/to/connections.json"
    exit 1
}

while getopts "f:" opt; do
    case $opt in
        f)
            CONNECTIONS_FILE=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "${CONNECTIONS_FILE:-}" ]; then
    usage
fi

if [ ! -f "$CONNECTIONS_FILE" ]; then
    echo "Error: File '$CONNECTIONS_FILE' not found."
    exit 1
fi


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

CONNECTION_COUNT=$(jq 'length' "$CONNECTIONS_FILE")
echo "Number of connections to import: ${CONNECTION_COUNT}"

for (( i=0; i<CONNECTION_COUNT; i++ )); do
    echo "Creating connection $((i+1))..."
    CONNECTION_PAYLOAD=$(jq -c ".[$i]" "$CONNECTIONS_FILE")
    
    CREATE_RESPONSE=$(curl -s -X POST "${GUACAMOLE_URL}/api/session/data/${DATA_SOURCE}/connections" \
        -H "Guacamole-Token: ${AUTH_TOKEN}" \
        -H "Content-Type: application/json" \
        --data-binary "${CONNECTION_PAYLOAD}")
    
    echo "Response for connection $((i+1)):"
    echo "$CREATE_RESPONSE" | jq
done