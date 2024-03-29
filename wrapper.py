#!/usr/bin/env python3

import os
import subprocess
import sys
from colorama import Fore, Style


def run_script(command, args):
    try:
        # If command is a string, assume it's a direct executable command
        if isinstance(command, str):
            subprocess.run([command] + args, check=True)
        else:
            # command is a tuple (interpreter, script_path)
            interpreter, script_path = command
            subprocess.run([interpreter, script_path] + args, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {e}", file=sys.stderr)


def print_help():
    help_text = f"""
    {Fore.CYAN}Usage: ssl followed by one of the following commands and/or arguments:{Style.RESET_ALL}

    {Fore.GREEN}cert,     c     {Style.RESET_ALL} = Check a certificate to see most certificate information.
    {Fore.GREEN}chain,    x     {Style.RESET_ALL} = Connect using OpenSSL to display the full certificate chain.
    {Fore.GREEN}quick,    q     {Style.RESET_ALL} = Query if a certificate is valid or has expired (one-line).
    {Fore.GREEN}fetch,    f     {Style.RESET_ALL} = Connect to a server IP with the domain as an argument. [-i for interactive mode]
    {Fore.GREEN}new,      n     {Style.RESET_ALL} = Create a new CSR and Private Key.
    {Fore.GREEN}decode,   d     {Style.RESET_ALL} = Deccode certificate or CSR to extract relevant information.
    {Fore.GREEN}md5,      m     {Style.RESET_ALL} = Check that MD5 checksums match between .csr and .key or .ca and .crt.
    {Fore.GREEN}pack,     p     {Style.RESET_ALL} = Import files or paste content and pack a PFX file.
    {Fore.GREEN}extract,  e     {Style.RESET_ALL} = Extract .crt, .ca and .key from a PFX file.
    {Fore.GREEN}scan,     s     {Style.RESET_ALL} = Perform a scan using sslscan {Fore.MAGENTA}(ssl scan domain.tld){Style.RESET_ALL}
    
    {Fore.BLUE}New tools that I'm currently testing. Grain of salt, people, grain of salt.{Style.RESET_ALL}
    
    {Fore.MAGENTA}cipher,        y     {Style.RESET_ALL} = This command will test the server for supported ciphers. Output can be verbose.
    {Fore.MAGENTA}ctlog,         l     {Style.RESET_ALL} = Placeholder for CT log verification - this might involve using an external API or service.
    {Fore.MAGENTA}ocsp,          0     {Style.RESET_ALL} = OCSP check command here. Requires extracting the issuer from the certificate and then querying the OCSP URI.
    {Fore.MAGENTA}crl,           u     {Style.RESET_ALL} = CRL revocation status check.
    {Fore.MAGENTA}pinning,       t     {Style.RESET_ALL} = Verify certificate fingerprints.
    {Fore.MAGENTA}headers,       h     {Style.RESET_ALL} = Use curl to fetch the HTTP headers and then grep for security-related headers.
    {Fore.MAGENTA}performance,   p     {Style.RESET_ALL} = The openssl s_time command measures the time taken for handshakes.
    """
    print(help_text)


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))

    if len(sys.argv) < 2:
        print_help()
        return

    command = sys.argv[
        1
    ].lower()  # Convert command to lowercase to make it case-insensitive
    args = sys.argv[2:]

    # Map both the full command names and their shortcuts to the same actions
    commands = {
        "quick": ("bash", os.path.join(script_dir, "quick.bash")),
        "q": ("bash", os.path.join(script_dir, "quick.bash")),
        "fetch": ("bash", os.path.join(script_dir, "fetch.bash")),
        "f": ("bash", os.path.join(script_dir, "fetch.bash")),
        "cert": ("bash", os.path.join(script_dir, "check_cert.bash")),
        "c": ("bash", os.path.join(script_dir, "check_cert.bash")),
        "chain": ("bash", os.path.join(script_dir, "check_ssl_chain.bash")),
        "x": ("bash", os.path.join(script_dir, "check_ssl_chain.bash")),
        "new": ("bash", os.path.join(script_dir, "newcert.bash")),
        "n": ("bash", os.path.join(script_dir, "newcert.bash")),
        "decode": ("python3", os.path.join(script_dir, "decode.py")),
        "d": ("python3", os.path.join(script_dir, "decode.py")),
        "md5": ("bash", os.path.join(script_dir, "modulus.bash")),
        "m": ("bash", os.path.join(script_dir, "modulus.bash")),
        "pack": ("python3", os.path.join(script_dir, "pfx_pack.py")),
        "p": ("python3", os.path.join(script_dir, "pfx_pack.py")),
        "extract": ("bash", os.path.join(script_dir, "pfx_extract.bash")),
        "e": ("bash", os.path.join(script_dir, "pfx_extract.bash")),
        ################## N E W  T O O L S ##################
        "cipher": ("bash", os.path.join(script_dir, "cipher.bash")),
        "y": ("bash", os.path.join(script_dir, "cipher.bash")),
        "ctlogs": ("bash", os.path.join(script_dir, "ctlogs.bash")),
        "l": ("bash", os.path.join(script_dir, "ctlogs.bash")),
        "ocsp": ("bash", os.path.join(script_dir, "ocsp.bash")),
        "0": ("bash", os.path.join(script_dir, "ocsp.bash")),
        "crl": ("bash", os.path.join(script_dir, "crl.bash")),
        "u": ("bash", os.path.join(script_dir, "crl.bash")),
        "pinning": ("bash", os.path.join(script_dir, "pinning.bash")),
        "t": ("bash", os.path.join(script_dir, "pinning.bash")),
        "version": ("bash", os.path.join(script_dir, "version.bash")),
        "v": ("bash", os.path.join(script_dir, "version.bash")),
        "headers": ("bash", os.path.join(script_dir, "headers.bash")),
        "h": ("bash", os.path.join(script_dir, "headers.bash")),
        "performance": ("bash", os.path.join(script_dir, "performance.bash")),
        "p": ("bash", os.path.join(script_dir, "performance.bash")),
        "scan": "sslscan",
        "s": "sslscan",
    }

    if command in commands:
        command_spec = commands[command]
        run_script(command_spec, args)
    else:
        print(f"Unknown command: {command}")


if __name__ == "__main__":
    main()
