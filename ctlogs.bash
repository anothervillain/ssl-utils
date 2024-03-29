#!/bin/bash

# Define ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

verify_certificate_ct_logs() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: $0 DOMAIN${RESET}"
        return 1
    fi

    local DOMAIN=$1

    echo -e "${GREEN}Verifying certificate in Certificate Transparency logs for ${DOMAIN}...${RESET}"

    if ! command -v curl &>/dev/null; then
        echo -e "${RED}Error: curl is required to check CT logs and is not installed.${RESET}"
        return 1
    fi

    # Using crt.sh to check the CT logs
    local RESPONSE=$(curl -s "https://crt.sh/?q=${DOMAIN}&output=json")

    if [ -z "$RESPONSE" ]; then
        echo -e "${RED}No certificates found for ${DOMAIN} in CT logs or unable to query crt.sh.${RESET}"
        return 1
    fi

    # JASON parsing the respnse
    echo "$RESPONSE" | jq '.'

    return 0
}

# Example usage of the function
verify_certificate_ct_logs "$1"
echo ""
