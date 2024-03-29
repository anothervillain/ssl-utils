#!/bin/bash

# Define ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

analyze_http_security_headers() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: $0 <domain> [port]${RESET}"
        echo -e "${YELLOW}Port defaults to 443 if not specified.${RESET}"
        return
    fi

    local DOMAIN=$1
    local PORT=${2:-443} # Default to port 443 if not specified

    echo -e "${GREEN}\nAnalyzing HTTP security headers for ${DOMAIN}:${PORT}...\n${RESET}"

    # Fetch headers using curl and filter for security-related headers
    local headers
    headers=$(curl -s -I "https://${DOMAIN}:${PORT}")

    # Define an array of security headers to check
    declare -a SECURITY_HEADERS=("Strict-Transport-Security" "Content-Security-Policy" "X-Frame-Options" "X-Content-Type-Options" "Referrer-Policy" "Permissions-Policy")

    for header in "${SECURITY_HEADERS[@]}"; do
        echo -n "${header}: "
        if echo "$headers" | grep -i "$header"; then
            : # Found, grep command has already printed the header
        else
            echo -e "${RED}Not Found\n${RESET}"
        fi
    done
}

analyze_http_security_headers "$1" "$2"
