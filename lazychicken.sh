#!/usr/bin/env bash

set -u

# ---------- Colors ----------
if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
  BOLD="$(tput bold)"
  BLUE="$(tput setaf 4)"
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  CYAN="$(tput setaf 6)"
  RESET="$(tput sgr0)"
else
  BOLD=""; BLUE=""; RED=""; GREEN=""; YELLOW=""; CYAN=""; RESET=""
fi

ipv4_regex='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
ipv6_regex='([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}'

results=()
timings=()
queried_sources=()

sources=(
  "IP Chicken|https://ipchicken.com|ipv4"
  "Icanhazip|https://icanhazip.com|any"
  "Icanhazip IPv4|https://ipv4.icanhazip.com|ipv4"
  "Icanhazip IPv6|https://ipv6.icanhazip.com|ipv6"
  "Ipify IPv4|https://api.ipify.org|ipv4"
  "Ipify IPv6|https://api64.ipify.org|any"
  "Ifconfig.me|https://ifconfig.me/ip|any"
  "Ident.me|https://ident.me|any"
  "Ident.me IPv4|https://4.ident.me|ipv4"
  "Ident.me IPv6|https://6.ident.me|ipv6"
  "AWS CheckIP|https://checkip.amazonaws.com|ipv4"
  "TorGuard|https://torguard.net/whats-my-ip.php|ipv4"
)

fetch_ip() {
  local url="$1"
  local version="${2:-any}"
  local output body timing ip

  output="$(curl -fsSL --max-time 8 -w '\nLC_TIME:%{time_total}' "$url" 2>/dev/null || true)"
  timing="$(printf "%s" "$output" | awk -F: '/LC_TIME:/ {printf "%.0fms", $2 * 1000}')"
  body="$(printf "%s" "$output" | sed '/LC_TIME:/d')"

  case "$version" in
    ipv4)
      ip="$(printf "%s" "$body" | grep -Eo "$ipv4_regex" | sort -u | head -1)"
      ;;
    ipv6)
      ip="$(printf "%s" "$body" | grep -Eio "$ipv6_regex" | grep ':' | sort -u | head -1)"
      ;;
    *)
      ip="$(printf "%s" "$body" | grep -Eo "$ipv4_regex|$ipv6_regex" | grep -E '\.|:' | sort -u | head -1)"
      ;;
  esac

  printf "%s|%s" "${ip:-Unavailable}" "${timing:-Unavailable}"
}

print_result() {
  local number="$1"
  local name="$2"
  local ip="$3"
  local elapsed="$4"

  if [ "$ip" = "Unavailable" ]; then
    printf "%b[%s]%b %-22s %b%s%b\n" "$RED" "$number" "$RESET" "$name:" "$YELLOW" "$ip" "$RESET"
  else
    printf "%b[%s]%b %-22s %b%s%b\n" "$CYAN" "$number" "$RESET" "$name:" "$GREEN" "$ip" "$RESET"
  fi

  printf "    %bResponse time:%b %s\n\n" "$YELLOW" "$RESET" "$elapsed"
}

banner() {
  printf "%b" "$BOLD$BLUE"
  printf " _                         ____ _     _      _              \n"
  printf "| |    __ _ _____   _     / ___| |__ (_) ___| | _____ _ __  \n"
  printf "| |   / _\` |_  / | | |   | |   | '_ \\| |/ __| |/ / _ \\ '_ \\ \n"
  printf "| |__| (_| |/ /| |_| |   | |___| | | | | (__|   <  __/ | | |\n"
  printf "|_____\\__,_/___|\\__, |    \\____|_| |_|_|\\___|_|\\_\\___|_| |_|\n"
  printf "                |___/                                       \n"
  printf "%b\n" "$RESET"
}

banner

printf "%b\n\n" "${BOLD}${BLUE}[*] Checking public IP from multiple sources...${RESET}"

count=1
for source in "${sources[@]}"; do
  IFS='|' read -r name url version <<EOF
$source
EOF

  queried_sources+=("$name|$url")

  response="$(fetch_ip "$url" "$version")"
  ip="${response%%|*}"
  elapsed="${response##*|}"

  print_result "$count" "$name" "$ip" "$elapsed"

  if [ "$ip" != "Unavailable" ]; then
    results+=("$ip")
  fi

  if printf "%s" "$elapsed" | grep -q 'ms'; then
    ms="$(printf "%s" "$elapsed" | tr -dc '0-9')"
    timings+=("$ms|$name|$elapsed")
  fi

  count=$((count + 1))
done

# ---------- Consensus ----------
printf "%b\n" "${BOLD}${BLUE}[*] Consensus Check:${RESET}"

if [ "${#results[@]}" -eq 0 ]; then
  printf "%b\n" "${RED}No valid IP results returned.${RESET}"
else
  printf "%s\n" "${results[@]}" |
    sort |
    uniq -c |
    sort -nr |
    while read -r hits ip; do
      printf "%b%s%b source(s) reported: %b%s%b\n" "$YELLOW" "$hits" "$RESET" "$GREEN" "$ip" "$RESET"
    done
fi

# ---------- IPv6 ----------
printf "\n%b\n" "${BOLD}${BLUE}[*] IPv6 Check:${RESET}"

ipv6_hits="$(printf "%s\n" "${results[@]:-}" | grep -c ':' || true)"

if [ "$ipv6_hits" -gt 0 ]; then
  printf "%b\n" "${YELLOW}IPv6 is active. Make sure your VPN/proxy protects IPv6 traffic.${RESET}"
else
  printf "%b\n" "${GREEN}No IPv6 address detected from tested sources.${RESET}"
fi

# ---------- Fastest Ranking ----------
printf "\n%b\n" "${BOLD}${BLUE}[*] Fastest Source Ranking:${RESET}"

if [ "${#timings[@]}" -eq 0 ]; then
  printf "%b\n" "${YELLOW}No timing data available.${RESET}"
else
  printf "%s\n" "${timings[@]}" |
    sort -n |
    while IFS='|' read -r ms name elapsed; do
      printf "  %b%-22s%b %s\n" "$CYAN" "$name" "$RESET" "$elapsed"
    done

  fastest="$(printf "%s\n" "${timings[@]}" | sort -n | head -1)"
  fastest_name="$(printf "%s" "$fastest" | cut -d'|' -f2)"
  fastest_time="$(printf "%s" "$fastest" | cut -d'|' -f3)"

  printf "\n%bFastest responder:%b %s at %s\n" "$GREEN" "$RESET" "$fastest_name" "$fastest_time"
fi

# ---------- User-Agent Test ----------
printf "\n%b\n" "${BOLD}${BLUE}[*] User-Agent IP Consistency Test:${RESET}"

user_agents=(
  "LazyChicken/1.0"
  "curl/8.0.1"
  "Mozilla/5.0"
  "Mozilla/5.0 (Macintosh; Intel Mac OS X)"
  "Mozilla/5.0 (X11; Linux x86_64)"
)

ua_test_url="https://api.ipify.org"
queried_sources+=("User-Agent Test|$ua_test_url")

ua_results=()
ua_count=1

for ua in "${user_agents[@]}"; do
  body="$(curl -fsSL --max-time 8 -A "$ua" "$ua_test_url" 2>/dev/null || true)"
  ip="$(printf "%s" "$body" | grep -Eo "$ipv4_regex|$ipv6_regex" | grep -E '\.|:' | sort -u | head -1)"
  ip="${ip:-Unavailable}"

  printf "%b[%s]%b Agent: %b%s%b\n" "$CYAN" "$ua_count" "$RESET" "$YELLOW" "$ua" "$RESET"
  printf "    Result: %b%s%b\n\n" "$GREEN" "$ip" "$RESET"

  if [ "$ip" != "Unavailable" ]; then
    ua_results+=("$ip")
  fi

  ua_count=$((ua_count + 1))
done

printf "%b\n" "${BOLD}${BLUE}[*] User-Agent Consensus:${RESET}"

if [ "${#ua_results[@]}" -eq 0 ]; then
  printf "%b\n" "${RED}No valid User-Agent test results returned.${RESET}"
else
  printf "%s\n" "${ua_results[@]}" |
    sort |
    uniq -c |
    sort -nr |
    while read -r hits ip; do
      printf "%b%s%b User-Agent test(s) reported: %b%s%b\n" "$YELLOW" "$hits" "$RESET" "$GREEN" "$ip" "$RESET"
    done
fi

# ---------- ASN / ISP / GeoIP ----------
printf "\n%b\n" "${BOLD}${BLUE}[*] ASN / ISP / GeoIP Lookup:${RESET}"

primary_ip="$(printf "%s\n" "${results[@]:-}" | grep -E "$ipv4_regex" | sort | uniq -c | sort -nr | awk 'NR==1 {print $2}')"

if [ -z "${primary_ip:-}" ]; then
  printf "%b\n" "${YELLOW}No IPv4 address available for ASN/GeoIP lookup.${RESET}"
else
  queried_sources+=("ipapi.co|https://ipapi.co")

  asn="$(curl -fsSL --max-time 8 "https://ipapi.co/$primary_ip/asn/" 2>/dev/null || true)"
  org="$(curl -fsSL --max-time 8 "https://ipapi.co/$primary_ip/org/" 2>/dev/null || true)"
  country="$(curl -fsSL --max-time 8 "https://ipapi.co/$primary_ip/country_name/" 2>/dev/null || true)"
  region="$(curl -fsSL --max-time 8 "https://ipapi.co/$primary_ip/region/" 2>/dev/null || true)"
  city="$(curl -fsSL --max-time 8 "https://ipapi.co/$primary_ip/city/" 2>/dev/null || true)"

  printf "  %bIP:%b       %s\n" "$CYAN" "$RESET" "$primary_ip"
  printf "  %bASN:%b      %s\n" "$CYAN" "$RESET" "${asn:-Unavailable}"
  printf "  %bOrg/ISP:%b  %s\n" "$CYAN" "$RESET" "${org:-Unavailable}"
  printf "  %bCountry:%b  %s\n" "$CYAN" "$RESET" "${country:-Unavailable}"
  printf "  %bRegion:%b   %s\n" "$CYAN" "$RESET" "${region:-Unavailable}"
  printf "  %bCity:%b     %s\n" "$CYAN" "$RESET" "${city:-Unavailable}"
fi

# ---------- DNS Resolver Test ----------
printf "\n%b\n" "${BOLD}${BLUE}[*] DNS Resolver / Leak Hint:${RESET}"

printf "%b\n" "${YELLOW}Local configured resolvers:${RESET}"

if command -v scutil >/dev/null 2>&1; then
  scutil --dns 2>/dev/null | awk '/nameserver\[[0-9]+\]/ {print "  - " $3}' | sort -u
elif command -v resolvectl >/dev/null 2>&1; then
  resolvectl dns 2>/dev/null | sed 's/^/  /'
elif [ -f /etc/resolv.conf ]; then
  awk '/^nameserver/ {print "  - " $2}' /etc/resolv.conf | sort -u
else
  printf "  %bUnavailable%b\n" "$YELLOW" "$RESET"
fi

if command -v dig >/dev/null 2>&1; then
  queried_sources+=("Google DNS Diagnostic|o-o.myaddr.l.google.com")
  dns_seen="$(dig +short TXT o-o.myaddr.l.google.com @ns1.google.com 2>/dev/null | tr -d '"')"

  printf "\n%bDNS query source seen by Google diagnostic:%b\n" "$YELLOW" "$RESET"

  if [ -n "$dns_seen" ]; then
    printf "  %s\n" "$dns_seen"
  else
    printf "  %bUnavailable%b\n" "$YELLOW" "$RESET"
  fi
else
  printf "\n%bdig not found, skipping external DNS resolver test.%b\n" "$YELLOW" "$RESET"
fi

# ---------- TLS / Proxy Sanity ----------
printf "\n%b\n" "${BOLD}${BLUE}[*] HTTPS / TLS Proxy Sanity Check:${RESET}"

queried_sources+=("Cloudflare Trace|https://www.cloudflare.com/cdn-cgi/trace")

cf_trace="$(curl -fsSL --max-time 8 https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null || true)"

if [ -z "$cf_trace" ]; then
  printf "%b\n" "${YELLOW}Cloudflare trace unavailable.${RESET}"
else
  cf_ip="$(printf "%s\n" "$cf_trace" | awk -F= '/^ip=/ {print $2}')"
  cf_tls="$(printf "%s\n" "$cf_trace" | awk -F= '/^tls=/ {print $2}')"
  cf_colo="$(printf "%s\n" "$cf_trace" | awk -F= '/^colo=/ {print $2}')"
  cf_http="$(printf "%s\n" "$cf_trace" | awk -F= '/^http=/ {print $2}')"

  printf "  %bCloudflare saw IP:%b %s\n" "$CYAN" "$RESET" "${cf_ip:-Unavailable}"
  printf "  %bTLS:%b               %s\n" "$CYAN" "$RESET" "${cf_tls:-Unavailable}"
  printf "  %bHTTP:%b              %s\n" "$CYAN" "$RESET" "${cf_http:-Unavailable}"
  printf "  %bColo:%b              %s\n" "$CYAN" "$RESET" "${cf_colo:-Unavailable}"

  if [ -n "${cf_ip:-}" ] && printf "%s\n" "${results[@]:-}" | grep -qx "$cf_ip"; then
    printf "  %bCloudflare IP agrees with other sources.%b\n" "$GREEN" "$RESET"
  else
    printf "  %bCloudflare IP differs or was not in the main consensus set.%b\n" "$YELLOW" "$RESET"
  fi
fi

# ---------- Credits ----------
printf "\n%b\n" "${BOLD}${BLUE}[*] Brought to you by the following sources:${RESET}"

printf "%s\n" "${queried_sources[@]}" |
  sort -u |
  while IFS='|' read -r name url; do
    printf "  %b•%b %-24s - %s\n" "$CYAN" "$RESET" "$name" "$url"
  done

printf "\n%b\n" "${YELLOW}Kudos and thanks to the operators and maintainers of these public services for supporting useful network diagnostics.${RESET}"

printf "\n%b\n" "${BOLD}${GREEN}[!] Done${RESET}"
