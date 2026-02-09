# In-Class Exercise: Building a Ping Sweep Script

Write a Bash script that performs a **ping sweep** to discover active hosts on a network. Your script must support two modes: scanning by **IP range** and scanning by **hostname prefix**. The script must work on both macOS and Linux.

## Background

A ping sweep is a network reconnaissance technique that sends ICMP echo requests to a range of addresses to determine which hosts are online. System administrators use ping sweeps to inventory active devices, verify network configurations, and troubleshoot connectivity issues.

## Requirements

Your script (`pingsweep.sh`) must implement the following:

### 1. Usage / Help Function

Create a `usage()` function that prints a help message describing all available options and examples, then exits. The help should be displayed when the user passes `-h` or `-?`, or when invalid options are provided.

### 2. Option Parsing

Use `getopts` (the portable shell builtin) to parse command-line options. Your script must accept the following flags:

| Flag           | Description                                              |
| -------------- | -------------------------------------------------------- |
| `-i <prefix>`  | Network prefix for IP sweep (e.g., `192.168.1`)          |
| `-d`           | Auto-detect the network prefix from this machine's IP    |
| `-n <prefix>`  | Hostname prefix for hostname sweep (e.g., `web-server-`) |
| `-r <start>`   | Range start number (required for hostname mode)          |
| `-e <end>`     | Range end number (required for hostname mode)            |
| `-t <seconds>` | Ping timeout in seconds (default: 1)                     |
| `-h` / `-?`    | Show help                                                |

### 3. Input Validation

Write a `validate()` function that checks:
- A mode (`-i`, `-d`, or `-n`) was selected
- If hostname mode is used, both `-r` and `-e` are provided

If validation fails, print the usage message and exit.

### 4. Cross-Platform Ping

The `ping` command uses different flags for timeout on macOS vs Linux:
- **macOS (Darwin):** `ping -c 1 -t <timeout> <host>`
- **Linux:** `ping -c 1 -W <timeout> <host>`

Write a `ping_host()` function that detects the operating system and uses the correct flag.

### 5. IP Sweep Mode (`ip_sweep` function)

When the user provides `-i <prefix>` or `-d`:
- Scan addresses `<prefix>.1` through `<prefix>.254`
- For each responding host, attempt a reverse DNS lookup and display the hostname if found
- Run pings in parallel using background subshells for speed

### 6. Auto-Detect Mode

When the user provides `-d`:
- Detect the machine's local IP address using OS-appropriate commands
- Extract the first three octets as the network prefix
- Proceed with the IP sweep using the detected prefix

### 7. Hostname Sweep Mode (`host_sweep` function)

When the user provides `-n <prefix> -r <start> -e <end>`:
- Generate hostnames by combining the prefix with zero-padded numbers from start to end
- Ping each hostname and display responding hosts with their resolved IP
- Track and report how many nodes were **found** vs **not found** at the end of the scan
- Run pings in parallel using background subshells

### 8. Output Format

Your output should follow this structure:

```
----------------------------
Scanning web-server-01 - web-server-20 ...
----------------------------
[UP] web-server-03  (10.0.1.3)
[UP] web-server-07  (10.0.1.7)
[UP] web-server-12  (10.0.1.12)
----------------------------
Nodes found: 3
Nodes not found: 17
Scan complete.
```

## Example Commands

```bash
# Sweep a /24 subnet by IP prefix
./pingsweep.sh -i 192.168.1

# Auto-detect your local subnet and sweep it
./pingsweep.sh -d

# Sweep hostnames web-server-01 through web-server-20 with a 2-second timeout
./pingsweep.sh -n web-server- -r 01 -e 20 -t 2
```

## Hints

- Use `getopts` instead of `getopt` for cross-platform compatibility
- Use `uname` to detect the operating system
- Background subshells `( ... ) &` with `wait` allow parallel pings
- `mktemp -d` creates a temporary directory for coordinating results across subshells
- `seq` generates number ranges; `printf "%0Nd"` zero-pads numbers
- `host <ip>` performs reverse DNS lookups; `getent hosts <name>` resolves hostnames to IPs

## Deliverables

- A single script file named `pingsweep-yourname.sh`
- The script must be executable (`chmod +x pingsweep-yourname.sh`)
- The script must run without errors on the lab machines

## Submission

Submit your completed script by creating a pull request to the main repository. Make sure to include a brief description of your implementation and any challenges you faced.
