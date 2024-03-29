"""
This script fetches A records and nameservers for a list of domains provided in a file. It filters domains based on specified A record criteria and matching nameservers, outputting the filtered list to a new file. Define filenames on the bottom of the document.

Configuration options are available for specifying nameserver match criteria and A record filter criteria.

Usage:
- Update the `specified_nameservers` and `a_record_criteria` variables as needed.
- Run the script with the input file containing domains as the first argument and the output file name as the second argument.

Requirements:
- Python 3.x
- Access to the `dig` command-line tool.
"""

import subprocess
import logging
from concurrent.futures import ThreadPoolExecutor, as_completed

# Setup basic logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Configuration options
specified_nameservers = ['ns01.no.brand.one.com', 'ns02.no.brand.one.com', '*.uniweb.no', '*.fastname.no']
a_record_criteria = "5.249"

def run_subprocess_command(command):
    """
    Executes a given command using subprocess and returns the output.
    If an error occurs, logs the error and returns None.
    """
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        logging.error(f"Command '{' '.join(command)}' failed with return code {e.returncode}: {e.output}")
    except Exception as e:
        logging.error(f"Unexpected error running command '{' '.join(command)}': {e}")
    return None

def get_a_record(domain):
    """
    Fetches the A record for the given domain using the dig command.
    """
    command = ['dig', '+short', 'A', domain]
    output = run_subprocess_command(command)
    if output:
        a_record = output.split('\n')[0]
        logging.info(f"A record for {domain}: {a_record}")
        return a_record
    else:
        logging.error(f"Failed to fetch A record for {domain}")
        return ''

def get_nameservers(domain):
    """
    Fetches the nameservers for the given domain using the dig command.
    """
    command = ['dig', '+short', 'NS', domain]
    output = run_subprocess_command(command)
    if output:
        nameservers = output.split('\n')
        logging.info(f"Nameservers for {domain}: {nameservers}")
        return nameservers
    else:
        logging.error(f"Failed to fetch nameservers for {domain}")
        return []

def is_matching_any_nameserver(domain_nameservers, specified_nameservers):
    """
    Checks if any of the domain's nameservers match the specified nameservers.
    """
    for dn in domain_nameservers:
        if any(sn.startswith('*') and dn.endswith(sn[1:]) or dn == sn for sn in specified_nameservers):
            logging.info(f"Matching NS found: {dn}")
            return True
    return False

def process_domains(file_path, output_file_path):
    """
    Processes domains from the input file, filtering based on A records and nameservers.
    """
    with open(file_path, 'r') as file:
        domains = [line.strip() for line in file]

    with open(output_file_path, 'w') as output_file:
        for index, domain in enumerate(domains, start=1):
            logging.info(f"Processing {index}/{len(domains)}: {domain}")

            a_record = get_a_record(domain)
            if a_record.startswith(a_record_criteria):
                nameservers = get_nameservers(domain)
                if is_matching_any_nameserver(nameservers, specified_nameservers):
                    output_file.write(domain + '\n')

# Define your list of domains in 'input.txt' and specify the output file name
process_domains('input.txt', 'output.txt')