#!/bin/bash

# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Function to display the SSL certificate chain of a domain
check_ssl_chain() {
    local domain="$1"
    # Check if domain argument is provided
    if [ -z "$domain" ]; then
        echo -e "${MAGENTA}\nYou didn't specify a domain.${RESET}" "${GREEN}Please enter a domain name:\n${RESET}"
        read -r domain            # Prompt user to input the domain
        if [ -z "$domain" ]; then # Check again if a domain was entered
            echo -e "${RED}No domain provided, exiting...${RESET}"
            return 1
        fi
    fi

    # Connect to a hostname using openssl to display the complete certificate chain
    local openssl_info verification_code verification_message exp_date
    openssl_info=$(echo | openssl s_client --showcerts --connect "$domain:443" 2>/dev/null)
    verification_code=$(echo "$openssl_info" | awk '/Verify return code:/ {print $4; exit}')
    verification_message=$(echo "$openssl_info" | awk '/Verify return code:/ {print; exit}')
    exp_date=$(echo "$openssl_info" | openssl x509 -noout -enddate | cut -d'=' -f2) # Extract the certificate's expiration date

    # Print the results
    echo "$openssl_info"
    if [ "$verification_code" = "0" ] || [[ "$verification_message" =~ ": (ok)" ]]; then
        echo ""
        echo -e "${GREEN}Valid SSL certificate found. ${CYAN}Expiry: ${exp_date}.\n${RESET}"
        echo -e "${YELLOW}Scroll to explore the full SSL chain.\n${RESET}"
    else
        echo ""
        echo -e "${RED}Invalid or no SSL certificate found. Verification: $verification_message\n${RESET}"
    fi

}

check_ssl_chain "$1" | python3 ~/ssl-utils/check_ssl_chain_color.py
