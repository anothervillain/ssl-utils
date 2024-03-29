#!/bin/bash

# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Function for SSL certificate fetch, validation, and domain matching including wildcard handling
fetch() {
    local server_ip="$1"
    local domain="$2"
    local port="${3:-443}" # Default to port 443 if not specified

    # Use curl to perform a head request which also validates the SSL against the system's CA store
    echo -e "${YELLOW}\nChecking SSL certificate for ${domain} at ${server_ip} on port ${port} with system CA bundle:${RESET}"
    local "curl_result"="$(curl --head --silent --fail --connect-to ::"${server_ip}:" "https://${domain}:${port}" 2>&1)"

    if [ $? -ne 0 ]; then
        echo -e "${RED}Error with SSL connection or certificate validation: "$curl_result"${RESET}"
        # If curl fails, there's no need to proceed with extracting certificate details
        return 1
    else
        echo -e "${GREEN}SSL certificate for ${domain} at ${server_ip} passed system CA validation.${RESET}"
    fi

    # Proceed with extracting the certificate details using openssl, as before
    local "cert_info"="$(openssl s_client -servername "${domain}" -connect "${server_ip}:${port}" -showcerts </dev/null 2>/dev/null)"
    local "exp_date"="$(echo "$cert_info" | openssl x509 -noout -enddate | cut -d'=' -f2)"
    echo -e "${GREEN}Certificate for ${domain} at ${server_ip} expires on: ${exp_date}.${RESET}"

    local "san"="$(echo "$cert_info" | openssl x509 -noout -text | grep -A1 "Subject Alternative Name:" | tail -n1)"
    local "domain_pattern"="$(echo "$domain" | sed 's/\./\\./g; s/\*/.*/g')" # Convert to regex: escape dots, replace * with .*
    if [[ "$san" =~ $domain_pattern ]]; then
        echo -e "${GREEN}Domain ${domain} matches one of the certificate Subject Alternative Names.\n${RESET}"
    else
        echo -e "${RED}Mismatch: Domain ${domain} does not match any of the certificate Subject Alternative Names.\n${RESET}"
    fi
}

# Interactive mode function
interactive_mode() {
    while true; do
        echo ""
        echo -n -e "${CYAN}Enter server IP (or 'exit' to quit):\n${RESET} "
        read -r server_ip
        [[ "$server_ip" == "exit" ]] && break

        echo -n -e "${CYAN}Enter domain:\n${RESET} "
        read -r domain

        echo -n -e "${CYAN}Enter port (Press Enter to use 443):\n${RESET} "
        read -r port
        port=${port:-443} # Default to 443 if empty
        echo ""

        fetch "$server_ip" "$domain" "$port"
        echo ""
        echo -n -e "${MAGENTA}Do you want to check another IP and domain? (y/n):${RESET} "
        read -r answer
        [[ "$answer" != "y" ]] && break
    done
}

# Main script logic
if [ "$1" == "-i" ] || [ "$1" == "--interactive" ]; then
    interactive_mode
elif [ $# -eq 0 ]; then
    echo -e "${YELLOW}\nFetch SSL/TLS information using IP and domain as arguments.\n${RESET}"
    echo -e "${GREEN}Usage: ssl fetch 192.168.0.1 domain.tld [-i]\n${RESET}"
    echo -e "${MAGENTA}Use -i for interactive mode or provide server IP and domain as arguments.\n${RESET}"
else
    fetch "$1" "$2" "${3:-443}"
fi
