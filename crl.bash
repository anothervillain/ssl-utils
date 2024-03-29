#!/bin/bash

# Define ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

verify_crl_revocation_status() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: $0 <domain>${RESET}"
        return
    fi

    local DOMAIN=$1
    local CERT_FILE="${DOMAIN}_cert.pem"
    local CRL_FILE="crl.pem"

    echo -e "${GREEN}Verifying CRL revocation status for ${DOMAIN}...${RESET}"

    # Retrieve and save the domain's certificate
    echo "Retrieving the domain's certificate..."
    echo | openssl s_client -connect "${DOMAIN}:443" -servername "${DOMAIN}" -showcerts 2>/dev/null | openssl x509 -outform PEM >"${CERT_FILE}"

    # Extract CRL distribution points from the certificate
    CRL_URL=$(openssl x509 -in "${CERT_FILE}" -noout -text | grep 'Full Name:' -A 1 | grep 'URI:' | awk '{print $NF}')
    if [ -z "${CRL_URL}" ]; then
        echo -e "${YELLOW}No CRL distribution point found in the certificate.${RESET}"
        rm -f "${CERT_FILE}"
        return
    fi

    echo "CRL distribution point extracted: ${CRL_URL}"

    # Download the CRL
    echo "Downloading the CRL..."
    CURL_USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
    if ! curl -L -A "${CURL_USER_AGENT}" -s "${CRL_URL}" -o "${CRL_FILE}" || [ ! -s "${CRL_FILE}" ]; then
        echo -e "${RED}Failed to download CRL from ${CRL_URL}.${RESET}"
        rm -f "${CERT_FILE}" "${CRL_FILE}"
        return
    fi

    # Check revocation status against the CRL
    echo "Checking revocation status..."
    SERIAL_NUMBER=$(openssl x509 -in "${CERT_FILE}" -serial -noout | cut -d= -f2 | tr -d ':')
    openssl crl -in "${CRL_FILE}" -inform DER -noout -text >crl_details.txt 2>/dev/null
    if grep -q "${SERIAL_NUMBER}" crl_details.txt; then
        echo -e "${RED}Certificate with serial ${SERIAL_NUMBER} is REVOKED according to CRL.${RESET}"
    else
        echo -e "${GREEN}Certificate with serial ${SERIAL_NUMBER} is NOT revoked according to CRL.${RESET}"
    fi

    # Cleanup
    rm -f "${CERT_FILE}" "${CRL_FILE}" "crl_details.txt"
}

verify_crl_revocation_status "$1"
