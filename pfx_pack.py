from cryptography import x509
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.serialization import pkcs12
from cryptography.hazmat.backends import default_backend
import sys
import colorama  # Importing the Colorama package
from colorama import (
    Fore,
    Style,
)  # Importing Fore and Style for color and style settings

colorama.init(
    autoreset=True
)  # Initializes Colorama to auto-reset the style after each print statement


def load_pem_file(file_path):
    try:
        with open(file_path, "rb") as f:
            return f.read()
    except FileNotFoundError:
        print(f"{Fore.RED}File not found: {file_path}{Style.RESET_ALL}")
        sys.exit(1)


def create_pfx(cert_pem, key_pem, ca_pem, password, pfx_file):
    try:
        cert = x509.load_pem_x509_certificate(cert_pem, default_backend())
        key = serialization.load_pem_private_key(
            key_pem, password=None, backend=default_backend()
        )
        ca_certs = (
            [x509.load_pem_x509_certificate(ca, default_backend()) for ca in ca_pem]
            if ca_pem
            else []
        )

        encryption_algo = (
            serialization.BestAvailableEncryption(password.encode())
            if password
            else serialization.NoEncryption()
        )

        pfx = pkcs12.serialize_key_and_certificates(
            name=b"",
            key=key,
            cert=cert,
            cas=ca_certs,
            encryption_algorithm=encryption_algo,
        )

        with open(pfx_file, "wb") as f:
            f.write(pfx)
        print(
            f"{Fore.GREEN}PFX file '{pfx_file}' created successfully.{Style.RESET_ALL}"
        )

    except Exception as e:
        print(f"{Fore.RED}An error occurred: {e}{Style.RESET_ALL}")


def main():
    yn = input(
        f"{Fore.MAGENTA}Are you in the correct directory with all necessary files? (Y/N): {Style.RESET_ALL}"
    ).lower()
    if yn not in ("y", "yes"):
        print(
            f"{Fore.RED}Please change to the correct directory with all necessary files and rerun this script.{Style.RESET_ALL}"
        )
        sys.exit()

    mode = input(
        f"{Fore.YELLOW}Do you want to (1) Enter paths to files or (2) Paste content directly? (1/2): {Style.RESET_ALL}"
    )
    if mode == "1":
        cert_file = input(
            f"{Fore.GREEN}Enter the path to the certificate file: {Style.RESET_ALL}"
        )
        key_file = input(
            f"{Fore.GREEN}Enter the path to the private key file: {Style.RESET_ALL}"
        )
        ca_file = input(
            f"{Fore.GREEN}Enter the path to the CA certificate file (leave blank if none): {Style.RESET_ALL}"
        )
        cert_pem = load_pem_file(cert_file)
        key_pem = load_pem_file(key_file)
        ca_pem = [load_pem_file(ca_file)] if ca_file else []
    elif mode == "2":
        print(
            f"{Fore.YELLOW}Paste the certificate in PEM format (end with a line containing only 'END'):{Style.RESET_ALL}"
        )
        cert_pem_lines = []
        while True:
            line = input()
            if line == "END":
                break
            cert_pem_lines.append(line)
        cert_pem = "\n".join(cert_pem_lines).encode()

        print(
            f"{Fore.YELLOW}Paste the private key in PEM format (end with a line containing only 'END'):{Style.RESET_ALL}"
        )
        key_pem_lines = []
        while True:
            line = input()
            if line == "END":
                break
            key_pem_lines.append(line)
        key_pem = "\n".join(key_pem_lines).encode()

        print(
            f"{Fore.YELLOW}Paste the CA certificate in PEM format (end with a line containing only 'END', leave blank if none):{Style.RESET_ALL}"
        )
        ca_pem_lines = []
        while True:
            line = input()
            if line == "END":
                break
            ca_pem_lines.append(line)
        ca_pem = [("\n".join(ca_pem_lines)).encode()] if ca_pem_lines else []
    else:
        print(f"{Fore.RED}Invalid choice.{Style.RESET_ALL}")
        sys.exit()

    pfx_name = input(
        f"\n{Fore.BLUE}Enter a name for the PFX file (without extension): {Style.RESET_ALL}"
    )
    if not pfx_name.strip():
        pfx_name = "certificate"
    pfx_file = f"{pfx_name}.pfx"

    password = input(
        f"\n{Fore.BLUE}Enter a password for the PFX file or leave blank for none: {Style.RESET_ALL}"
    )

    create_pfx(cert_pem, key_pem, ca_pem, password, pfx_file)


if __name__ == "__main__":
    main()
