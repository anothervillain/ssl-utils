#!/bin/bash

# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"
BOLD="\033[1m"

# Create a new CSR and Private Key
newcert() {
    local file_name passphrase_option
    # Function to process user input
    process_input() {
        local input=${1%.*}
        echo "${input:-certificate}"
    }

    # Validate number of arguments
    if [ "$#" -gt 1 ]; then
        echo -e "${RED}Error: Incorrect usage. Please provide only one domain name.${RESET}" >&2
        return 1
    fi
    # Check if a domain name is passed as an argument
    if [ "$#" -eq 1 ]; then
        file_name=$(process_input "$1")
    else
        # User prompt for file name
        echo -e "${YELLOW}Enter a name for your .csr and .key files (ex:domain_no) or leave blank for default 'certificate' name:${RESET}"
        read -r file_name
        file_name=$(process_input "$file_name")
    fi

    # Ask user if they want to set a PEM passphrase
    while true; do
        echo -e "${YELLOW}Do you want to set a PEM passphrase for the Private Key? (Y/N)${RESET}"
        read -r -n 1 passphrase_option
        echo "" # Move to a new line

        # Convert input to uppercase
        passphrase_option=${passphrase_option^^}

        # Check if input is 'Y' or 'N'
        if [[ $passphrase_option == "Y" ]]; then
            echo -e "${YELLOW}You will be prompted to create a PEM passphrase for the Private Key.${RESET}"
            echo -e "${RED}Use a strong password and store it somewhere safe!${RESET}"
            if openssl genpkey -algorithm RSA -aes256 -out "${file_name}.key"; then
                echo -e "${GREEN}Private Key created as ${file_name}.key with a passphrase${RESET}"
            else
                echo -e "${RED}Failed to create Private Key.${RESET}" >&2
                return 1
            fi
            break
        elif [[ $passphrase_option == "N" ]]; then
            if openssl genpkey -algorithm RSA -out "${file_name}.key"; then
                echo -e "${GREEN}Private Key created as ${file_name}.key without a passphrase${RESET}"
            else
                echo -e "${RED}Failed to create Private Key.${RESET}" >&2
                return 1
            fi
            break
        else
            echo -e "${RED}Invalid input. Please press Y or N.${RESET}"
        fi
    done

    # Guidance for OpenSSL prompts
    echo
    echo -e "${CYAN}${BOLD}* THINGS TO REMEMBER IN THE NEXT STEPS *${RESET}"
    echo
    echo -e "${YELLOW}Proceed to enter information for CSR: This is mostly optional.${RESET}"
    echo -e "${MAGENTA}You can leave all steps blank (Enter)${RESET} ${RED}${BOLD}EXCEPT STEP 6: FQDN/CN!${RESET}"
    echo
    echo -e "${RED}${BOLD}IMPORTANT:${RESET}" "${YELLOW}If this is to be used with${RESET}" "${GREEN}Organization Validated cert${RESET}" "${CYAN}all info must be filled correctly.${RESET}"
    echo -e "${MAGENTA}You do not need to set an email or alternative password (last steps).${RESET}"
    echo

    # Generating CSR with color feedback
    if openssl req -new -key "${file_name}.key" -out "${file_name}.csr"; then
        echo
        echo -e "${GREEN}CSR created as ${file_name}.csr${RESET}"
    else
        echo -e "${RED}Failed to create CSR.${RESET}" >&2
        return 1
    fi
}

newcert "$@"
