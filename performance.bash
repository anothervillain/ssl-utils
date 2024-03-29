#!/bin/bash

# Define ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

measure_ssl_tls_performance() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: $0 <domain> [port]${RESET}"
        echo -e "${YELLOW}Port defaults to 443 if not specified.${RESET}"
        return 1
    fi

    local DOMAIN=$1
    local PORT=${2:-443} # Default to port 443 if not specified

    echo -e "${GREEN}Measuring SSL/TLS handshake performance for ${DOMAIN}:${PORT}...${RESET}"

    # Measuring handshake time with openssl s_time. Suppress error output to avoid confusion in case of non-fatal errors.
    if ! openssl s_time -connect "${DOMAIN}:${PORT}" -new -www / -time 5 2>/dev/null; then
        echo -e "${RED}There was an error measuring the SSL/TLS performance. This might be due to connectivity issues, or the specified domain does not support SSL/TLS on the given port.\n${RESET}"
        return 1
    fi
    return 0
}

measure_ssl_tls_performance "$1" "$2"
$()
