#!/bin/bash

# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Function to calculate modulus from content
calculate_modulus() {
    echo "$1" | openssl md5
}

# Function to compare modulus of CSR and Private Key
compare_modulus() {
    local csr_content="$1"
    local key_content="$2"

    # Check if both inputs are empty
    if [ -z "$csr_content" ] && [ -z "$key_content" ]; then
        echo -e "${YELLOW}Nothing to process...\n${RESET}"
        return 0
    fi

    # Determine if input is file path or actual content and calculate modulus
    if [ -f "$csr_content" ]; then
        csr_modulus=$(openssl req -noout -modulus -in "$csr_content" | calculate_modulus)
    else
        csr_modulus=$(echo "$csr_content" | openssl req -noout -modulus | calculate_modulus)
    fi

    if [ -f "$key_content" ]; then
        key_modulus=$(openssl rsa -noout -modulus -in "$key_content" | calculate_modulus)
    else
        key_modulus=$(echo "$key_content" | openssl rsa -noout -modulus | calculate_modulus)
    fi

    # Compare and output result
    if [ "$csr_modulus" = "$key_modulus" ]; then
        echo -e "${GREEN}The CSR and Private Key match.\n${RESET}"
    else
        echo -e "${RED}The CSR and Private Key do not match.\n${RESET}"
        return 1
    fi
}

# Function to verify certificate against CA
verify_certificate() {
    local certificate_content="$1"
    local ca_certificate_content="$2"

    # Check if both inputs are empty
    if [ -z "$certificate_content" ] && [ -z "$ca_certificate_content" ]; then
        echo -e "${YELLOW}Nothing to process...\n${RESET}"
        return 0
    fi

    # Determine if input is file path or actual content, then verify
    if [ -f "$certificate_content" ]; then
        if openssl verify -CAfile "$ca_certificate_content" "$certificate_content" >/dev/null 2>&1; then
            echo -e "${GREEN}The certificate is valid and verified against the CA.\n${RESET}"
        else
            echo -e "${RED}The certificate is not valid or cannot be verified against the CA.\n${RESET}"
            return 1
        fi
    else
        # If direct content, write to temporary files for verification
        local "cert_file"="$(mktemp)"
        local "ca_cert_file"="$(mktemp)"
        echo "$certificate_content" >"$cert_file"
        echo "$ca_certificate_content" >"$ca_cert_file"

        if openssl verify -CAfile "$ca_cert_file" "$cert_file" >/dev/null 2>&1; then
            echo -e "${GREEN}The certificate is valid and verified against the CA.\n${RESET}"
        else
            echo -e "${RED}The certificate is not valid or cannot be verified against the CA.\n${RESET}"
            return 1
        fi

        # Cleanup temporary files
        rm -f "$cert_file" "$ca_cert_file"
    fi
}

# Main script starts here
echo ""
echo -e "${YELLOW}Verify MD5 checksums: (Press 1 or 2):\n${RESET}"
echo -e "${CYAN}1 - Verify CSR and Private Key.${RESET}"
echo -e "${BLUE}2 - Verify certificate against CA.${RESET}"
read -r -n 1 action
echo

case ${action,,} in
1)
    # Handle modulus comparison
    echo ""
    while true; do
        echo -e "${YELLOW}Paste the content or import files? (Press 1 or 2):\n${RESET}"
        echo -e "${CYAN}1 - Paste content.${RESET}"
        echo -e "${BLUE}2 - Import files.${RESET}"
        read -r -n 1 input_method
        echo

        case ${input_method,,} in
        2)
            echo ""
            echo -e "${MAGENTA}Enter the path to your CSR file:${RESET}"
            read -r csr_path
            echo -e "${MAGENTA}Enter the path to your Private Key file:${RESET}"
            read -r key_path
            compare_modulus "$csr_path" "$key_path"
            break # Exit loop after processing
            ;;
        1)
            echo ""
            echo -e "${CYAN}Paste the CSR content and press Ctrl-D:${RESET}"
            csr_pasted=$(cat)
            echo -e "${CYAN}Paste the Private Key content and press Ctrl-D:${RESET}"
            key_pasted=$(cat)
            compare_modulus "$csr_pasted" "$key_pasted"
            break # Exit loop after processing
            ;;
        *)
            echo -e "${RED}Invalid input, try again.${RESET}"
            ;;
        esac
    done
    ;;
2)
    # Handle certificate verification against CA
    echo ""
    while true; do
        echo -e "${YELLOW}Paste the content or import files? (Press 1 or 2):\n${RESET}"
        echo -e "${CYAN}1 - Paste content.${RESET}"
        echo -e "${BLUE}2 - Import files.${RESET}"
        read -r -n 1 input_method
        echo

        case ${input_method,,} in
        2)
            echo ""
            echo -e "${MAGENTA}Enter the path to your Certificate file:${RESET}"
            read -r certificate_path
            echo -e "${MAGENTA}Enter the path to your CA Certificate file:${RESET}"
            read -r ca_certificate_path
            verify_certificate "$certificate_path" "$ca_certificate_path"
            break # Exit loop after processing
            ;;
        1)
            echo ""
            echo -e "${CYAN}Paste the Certificate content and press Ctrl-D:${RESET}"
            certificate_pasted=$(cat)
            echo -e "${CYAN}Paste the CA Certificate content and press Ctrl-D:${RESET}"
            ca_certificate_pasted=$(cat)
            verify_certificate "$certificate_pasted" "$ca_certificate_pasted"
            break # Exit loop after processing
            ;;
        *)
            echo -e "${RED}Invalid input, try again.${RESET}"
            ;;
        esac
    done
    ;;
*)
    echo -e "${RED}Invalid choice again. Exiting.${RESET}"
    ;;
esac # This closes the main case statement
