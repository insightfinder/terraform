#!/bin/bash

# apply-config.sh - Apply project configuration to InsightFinder
# This script is called by Terraform to apply project configurations

set -euo pipefail

# Check required environment variables
if [[ -z "${CONFIG_FILE:-}" || -z "${PROJECT_NAME:-}" || -z "${BASE_URL:-}" || -z "${USERNAME:-}" || -z "${PASSWORD:-}" ]]; then
    echo "Error: Missing required environment variables"
    echo "Required: CONFIG_FILE, PROJECT_NAME, BASE_URL, USERNAME, PASSWORD"
    exit 1
fi

echo "=========================================="
echo "Applying configuration for project: $PROJECT_NAME"
echo "Base URL: $BASE_URL"
echo "Username: $USERNAME"
echo "Config file: $CONFIG_FILE"
echo "=========================================="

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

# Function to URL encode password
url_encode() {
    python3 -c "import urllib.parse; print(urllib.parse.quote('$1', safe=''))"
}

# Authenticate and get token (use cookie jar like Python requests.Session)
echo "Getting authentication token..."
ENCODED_PASSWORD=$(url_encode "$PASSWORD")

# Create temporary cookie jar
COOKIE_JAR=$(mktemp)
trap "rm -f $COOKIE_JAR" EXIT

TOKEN_RESPONSE=$(curl --http1.1 -s -c "$COOKIE_JAR" -X POST "$BASE_URL/api/v1/login-check?userName=$USERNAME&password=$ENCODED_PASSWORD" \
    -H "Content-Type: application/json")

if [[ -z "$TOKEN_RESPONSE" ]]; then
    echo "Error: No response from authentication endpoint"
    exit 1
fi

# Extract token from response
TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4 || echo "")

if [[ -z "$TOKEN" ]]; then
    echo "Error: Failed to get authentication token"
    echo "Response: $TOKEN_RESPONSE"
    exit 1
fi
echo "✅ Authentication successful"

# Apply project configuration
echo "Applying project configuration..."

# Read config file content  
CONFIG_CONTENT=$(cat "$CONFIG_FILE")

# Validate JSON
if ! echo "$CONFIG_CONTENT" | python3 -c "import json,sys; json.load(sys.stdin)" > /dev/null 2>&1; then
    echo "Error: Invalid JSON in config file"
    exit 1
fi

# Add verbose curl to see full request/response details, force HTTP/1.1 and use cookies to match Python
APPLY_RESPONSE=$(curl --http1.1 -v -s -b "$COOKIE_JAR" -w "HTTPSTATUS:%{http_code}" -X POST \
    "$BASE_URL/api/v1/watch-tower-setting?projectName=$PROJECT_NAME&customerName=$USERNAME" \
    -H "Content-Type: application/json" \
    -H "X-CSRF-TOKEN: $TOKEN" \
    -d "$CONFIG_CONTENT" 2>&1)

# Parse response
HTTP_STATUS=$(echo "$APPLY_RESPONSE" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
RESPONSE_BODY=$(echo "$APPLY_RESPONSE" | sed -e 's/HTTPSTATUS:.*//')

echo "HTTP Status: $HTTP_STATUS"

# Check if successful
if [[ "$HTTP_STATUS" -eq 200 ]]; then
    echo "✅ Project configuration applied successfully for $PROJECT_NAME"
    echo "Response: $RESPONSE_BODY"
else
    echo "❌ Failed to apply project configuration for $PROJECT_NAME"
    echo "Response: $RESPONSE_BODY"
    exit 1
fi

echo "=========================================="
echo "✅ Configuration application completed for $PROJECT_NAME"
echo "=========================================="