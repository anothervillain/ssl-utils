#!/bin/bash

# Define ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

check_ocsp_revocation_status() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: $0 <domain>${RESET}"
        return
    fi

    local DOMAIN=$1
    local CERT_FILE="cert.pem"

    echo -e "${GREEN}Checking OCSP revocation status for ${DOMAIN}...${RESET}"

    # Retrieve the domain's certificate
    echo "Retrieving the domain's certificate..."
    echo | openssl s_client -connect "${DOMAIN}:443" -servername "${DOMAIN}" -showcerts 2>/dev/null | openssl x509 -outform PEM >"${CERT_FILE}"

    # Extract the OCSP URL from the domain's certificate
    OCSP_URL=$(openssl x509 -noout -ocsp_uri -in "${CERT_FILE}")
    echo "OCSP URL extracted: ${OCSP_URL}"

    # Update this path to the location of your CA bundle
    CA_BUNDLE_PATH="/etc/ssl/certs/ca-certificates.crt"

    if [ ! -z "${OCSP_URL}" ]; then
        # Using the CA bundle for the OCSP check
        openssl ocsp -no_nonce -issuer "${CA_BUNDLE_PATH}" -cert "${CERT_FILE}" -text -url "${OCSP_URL}" -CAfile "${CA_BUNDLE_PATH}"
    else
        echo -e "${RED}OCSP URL not found in the certificate.${RESET}"
    fi

    # Cleanup
    rm -f "${CERT_FILE}"
}

check_ocsp_revocation_status "$1"
