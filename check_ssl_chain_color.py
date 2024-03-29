#!/usr/bin/env python3

import sys
import re
from colorama import init, Fore, Style

init(autoreset=True)

# Define regex patterns for colorization
patterns = {
    "subject": (re.compile(r"(subject=)"), Fore.GREEN),
    "issuer": (re.compile(r"(issuer=)"), Fore.MAGENTA),
    # -------------------------------------------------
    "s:CN =": (re.compile(r"(s:CN =)"), Fore.GREEN),
    "i:C =": (re.compile(r"(i:C =)"), Fore.LIGHTYELLOW_EX),
    "a:PKEY:": (re.compile(r"(a:PKEY:)"), Fore.BLUE),
    "v:NotBefore:": (re.compile(r"(v:NotBefore:)"), Fore.MAGENTA),
    "s:C": (re.compile(r"(s:C =)"), Fore.LIGHTYELLOW_EX),
    "i:C =": (re.compile(r"(i:C =)"), Fore.LIGHTYELLOW_EX),
    "i:OU =": (re.compile(r"(i:OU =)"), Fore.LIGHTYELLOW_EX),
    "O =": (re.compile(r"(O =)"), Fore.MAGENTA),
    "s:b": (re.compile(r"(s:b)"), Fore.LIGHTYELLOW_EX),
    # -------------------------------------------------
    "No client": (re.compile(r"(No client)"), Fore.LIGHTCYAN_EX),
    "Peer signing digest:": (re.compile(r"(Peer signing digest:)"), Fore.LIGHTCYAN_EX),
    "Peer signature type:": (re.compile(r"(Peer signature type:)"), Fore.LIGHTCYAN_EX),
    "Server Temp Key": (re.compile(r"(Server Temp Key:)"), Fore.LIGHTCYAN_EX),
    # -------------------------------------------------
    "SSL handshake": (re.compile(r"(SSL handshake)"), Fore.YELLOW),
    "Verification": (re.compile(r"(Verification)"), Fore.YELLOW),
    # -------------------------------------------------
    "TLSv": (re.compile(r"(New,)"), Fore.CYAN),
    "Server": (re.compile(r"(Server public)"), Fore.CYAN),
    "Secure": (re.compile(r"(Secure)"), Fore.CYAN),
    "Compression:": (re.compile(r"(Compression:)"), Fore.CYAN),
    "Expansion:": (re.compile(r"(Expansion:)"), Fore.CYAN),
    "No ALPN": (re.compile(r"(No ALPN)"), Fore.CYAN),
    "Early": (re.compile(r"(Early)"), Fore.CYAN),
    "SSL-": (re.compile(r"(SSL-)"), Fore.CYAN),
    "Post-Handshake": (re.compile(r"(Post-Handshake)"), Fore.CYAN),
    "Verify": (re.compile(r"(Verify)"), Fore.GREEN),
}

# Read from stdin and apply colorization
for line in sys.stdin:
    colored_line = line
    for key, value in patterns.items():
        if key == "hex_line":
            # Special handling for hex lines
            def repl(m):
                return f"{value[1]}{m.group(1)}{value[2]}{m.group(2)}{value[3]}{m.group(3)}"

            colored_line = value[0].sub(repl, colored_line)
        else:
            # Replace the pattern with itself (referenced by \1) prefixed with the color code
            colored_line = value[0].sub(value[1] + r"\1", colored_line)
    sys.stdout.write(colored_line)
