#!/bin/bash

# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Function to check certificate validity
quick() {
    local domain=$1
    if [ -z "$domain" ]; then
        echo -e "${MAGENTA}You didn't specify a domain.${RESET}" "${GREEN}Please enter a domain name:${RESET}"
        read -r domain
        if [ -z "$domain" ]; then
            echo -e "${RED}Error: No domain provided.${RESET}"
            usage
            return 1
        fi
    fi

    local tmp_cert_file="/tmp/${domain}_cert.pem"
    echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -enddate >"$tmp_cert_file"

    if [ ! -f "$tmp_cert_file" ]; then
        echo -e "${RED}Failed to retrieve certificate for $domain.${RESET}"
        return 1
    fi

    # shellcheck disable=SC2002
    local "end_date"="$(cat "$tmp_cert_file" | cut -d= -f2)"
    local "end_date_seconds"="$(date -d "$end_date" +%s)"
    local "now_seconds"="$(date +%s)"

    rm "$tmp_cert_file"

    if [ "$now_seconds" -gt "$end_date_seconds" ]; then
        echo -e "${RED}Certificate for $domain has expired.${RESET}"
    else
        echo -e "${GREEN}OK! Certificate for ${CYAN}$domain ${GREEN}is valid until ${CYAN}$end_date.${RESET}"
    fi
}

# Main script starts here
if [ $# -eq 0 ]; then
    quick "" # Call valid with an empty string to trigger the prompt
else
    quick "$1"
fi
