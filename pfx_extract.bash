#!/bin/bash

# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Check if user is in the correct directory
while true; do
    read -rp "Are you in the correct directory? (Y/N): " -n 1 yn
    echo "" # Move to a new line for clean output
    case ${yn,,} in
    y | yes) break ;;
    n | no)
        echo -e "${MAGENTA}Please change to the correct directory and rerun this script.${RESET}"
        exit
        ;;
    *) echo -e "${RED}Please answer yes or no.${RESET}" ;;
    esac
done

# Ask for the PFX file path
read -rp "Enter the path to your PFX file:" pfx_path

# Verify that the file exists
if [ ! -f "$pfx_path" ]; then
    echo -e "${RED}The file '$pfx_path' does not exist.${RESET}"
    exit 1
fi

# Ask for the PFX password
read -rsp "Enter the PFX password: " pfx_password
echo

# Extract the filename without extension for folder creation
file_name=$(basename -- "$pfx_path")
folder_name="${file_name%.*}"

# Create a directory for the extracted files
mkdir -p "$folder_name"

# Define output file names
private_key_file="$folder_name/${folder_name}.key"
certificate_file="$folder_name/${folder_name}.crt"
ca_file="$folder_name/${folder_name}.ca"

# Extract the private key
if openssl pkcs12 -in "$pfx_path" -nocerts -nodes -passin pass:"$pfx_password" -out "$private_key_file"; then
    echo -e "${GREEN}Private key extracted to $private_key_file${RESET}"
else
    echo -e "${RED}Failed to extract private key.${RESET}"
    exit 1
fi

# Extract the certificate
if openssl pkcs12 -in "$pfx_path" -clcerts -nokeys -passin pass:"$pfx_password" -out "$certificate_file"; then
    echo -e "${GREEN}Certificate extracted to $certificate_file${RESET}"
else
    echo -e "${RED}Failed to extract certificate.${RESET}"
    exit 1
fi

# Extract the CA certificates
if openssl pkcs12 -in "$pfx_path" -cacerts -nokeys -chain -passin pass:"$pfx_password" -out "$ca_file"; then
    echo -e "${GREEN}CA certificates extracted to $ca_file${RESET}"
else
    echo -e "${RED}Failed to extract CA certificates.${RESET}"
    exit 1
fi

echo -e "${CYAN}Extraction complete!${RESET}"
