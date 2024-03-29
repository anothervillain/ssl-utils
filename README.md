# SSL Utility Suite 🛡️

Welcome to **SSL Utility Suite**, a comprehensive toolkit I've designed to simplify the processes of SSL certificate creation and troubleshooting. This suite is your go-to resource for managing SSL/TLS certificates, whether you're quickly verifying a certificate's validity, fetching issuer details, or creating new certficates, extracting PFX or packing new ones. Should cover most use-cases.

![SSL Utility Suite](https://raw.githubusercontent.com/zhk3r/stash/main/image.png)

## 🚀 Getting Started

This utility suite is built to run on Ubuntu-22.04 on WSL, ensuring broad compatibility and ease of use.

### Dependencies

Ensure your system meets the following dependencies:

```bash
sudo apt install -y git whois openssl dig curl sslscan python3 python3-pip ca-certificates && pip3 install colorama
```

#### Installation

Clone this repository to your local machine to get started.

```bash
git clone git@gitlab.group.one:christian-mathias.moen/ssl-utils.git
```

Create a convenient alias for the wrapper.py script so you can invoke the commands:

```bash
alias ssl='~/ssl-utils/wrapper.py'
```

Ensure executability of the scripts within the suite:

```bash
chmod +x -R ssl-utils
```

##### Stay Updated by running the update script periodically:

```bash
cd ssl-utils && ./update.sh
```

##### Handling PATH Issues

If you encounter any PATH issues, you might need to adjust your shell's configuration file (.zshrc, .bashrc, etc.):

```bash
export PATH="$PATH:/$HOME/ssl-utils"
```

🛠 **Features & Usage**

SSL Utility Suite includes a variety of tools for SSL certificate management:

```
Usage: ssl (or your alias) followed by one of the following commands and/or arguments:

cert,     c      = Check a certificate to see most certificate information.
chain,    x      = Connect using OpenSSL to display the full certificate chain.
quick,    q      = Query if a certificate is valid or has expired (one-line).
fetch,    f      = Connect to a server IP with the domain as an argument. [-i for interactive mode]
new,      n      = Create a new CSR and Private Key.
decode,   d      = Deccode certificate or CSR to extract relevant information.
md5,      m      = Check that MD5 checksums match between .csr and .key or .ca and .crt.
pack,     p      = Import files or paste content and pack a PFX file.
extract,  e      = Extract .crt, .ca and .key from a PFX file.
scan,     s      = Perform a scan using sslscan (ssl scan domain.tld)

```

*New tools that I'm currently testing. Grain of salt, people, grain of salt*

```
cipher,        y      = This command will test the server for supported ciphers. Output can be verbose.
ctlog,         l      = Placeholder for CT log verification - this might involve using an external API or service.
ocsp,          0      = OCSP check: Requires extracting the issuer from the cert and then querying the OCSP URI.
crl,           u      = CRL revocation status check.
pinning,       t      = Verify certificate fingerprints.
headers,       h      = Use curl to fetch the HTTP headers and then grep for security-related headers.
performance,   p      = The openssl s_time command measures the time taken for handshakes.

```

🤝 **Contributing**

Any contributions you make are greatly appreciated. If you wish to contribute, please contact me on Slack.

📜 **License**

This project is proudly offered without licensing, free for personal and commercial use.

📈 **Project Status**

**SSL Utility Suite** is currently in development, with new features and improvements being added regularly. Stay tuned for updates and feel free to contribute!
