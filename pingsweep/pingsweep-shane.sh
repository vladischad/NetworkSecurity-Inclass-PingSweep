#!/bin/bash
# Ping Sweep Script - IP range or hostname prefix

usage() {
  cat <<EOF
Usage:
  IP mode:        $0 -i <network-prefix> [-t timeout]
  Auto-detect:    $0 -d [-t timeout]
  Hostname mode:  $0 -n <hostname-prefix> -r <start> -e <end> [-t timeout]

Options:
  -i    Network prefix for IP sweep (e.g., 192.168.1)
  -d    Auto-detect network prefix from this machine's IP
  -n    Hostname prefix for hostname sweep (e.g., web-server-)

  -r    Range start (required for hostname mode)
  -e    Range end (required for hostname mode)
  -t    Ping timeout in seconds (default: 1)
  -h/?  Show this help (alternative)

Examples:
  $0 -i 192.168.1
  $0 -i 10.0.0 -t 2
  $0 -d
  $0 -d -t 2
  $0 -n web-server- -r 1 -e 20
  $0 -n node -r 01 -e 12 -t 2
EOF
  exit 1
}

# Parse options with getopts (portable across macOS and Linux)
MODE=""
PREFIX=""
TIMEOUT=1
RANGE_START=""
RANGE_END=""

while getopts "i:n:r:e:t:dh?" opt; do
  case "$opt" in
    i) MODE="ip";       PREFIX="$OPTARG" ;;
    d) MODE="ip";       PREFIX="auto" ;;
    n) MODE="host";     PREFIX="$OPTARG" ;;
    r) RANGE_START="$OPTARG" ;;
    e) RANGE_END="$OPTARG" ;;
    t) TIMEOUT="$OPTARG" ;;
    h|?) usage ;;
  esac
done
shift $((OPTIND - 1))

# Auto-detect the local network prefix
get_local_prefix() {
  local ip=""
  if command -v ip &>/dev/null; then
    ip=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1); exit}')
  elif [ "$(uname)" = "Darwin" ]; then
    local iface
    iface=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')
    [ -n "$iface" ] && ip=$(ipconfig getifaddr "$iface" 2>/dev/null)
  fi
  if [ -z "$ip" ]; then
    echo "Error: Could not detect local IP address" >&2
    exit 1
  fi
  echo "$ip" | awk -F. '{print $1"."$2"."$3}'
}

if [ "$PREFIX" = "auto" ]; then
  PREFIX=$(get_local_prefix)
  echo "Detected network prefix: ${PREFIX}"
fi

validate() {
  [ -z "$MODE" ] || [ -z "$PREFIX" ] && usage
  if [ "$MODE" = "host" ]; then
    [ -z "$RANGE_START" ] || [ -z "$RANGE_END" ] && {
      echo "Error: Hostname mode requires -r <start> and -e <end>"
      usage
    }
  fi
}

# Build a portable ping command (macOS uses -t for timeout, Linux uses -W)
if [ "$(uname)" = "Darwin" ]; then
  ping_host() { ping -c 1 -t "$TIMEOUT" "$1" &>/dev/null; }
else
  ping_host() { ping -c 1 -W "$TIMEOUT" "$1" &>/dev/null; }
fi

ip_sweep() {
  echo "Scanning ${PREFIX}.1 - ${PREFIX}.254 ..."
  echo "----------------------------"
  for i in $(seq 1 254); do
    (
      TARGET="${PREFIX}.${i}"
      if ping_host "$TARGET"; then
        HOSTNAME=$(host "$TARGET" 2>/dev/null | awk '/domain name pointer/ {print $NF}' | sed 's/\.$//')
        [ -n "$HOSTNAME" ] && echo "[UP] $TARGET  ($HOSTNAME)" || echo "[UP] $TARGET"
      fi
    ) &
  done
}

host_sweep() {
  echo "Scanning ${PREFIX}${RANGE_START} - ${PREFIX}${RANGE_END} ..."
  echo "----------------------------"

  PAD_LEN=${#RANGE_START}
  UP_DIR=$(mktemp -d)

  for i in $(seq "$RANGE_START" "$RANGE_END"); do
    (
      PADDED=$(printf "%0${PAD_LEN}d" "$i")
      TARGET="${PREFIX}${PADDED}"
      if ping_host "$TARGET"; then
        IP=$(getent hosts "$TARGET" 2>/dev/null | awk '{print $1}')
        [ -n "$IP" ] && echo "[UP] $TARGET  ($IP)" || echo "[UP] $TARGET"
        touch "${UP_DIR}/${PADDED}.up"
      else
        touch "${UP_DIR}/${PADDED}.down"
      fi
    ) &
  done
}

validate

echo "----------------------------"

if [ "$MODE" = "ip" ]; then
  ip_sweep
else
  host_sweep
fi

wait
echo "----------------------------"
if [ "$MODE" = "host" ]; then
  FOUND=$(find "$UP_DIR" -name '*.up' 2>/dev/null | wc -l | tr -d ' ')
  NOT_FOUND=$(find "$UP_DIR" -name '*.down' 2>/dev/null | wc -l | tr -d ' ')
  echo "Nodes found: ${FOUND}"
  echo "Nodes not found: ${NOT_FOUND}"
  rm -rf "$UP_DIR"
fi
echo "Scan complete."