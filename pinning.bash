#!/bin/bash

# Define ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

test_certificate_pinning() {
    if [ -z "$1" ]; then
        echo -e "${YELLOW}\nUsage: ${CYAN}ssl pinning\n${RESET}"
        echo -e "${YELLOW}Verify certificate fingerptint\n${RESET}"
        echo -e "${MAGENTA}You only have to define the domain.\n${RESET}"
        return
    fi

    local DOMAIN=$1

    echo -e "${YELLOW}\nTesting certificate pinning implementation for ${CYAN}${DOMAIN}...${RESET}"

    # Dynamically retrieve the current certificate's fingerprint
    local "CURRENT_CERT_FINGERPRINT"="$(echo | openssl s_client -connect "${DOMAIN}:443" -servername "${DOMAIN}" 2>/dev/null | openssl x509 -noout -sha256 -fingerprint | cut -d= -f2)"

    echo -e "${GREEN}\nCurrent certificate fingerprint for ${CYAN}${DOMAIN}: ${MAGENTA}${CURRENT_CERT_FINGERPRINT}\n${RESET}"

    # Ask for the expected fingerprint
    read -r -p "Enter the expected certificate fingerprint for comparison: " EXPECTED_CERT_FINGERPRINT

    # Perform the pinning test
    if [ "${CURRENT_CERT_FINGERPRINT}" == "${EXPECTED_CERT_FINGERPRINT}" ]; then
        echo -e "${GREEN}\nCertificate fingerprint matches the expected value. Pinning test passed!\n${RESET}"
    else
        echo -e "${RED}\nCertificate fingerprint does not match the expected value. Pinning test failed.\n${RESET}"
    fi
}

test_certificate_pinning "$1"
