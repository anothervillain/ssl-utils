#!/usr/bin/env python3

from cryptography import x509
from cryptography.hazmat.backends import default_backend
from colorama import Fore, Style, init
import sys

# Initialize Colorama
init(autoreset=True)


def decode_certificate(cert_pem):
    try:
        cert = x509.load_pem_x509_certificate(cert_pem.encode(), default_backend())

        # Extract Common Name
        subject_cn = next(
            (
                item.value
                for item in cert.subject
                if item.oid == x509.NameOID.COMMON_NAME
            ),
            None,
        )
        print(Fore.MAGENTA + "Common Name:" + Fore.GREEN + f" {subject_cn}")

        # Extract SAN (Subject Alternative Names)
        try:
            san = cert.extensions.get_extension_for_oid(
                x509.oid.ExtensionOID.SUBJECT_ALTERNATIVE_NAME
            )
            alt_names = san.value.get_values_for_type(x509.DNSName)
            print(
                Fore.MAGENTA
                + "Subject Alternative Names:"
                + Fore.GREEN
                + f" {', '.join(alt_names)}"
            )
        except x509.ExtensionNotFound:
            print(Fore.YELLOW + "No Subject Alternative Names found.")

        # Extract Issuer Information
        issuer = cert.issuer.rfc4514_string().replace("\n", ", ").strip(" /")
        print(Fore.MAGENTA + "Issuer:" + Fore.GREEN + f" {issuer}")

        # Extract Validity Period
        print(Fore.YELLOW + "Validity Period:")
        print(Fore.MAGENTA + "Not Before:" + Fore.GREEN + f" {cert.not_valid_before}")
        print(Fore.MAGENTA + "Not After:" + Fore.GREEN + f" {cert.not_valid_after}")

    except Exception as e:
        print(Fore.RED + f"An error occurred: {e}")


def decode_csr(csr_pem):
    try:
        csr = x509.load_pem_x509_csr(csr_pem.encode(), default_backend())

        # Extract requested Common Name
        subject_cn = next(
            (
                item.value
                for item in csr.subject
                if item.oid == x509.NameOID.COMMON_NAME
            ),
            None,
        )
        print(Fore.MAGENTA + "Common Name:" + Fore.GREEN + f" {subject_cn}")

        # Extract SAN (Subject Alternative Names)
        try:
            san = csr.extensions.get_extension_for_oid(
                x509.oid.ExtensionOID.SUBJECT_ALTERNATIVE_NAME
            )
            alt_names = san.value.get_values_for_type(x509.DNSName)
            print(
                Fore.MAGENTA
                + "Subject Alternative Names:"
                + Fore.GREEN
                + f" {', '.join(alt_names)}"
            )
        except x509.ExtensionNotFound:
            print(Fore.YELLOW + "No Subject Alternative Names found.")
        except Exception as e:
            print(Fore.RED + f"An error occurred extracting SAN: {e}")

        # Extract CSR properties # Commented out cause of issues (!!)
        # print(Fore.YELLOW + "CSR Properties:")
        # print(Fore.MAGENTA + "Version:" + Fore.GREEN + f" {csr.version}")

    except Exception as e:
        print(Fore.RED + f"An error occurred: {e}")


def main():
    choice = input(
        f"{Fore.CYAN}Do you want to decode (1) certificate or (2) CSR? {Style.RESET_ALL}"
    ).upper()
    if choice == "1":
        print(
            Fore.MAGENTA
            + "Please paste your certificate (end with 'END CERTIFICATE-----'):"
        )
        cert_lines = []
        while True:
            line = input()
            cert_lines.append(line)
            if line.endswith("END CERTIFICATE-----"):
                break
        cert_pem = "\n".join(cert_lines)
        decode_certificate(cert_pem)
    elif choice == "2":
        print(
            Fore.MAGENTA
            + "Please paste your CSR (end with 'END CERTIFICATE REQUEST-----'):"
        )
        csr_lines = []
        while True:
            line = input()
            csr_lines.append(line)
            if line.endswith("END CERTIFICATE REQUEST-----"):
                break
        csr_pem = "\n".join(csr_lines)
        decode_csr(csr_pem)
    else:
        print(
            Fore.RED
            + "Invalid option selected. Please enter '1' for Certificate or '2' for CSR."
        )


if __name__ == "__main__":
    main()
