#!/bin/bash

# Define ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Usage message for the script
usage() {
    echo -e "${YELLOW}\nUsage:    ${CYAN}ssl cipher DOMAIN PORT [FILTER] [LOGFILE]\n${RESET}"
    echo -e "${YELLOW}DOMAIN:     ${GREEN}The domain to analyze.${RESET}"
    echo -e "${YELLOW}PORT:       ${GREEN}The port to analyze, defaults to 443.${RESET}"
    echo -e "${YELLOW}FILTER:     ${GREEN}Optional filter keyword for cipher suites.${RESET}"
    echo -e "${YELLOW}LOGFILE:    ${GREEN}Optional file to log the output.\n${RESET}"
    echo -e "${MAGENTA}You only *have* to define the domain.${RESET}"
}

analyze_supported_ciphers() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        usage
        return
    fi

    local DOMAIN=$1
    local PORT=$2
    local FILTER=${3:-}
    local LOGFILE=$4

    echo -e "${GREEN}Analyzing supported TLS/SSL ciphers for ${DOMAIN} on port ${PORT}...${RESET}"
    # Execute nmap command and optionally filter output
    local COMMAND="grc nmap --script ssl-enum-ciphers -p \"${PORT}\" \"${DOMAIN}\""
    if [ ! -z "$FILTER" ]; then
        COMMAND="$COMMAND | grep \"$FILTER\""
    fi

    # Optionally log output to a file
    if [ ! -z "$LOGFILE" ]; then
        eval "$COMMAND" | tee "$LOGFILE"
    else
        eval "$COMMAND"
    fi
}

analyze_supported_ciphers "$1" 443
echo ""
