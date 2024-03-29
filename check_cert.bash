#!/bin/bash

# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Flag to indicate if the script executed successfully
script_executed=0

# Function to curl a site via TLS, validate SSL cert using openssl and print extracted & connection information.
check_cert() {
    local domain="$1"
    local port="${2:-443}" # Default to port 443 if not specified (standard)

    # Check if domain argument is provided
    if [ -z "$domain" ]; then
        echo -e "${MAGENTA}\nYou didn't specify a domain.${RESET}" "${GREEN}Please enter a domain name:\n${RESET}"
        read -r domain            # Prompt user to input the domain
        if [ -z "$domain" ]; then # Check again if a domain was entered
            echo -e "${RED}No domain provided, exiting...${RESET}"
            return 1 # Exit this script cause no domain was entered
        fi
    fi

    # Extracting certificate details using openssl and check for validation errors
    local "cert_info"="$(echo -e "QUIT\n" | openssl s_client -servername "${domain}" -connect "${domain}:${port}" -showcerts 2>&1)"
    local "validation_error"="$(echo "$cert_info" | grep 'Verify return code:')"

    # Check if there was a validation error with the cert
    if [[ "$validation_error" != *"Verify return code: 0 (ok)"* ]]; then
        echo -e "${RED}\nError with SSL connection or certificate validation: $validation_error${RESET}"
        echo -e "${MAGENTA}There is probably not a valid certificate on the server.\n${RESET}"
        return 1 # Exit if there's an issue with the cert
    else
        # If the certificate is valid print CA information
        echo ""
        echo -e "${YELLOW}SSL CERTIFICATE INFORMATION:\n${RESET}"
        echo -e "${YELLOW}*  CONNECTED: ${CYAN}${domain} on port:${port}${RESET}"
        echo -e "${YELLOW}*  VALIDATION: ${GREEN}Passed CA validation${RESET}"
    fi

    # Extracting certificate start and expiry dates
    local "start_date"="$(echo "$cert_info" | openssl x509 -noout -startdate | cut -d'=' -f2)"
    local "expire_date"="$(echo "$cert_info" | openssl x509 -noout -enddate | cut -d'=' -f2)"

    # Use curl to fetch certificate details and extract Common Name (CN) and Issuer's Organization (O)
    local "curl_cert_info"="$(curl --insecure -vvI "https://${domain}:${port}" 2>&1)"
    local "cn"="$(echo "$curl_cert_info" | awk '/^\*  subject:/ {print}' | grep -oP '(?<=CN=)[^,/\"]+')"
    local "issuer_o"="$(echo "$curl_cert_info" | awk '/^\*  issuer:/ {print}' | grep -oP '(O=[^,]+)' | sed -e 's/O=//' | tr -d ',' | head -n 1)"

    # Check if domain matches the certificate's SAN
    local "san"="$(echo "$cert_info" | openssl x509 -noout -text | grep -A1 "Subject Alternative Name:" | tail -n1)"
    local "domain_pattern"="$(echo "$domain" | sed 's/\./\\./g; s/\*/.*/g')" # Convert to regex: escape dots, replace * with .*

    # Printing the output
    echo -e "${YELLOW}*  COMMON NAME: ${CYAN}${cn} ${o}${RESET}"
    echo -e "${YELLOW}*  START DATE: ${CYAN}${start_date}${RESET}"
    echo -e "${YELLOW}*  EXPIRE DATE: ${CYAN}${expire_date}${RESET}"
    #echo -e "${YELLOW}ISSUER: ${CYAN}${issuer}${RESET}" # Commented out cause of issues extracting the name properly

    if [[ "$san" =~ $domain_pattern ]]; then
        echo -e "${YELLOW}*  SUBJECT ALT NAME: ${CYAN}'${domain}' ${GREEN}matched in SAN\n${RESET}"
    else
        echo -e "${YELLOW}*  SUBJECT ALT NAME: ${CYAN}'${domain}' ${RED}doesn't match SAN\n${RESET}"
    fi

    # curl (secure/insecure) and print TLS connection information
    echo -e "${YELLOW}TLS CONNECTION INFORMATION:\n${RESET}"
    local tls_info
    tls_info=$({ curl --insecure -vvI "https://${domain}:${port}" 2>&1 | awk -v green="$GREEN" -v cyan="$CYAN" -v magenta="$MAGENTA" -v yellow="$YELLOW" -v blue="$BLUE" -v red="$RED" -v reset="$RESET" '
        # Remove lines that start with "* ALPN," or "* Server certificate:"
        /^(\* ALPN,|\* Server certificate:)/ { next }  # Skip these lines
        /^\* SSL connection using/ {
            sub(/^\*/, "* ");  # Replace the asterisk followed by space with asterisk followed by two spaces
            print blue $0 reset;
            next
        }
        /^\*  subject:/ {
            match($0, /O=[^;]*/);  # Extract O= part
            org = substr($0, RSTART, RLENGTH);
            match($0, /CN=[^;]*/);  # Extract CN= part
            cn = substr($0, RSTART, RLENGTH);
            gsub("O=[^;]*;?", "", $0);  # Remove O= part and optional semicolon
            if(org != "" && cn != "") {
                print green "*  " cn reset;  # Only print CN= part
            } else if(cn != "") {
                print green "*  " cn reset;  # Print only CN= if available
            }
            next
        }
        /^\*  (start|expire) date:/ { print yellow $0 reset; next }
        /^\*  issuer:/ { print magenta $0 reset; next }
    '; } 2>/dev/null) # Dump bash and awk errors in /dev/null

    # When things don't work
    if [ -z "$tls_info" ]; then
        echo -e "${RED}Failed to establish a TLS connection. Please check the domain or try again.${RESET}"
        return 1 # Exit script here
    else
        echo -e "$tls_info" # Print curl info
    fi

    # Check that the script ran
    script_executed=1
}

test_tls_version() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: $0 <domain> [port]${RESET}"
        echo -e "${YELLOW}Port defaults to 443 if not specified.${RESET}"
        return
    fi

    local DOMAIN=$1
    local PORT=${2:-443} # Default to port 443 if not specified

    echo -e "${YELLOW}TLS VERSION SUPPORT:\n${RESET}"

    # Array of possible SSL/TLS versions
    declare -a VERSIONS=("tls1" "tls1_1" "tls1_2" "tls1_3")

    # Declare an associative array for version aliases
    declare -A VERSION_ALIASES
    VERSION_ALIASES["tls1"]="*  TLSv1.0"
    VERSION_ALIASES["tls1_1"]="*  TLSv1.1"
    VERSION_ALIASES["tls1_2"]="*  TLSv1.2"
    VERSION_ALIASES["tls1_3"]="*  TLSv1.3"

    for version in "${VERSIONS[@]}"; do
        echo -ne "${BLUE}${VERSION_ALIASES[$version]}: ${RESET}"
        # Directing output to /dev/null to only report support status
        if openssl s_client -connect "${DOMAIN}:${PORT}" -servername "${DOMAIN}" -"${version}" </dev/null >/dev/null 2>&1; then
            echo -e "${GREEN}Supported${RESET}"
        else
            # Differentiating between handshake failure and other types of errors
            if openssl s_client -connect "${DOMAIN}:${PORT}" -servername "${DOMAIN}" -"${version}" </dev/null 2>&1 | grep -q 'handshake failure'; then
                echo -e "${RED}Error! (Not supported)${RESET}"
            else
                echo -e "${MAGENTA}Unsupported${RESET}"
            fi
        fi
    done
}

check_cert "$1" "$2"
echo ""
test_tls_version "$1" "$2"

# Print the command information if the script was executed successfully
if [ "$script_executed" -eq 1 ]; then
    echo ""
    echo ""
    echo "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
    echo ""
    echo "Commands:"
    echo ""
    echo "openssl s_client -connect -servername dns.tld:port -showcerts -version"
    echo "curl --insecure -vvI https://dns.tld:port"
    echo ""
fi
