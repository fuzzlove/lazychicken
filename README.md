# 🐔 LazyChicken

> A lightweight Bash-based public IP, VPN, DNS, IPv6, and network sanity-check utility.

LazyChicken queries multiple trusted public services to help you quickly verify your public IP, check for IPv6 exposure, compare provider responses, inspect DNS configuration, perform ASN/GeoIP lookups, and gather basic network diagnostics from a single script.

---

## 🚀 Quick Start

### Run Directly From GitHub

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/fuzzlove/lazychicken/main/lazychicken.sh)"
```

### Clone and Run Locally

```bash
git clone https://github.com/fuzzlove/lazychicken.git
cd lazychicken
chmod +x lazychicken.sh
./lazychicken.sh
```

---

# ✨ Features

## 🌎 Multi-Source Public IP Detection

Queries multiple providers and compares results:

- IP Chicken
- Icanhazip
- Ipify
- Ifconfig.me
- Ident.me
- AWS CheckIP
- TorGuard

This reduces dependence on any single source.

---

## 🔍 Consensus Verification

LazyChicken counts how many services report each IP address.

Example:

```text
8 source(s) reported: 203.0.113.15
2 source(s) reported: 2001:db8::1
```

Useful for identifying:

- VPN inconsistencies
- Proxy anomalies
- Endpoint failures
- IPv4/IPv6 differences

---

## 🌐 IPv6 Detection

Checks for IPv6 connectivity and warns if IPv6 is active.

Example:

```text
IPv6 is active. Make sure your VPN/proxy protects IPv6 traffic.
```

Helpful for detecting IPv6 leaks.

---

## ⚡ Response Time Measurements

Each source is timed individually.

Example:

```text
IP Chicken       320ms
Ipify             41ms
Ident.me          37ms
```

LazyChicken ranks providers and identifies the fastest responder.

---

## 🕵️ User-Agent Consistency Testing

Tests multiple User-Agent strings against a public IP endpoint.

Examples:

```text
curl/8.0.1
Mozilla/5.0
Mozilla/5.0 (Macintosh)
Mozilla/5.0 (Linux)
LazyChicken/1.0
```

Verifies whether different User-Agent headers produce different public IP results.

---

## 🏢 ASN / ISP Lookup

Attempts to identify:

- Autonomous System Number (ASN)
- ISP
- Organization

Example:

```text
ASN: AS12345
Org: Example VPN Inc.
```

Useful for confirming that traffic exits through the expected provider.

---

## 📍 GeoIP Lookup

Attempts to determine:

- Country
- Region
- City

Example:

```text
Country: United States
Region: Texas
City: Dallas
```

Helpful when validating VPN exit locations.

---

## 🧠 DNS Resolver Inspection

Displays locally configured DNS resolvers.

### macOS

```bash
scutil --dns
```

### Linux

```bash
resolvectl dns
```

or

```bash
cat /etc/resolv.conf
```

Useful for:

- DNS troubleshooting
- DNS leak detection
- VPN verification

---

## 🌐 External DNS Verification

If `dig` is installed, LazyChicken performs an external DNS diagnostic query.

This can reveal:

- Which resolver is being used
- Potential DNS leaks
- DNS forwarding behavior

---

## 🔒 HTTPS / TLS Sanity Check

Queries Cloudflare diagnostic endpoints to gather:

- Public IP seen by Cloudflare
- TLS version
- HTTP version
- Cloudflare data center (colo)

Example:

```text
Cloudflare saw IP: 203.0.113.15
TLS: TLSv1.3
HTTP: HTTP/3
Colo: DFW
```

Useful for spotting:

- Proxy behavior
- VPN routing differences
- TLS anomalies

---

## 🎨 Universal Terminal Colors

LazyChicken now uses:

```bash
tput
```

instead of hardcoded ANSI escape sequences.

Benefits:

- Better macOS compatibility
- Better Linux compatibility
- Better SSH compatibility
- Graceful fallback when colors are unavailable

Supported terminals include:

- macOS Terminal
- iTerm2
- GNOME Terminal
- Konsole
- Alacritty
- Kitty
- Most ANSI-compatible terminals

---

## 🙏 Source Credits

At the end of every run, LazyChicken displays:

```text
Brought to you by the following sources:
```

and lists all services used during execution.

Special thanks to the maintainers and operators of these free public services.

---

# 📋 Requirements

## Required

```bash
bash
curl
grep
awk
sort
head
sed
```

## Optional (Recommended)

```bash
dig
tput
scutil
resolvectl
```

### macOS

Typically available by default:

```bash
curl
awk
sed
grep
scutil
```

### Linux

You may need:

```bash
sudo apt install dnsutils
```

or

```bash
sudo dnf install bind-utils
```

for `dig`.

---

# 🧪 Example Use Cases

### Verify VPN Exit Node

Confirm:

- Public IP
- ASN
- ISP
- Country

---

### Check for IPv6 Leaks

Determine whether:

- IPv6 is active
- VPN protects IPv6

---

### Validate DNS Configuration

View:

- Local resolvers
- External resolver behavior

---

### Compare Public IP Providers

See whether:

- All providers agree
- Some providers disagree
- Endpoints are reachable

---

### Benchmark Public IP Services

Compare response times across providers.

---

# 📄 Example Output

```text
[*] Checking public IP from multiple sources...

[1] IP Chicken          203.0.113.15
    Response time: 310ms

[2] Ipify IPv4          203.0.113.15
    Response time: 42ms

[*] Consensus Check:

8 source(s) reported: 203.0.113.15

[*] Fastest Source Ranking:

Ipify IPv4     42ms
Ident.me       51ms
AWS CheckIP    73ms

Fastest responder: Ipify IPv4 at 42ms

[*] ASN / ISP / GeoIP Lookup:

ASN: AS12345
Org: Example VPN
Country: United States
Region: Texas
City: Dallas

[!] Done
```

---

# ⚠ Disclaimer

LazyChicken is intended for informational and diagnostic purposes.

Results may vary depending on:

- VPN provider
- Proxy configuration
- ISP routing
- CDN behavior
- GeoIP database accuracy
- DNS configuration

Public IP, ASN, DNS, and geolocation data are obtained from third-party services and may occasionally be inaccurate or inconsistent.

---

# ❤️ Contributing

Contributions, bug reports, feature requests, and pull requests are welcome.

If you'd like to add new diagnostic providers, improve platform compatibility, or contribute additional network checks, feel free to open an issue or submit a pull request.

---

# 🐓 LazyChicken

**Fast. Lightweight. Multi-source. No nonsense.**
