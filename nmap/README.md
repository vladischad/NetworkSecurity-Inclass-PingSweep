# In-Class Exercise: Network Scanning with Nmap

## Overview

This is a multi-day exercise where you will learn to use **Nmap** (Network Mapper), one of the most widely used network scanning tools in cybersecurity. You will scan a lab network to discover hosts, identify open ports, detect services, and understand what information an attacker (or a defender) can learn about a network.

> [!TIP]
> We will be updating this document in class as we go through the exercises. Make sure to check back here for the latest instructions and details on each step.

> [!WARNING]
> Only scan networks you have explicit permission to scan. In this exercise, you will only scan the lab network provided by your instructor. Scanning networks without authorization is illegal and unethical.

---

## What You Need

- A computer connected to the lab network
- Terminal access
- Nmap installed (check by typing `nmap --version` in your terminal)
- A notebook or text file to record your findings
- The lab network range provided in class

### What is an IP Address Range?

Throughout this exercise, you will see network ranges written like `10.0.0.0/24`. Here is what that means:

- `10.0.0.0` is the starting network address
- `/24` means the first 24 bits of the address are the "network part," leaving the last 8 bits for hosts
- In plain terms: `/24` covers all addresses from `10.0.0.1` through `10.0.0.254` (254 possible hosts)

## Host Discovery

**Goal:** Find out which devices are alive (connected and responding) on the lab network.

### What is Host Discovery?

Before you can scan a computer for open ports or services, you first need to know it exists. Host discovery is the process of finding which IP addresses on a network have a live device behind them. Think of it like knocking on every door in an apartment building to see who is home.

### Step 1: Ping Sweep

Use the [pingsweep.sh](../pingsweep/) script that we created in the previous exercise to perform a ping sweep and collect all the necessary information for nmap.


### Step 2: Basic Ping Scan Nmap Command

Use Nmap's ping scan to send a small message to each address and listen for a reply. It is the simplest way to discover hosts. Compare the results to your ping sweep script and see if you find the same hosts.

Run this command (replace `10.0.0.0/24` with your lab's network range):

```bash
nmap -sn 10.0.0.0/24
```

**What each part means:**
- `nmap` — the program you are running
- `-sn` — this flag tells Nmap to do a "ping scan" only (do NOT scan for open ports, just check if hosts are alive)
- `10.0.0.0/24` — the range of IP addresses to scan

**What to look for in the output:**

You will see output that looks something like this:
```
Nmap scan report for 10.0.0.1
Host is up (0.0023s latency).
Nmap scan report for 10.0.0.5
Host is up (0.0041s latency).
Nmap scan report for 10.0.0.12
Host is up (0.0018s latency).
...
Nmap done: 256 IP addresses (8 hosts up) scanned in 2.34 seconds
```

Each "Host is up" line is a device that responded. The number in parentheses (like `0.0023s latency`) is how long it took to respond, measured in seconds.

**Record your findings:**
1. How many total addresses were scanned?
2. How many hosts are up?
3. List every IP address that responded.
4. Which IP address is yours?

### Step 3: Save Your Results to a File

It is useful to save scan results so you can look at them later. Nmap can write output to a file for you.

Run the same scan, but save the results:

```bash
nmap -sn 10.0.0.0/24 -oN 1-ping-scan.txt
```

**What the new part means:**
- `-oN 1-ping-scan.txt` — save the output in "normal" format to a file called `1-ping-scan.txt`

After it finishes, you can view the saved file:

```bash
cat 1-ping-scan.txt
```

### Step 4: Understanding ARP vs ICMP

When you scan a network you are directly connected to (a "local" network), Nmap uses **ARP** (Address Resolution Protocol) instead of regular ping. ARP is more reliable because:

- ARP works at a lower level than ping
- Firewalls cannot easily block ARP on a local network
- ARP gets a response even from devices that block ping

You do not need to do anything different. Nmap automatically picks the best method. But it is important to understand that "ping scan" does not always mean ICMP ping.

### Step 5: Try a List Scan (No Actual Scanning)

Nmap can show you what it *would* scan without actually sending any packets. This is useful for double-checking your target range.

```bash
nmap -sL 10.0.0.0/24
```

**What this does:**
- `-sL` — "list scan" that only lists the targets, it does not send anything to the network
- Notice it also tries to look up hostnames using reverse DNS

**Record your findings:**
1. Did any IP addresses resolve to hostnames?
2. If so, what can the hostnames tell you about what those machines might be?

## Port Scanning and Service Detection

**Goal:** Discover what services are running on the live hosts you found.

### What are Ports?

Every networked computer has **65,535 ports** available. Think of ports like apartment numbers in a building — the IP address is the building's street address, and the port number tells you which apartment (service) to talk to.

Common port numbers and what they usually mean:

| Port | Service | What it Does                              |
| ---- | ------- | ----------------------------------------- |
| 22   | SSH     | Secure remote login (command line access) |
| 80   | HTTP    | Web server (unencrypted)                  |
| 443  | HTTPS   | Web server (encrypted)                    |
| 21   | FTP     | File transfer                             |
| 25   | SMTP    | Sending email                             |
| 53   | DNS     | Translating domain names to IP addresses  |
| 3306 | MySQL   | Database server                           |
| 3389 | RDP     | Windows remote desktop                    |

### Step 1: Scan a Single Host for Open Ports

Pick one of the live hosts you found on (NOT your own computer). Replace `10.0.0.5` below with the IP you choose.

```bash
nmap 10.0.0.5
```

When you run `nmap` with just an IP address and no flags, it performs a **default scan** that:
- Checks the **1,000 most common ports**
- Uses a **TCP SYN scan** (sends a connection request to each port and checks if it gets a reply)

**What to look for in the output:**

```
PORT     STATE  SERVICE
22/tcp   open   ssh
80/tcp   open   http
443/tcp  open   https
3306/tcp closed mysql
```

Each line tells you:
- **PORT** — the port number and protocol (tcp means it uses TCP)
- **STATE** — whether the port is `open` (accepting connections), `closed` (reachable but nothing is listening), or `filtered` (a firewall is blocking Nmap from telling)
- **SERVICE** — what service Nmap thinks is running, based on the port number

**Record your findings:**
1. Which host did you scan?
2. How many open ports did it have?
3. What services appear to be running?

### Step 2: Scan All Live Hosts

Now scan all the hosts you discovered. You can give Nmap multiple targets:

```bash
nmap 10.0.0.1 10.0.0.5 10.0.0.12
```

Or, to scan the entire range again (Nmap will automatically skip hosts that are down):

```bash
nmap 10.0.0.0/24 -oN 2-port-scan.txt
```

This will take longer than the ping scan because Nmap is checking 1,000 ports on each live host.

### Step 3: Service Version Detection

Knowing that port 80 is open tells you a web server is probably running, but what *kind* of web server? Apache? Nginx? What version? This matters because specific versions may have known vulnerabilities.

Run a version detection scan on one of your targets:

```bash
nmap -sV 10.0.0.5
```

**What the new part means:**
- `-sV` — probe open ports to determine the service name and version number

**What to look for in the output:**

```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.6
80/tcp open  http    Apache httpd 2.4.52
```

Now you can see not just "ssh" but the exact software and version: `OpenSSH 8.9p1`.

### Step 4: Scan Specific Ports

Sometimes you only care about certain ports. You can tell Nmap to scan specific ones:

**Scan a single port:**
```bash
nmap -p 22 10.0.0.5
```

**Scan a range of ports:**
```bash
nmap -p 1-100 10.0.0.5
```

**Scan a list of specific ports:**
```bash
nmap -p 22,80,443,3306 10.0.0.5
```

**Scan ALL 65,535 ports (this takes a while):**
```bash
nmap -p- 10.0.0.5
```

**What the flag means:**
- `-p` — specifies which ports to scan
- `-p-` — shorthand for `-p 1-65535` (every possible port)

### Step 5: Understanding Port States

You may see three different port states. Here is what each one means:

| State      | Meaning                                                                                   |
| ---------- | ----------------------------------------------------------------------------------------- |
| `open`     | A service is actively listening and accepting connections on this port                    |
| `closed`   | The port is reachable (no firewall blocking it) but nothing is listening                  |
| `filtered` | Nmap cannot tell if the port is open or closed because a firewall is dropping the packets |

### Step 6: Combine Version Detection with Full Results

Run a thorough scan on one host and save the output:

```bash
nmap -sV -p 1-1024 10.0.0.5 -oN 2-service-scan.txt
```

This scans ports 1 through 1024 (all "well-known" ports) with version detection and saves the results.

---

## OS Detection, Scripting Engine, and Reporting

**Goal:** Identify operating systems, run Nmap's built-in vulnerability scripts, and compile a professional network report.

### Step 1: Operating System Detection (Instructor Demo)

**NOTE:** Students do not have sudo privileges, so you will not be able to run this scan yourself. Your instructor will demonstrate this scan in class.

Nmap can guess what operating system a host is running by analyzing how it responds to specially crafted packets. Different operating systems implement network protocols in slightly different ways, and Nmap uses these differences as fingerprints.

> **Note:** OS detection requires root/admin privileges. You will need to use `sudo`.

```bash
sudo nmap -O 10.0.0.5
```

**What the new part means:**
- `sudo` — runs the command with administrator privileges (you may need to enter your password)
- `-O` — enable OS detection (that is a capital letter O, not the number zero)

**What to look for in the output:**

```
OS details: Linux 5.4 - 5.15
```

or

```
OS details: Microsoft Windows 10 1903 - 21H2
```

Nmap may show multiple guesses with confidence percentages. The highest percentage is its best guess.

**Record your findings:**
1. What operating systems were detected on the live hosts?
2. Were any results surprising?

### Step 2: The Nmap Scripting Engine (NSE)

Nmap includes hundreds of built-in scripts that can check for specific vulnerabilities, gather extra information, and even attempt basic brute-force tests. These scripts are organized into categories.

**Common script categories:**

| Category    | What it Does                                   |
| ----------- | ---------------------------------------------- |
| `default`   | Safe, general-purpose information gathering    |
| `discovery` | Extra host and service discovery techniques    |
| `vuln`      | Checks for known security vulnerabilities      |
| `safe`      | Scripts that are non-intrusive and safe to run |
| `auth`      | Checks for authentication weaknesses           |

### Step 3: Run Default Scripts

The default scripts gather useful extra information without being aggressive:

```bash
nmap -sC 10.0.0.5
```

**What the new part means:**
- `-sC` — run the "default" category of Nmap scripts against open ports

You will see extra information appear under each port. For example, an SSH port might show:

```
22/tcp open  ssh
| ssh-hostkey:
|   3072 aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99 (RSA)
|   256  aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99 (ECDSA)
```

This shows you the SSH host keys, which uniquely identify that server.

A web server port might show:

```
80/tcp open  http
| http-title: Welcome to Our Lab Server
|_http-server-header: Apache/2.4.52 (Ubuntu)
```

This tells you the web page title and the server header.

### Step 4: Combine Everything into One Scan

You can combine multiple scan types into one command. This is the most common "thorough scan" that security professionals use:

```bash
sudo nmap -sV -sC -O 10.0.0.5 -oN 3-full-scan.txt
```

This single command does:
- `-sV` — detect service versions
- `-sC` — run default scripts
- `-O` — detect the operating system
- `-oN` — save results to a file

### Step 5: Check for Vulnerabilities

> **Important:** Only run vulnerability scans on lab machines you have permission to test.

Nmap can check for known security vulnerabilities:

```bash
nmap --script vuln 10.0.0.5
```

**What this does:**
- `--script vuln` — runs all scripts in the "vuln" category

This may take several minutes. When it finishes, look for output that says things like:

```
| vulners:
|   cve-2021-XXXXX  7.5  https://vulners.com/cve/CVE-2021-XXXXX
```

Each **CVE** (Common Vulnerabilities and Exposures) is a publicly known security flaw. The number (like 7.5) is the severity score from 0 to 10, where 10 is the most critical.

### Step 6: Scan a Specific Service with a Specific Script

You can also run individual scripts. For example, to check what HTTP methods a web server allows:

```bash
nmap --script http-methods -p 80 10.0.0.5
```

Or to grab the banner (greeting message) from any service:

```bash
nmap --script banner -p 22 10.0.0.5
```

To see all available scripts on your system:

```bash
ls /usr/share/nmap/scripts/ | head -20
```

(This shows the first 20 scripts. There are hundreds.)


---

## Nmap Quick Reference

| Command                         | What it Does                         |
| ------------------------------- | ------------------------------------ |
| `nmap -sn <range>`              | Ping scan (host discovery only)      |
| `nmap <target>`                 | Default port scan (top 1,000 ports)  |
| `nmap -p <ports> <target>`      | Scan specific ports                  |
| `nmap -p- <target>`             | Scan all 65,535 ports                |
| `nmap -sV <target>`             | Detect service versions              |
| `nmap -sC <target>`             | Run default scripts                  |
| `nmap -O <target>`              | Detect operating system (needs sudo) |
| `nmap --script <name> <target>` | Run a specific script or category    |
| `nmap -oN <file> <target>`      | Save output to a text file           |
| `nmap -sV -sC -O <target>`      | Combined thorough scan (needs sudo)  |

## Common Troubleshooting

**"Permission denied" or "requires root"**
Some scan types (like OS detection with `-O`) need administrator access. Add `sudo` before the command.

**Scan is taking a very long time**
Scanning all 65,535 ports or running scripts on many hosts is slow. Start with smaller scans (fewer ports, one host at a time) and expand from there.

**"Host seems down" but you know it is on**
Some hosts block ping. Try adding `-Pn` to skip host discovery and scan the ports directly:
```bash
nmap -Pn 10.0.0.5
```

**No results showing up**
Make sure you are on the correct network and using the right IP range. Double-check with your instructor.
