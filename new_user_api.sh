#!/bin/bash
set -euo pipefail

GUACAMOLE_URL="http://localhost:8080/guacamole"
USERNAME="guacadmin"
PASSWORD="CHANGEPASSWORD"

NEW_USER="api_user"                            
NEW_USER_PASSWORD="CHANGEPASSWORD"            

for cmd in jq curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "$cmd is not installed. Installing..."
        sudo apt update && sudo apt install -y "$cmd"
    fi
done

echo "Authenticating as admin..."
TOKEN_RESPONSE=$(curl -s -X POST "${GUACAMOLE_URL}/api/tokens" \
    -d "username=${ADMIN_USER}" \
    -d "password=${ADMIN_PASSWORD}")

ADMIN_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.authToken')
DATA_SOURCE=$(echo "$TOKEN_RESPONSE" | jq -r '.dataSource')

if [ -z "$ADMIN_TOKEN" ] || [ "$ADMIN_TOKEN" == "null" ]; then
    echo "Error: Admin authentication failed. Check your credentials."
    exit 1
fi

echo "Admin token obtained: ${ADMIN_TOKEN}"
echo "Data source: ${DATA_SOURCE}"

echo "Creating user ${NEW_USER}..."
CREATE_USER_PAYLOAD=$(cat <<EOF
{
  "username": "${NEW_USER}",
  "password": "${NEW_USER_PASSWORD}",
  "attributes": {}
}
EOF
)

CREATE_USER_RESPONSE=$(curl -s -X POST "${GUACAMOLE_URL}/api/session/data/${DATA_SOURCE}/users" \
    -H "Guacamole-Token: ${ADMIN_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-binary "${CREATE_USER_PAYLOAD}")

echo "User creation response:"
echo "$CREATE_USER_RESPONSE" | jq

echo "Updating system permissions for user ${NEW_USER}..."
SYSTEM_PERMISSIONS_PAYLOAD='[
  {
    "op": "add",
    "path": "/systemPermissions",
    "value": "CREATE_CONNECTION"
  }
]'
UPDATE_SYSTEM_PERMISSIONS_RESPONSE=$(curl -s -X PATCH "${GUACAMOLE_URL}/api/session/data/${DATA_SOURCE}/users/${NEW_USER}/permissions?token=${ADMIN_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-binary "${SYSTEM_PERMISSIONS_PAYLOAD}")

echo "System permissions update response:"
echo "$UPDATE_SYSTEM_PERMISSIONS_RESPONSE" | jq

echo "User ${NEW_USER} created and configured with system permissions for managing connections."
