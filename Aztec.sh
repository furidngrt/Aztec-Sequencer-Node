#!/bin/bash
set -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}Starting Auto Install Aztec...${NC}"
sleep 3

log() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Fancy box characters
    local top_left="╔"
    local top_right="╗"
    local bottom_left="╚"
    local bottom_right="╝"
    local horizontal="═"
    local vertical="║"
    
    # Calculate box width based on message length
    local msg_length=${#message}
    local date_length=${#timestamp}
    local max_length=$((msg_length > date_length ? msg_length : date_length))
    local width=$((max_length + 20))
    
    # Create top border
    local top_border="$top_left"
    for ((i=0; i<width; i++)); do
        top_border+="$horizontal"
    done
    top_border+="$top_right"
    
    # Create bottom border
    local bottom_border="$bottom_left"
    for ((i=0; i<width; i++)); do
        bottom_border+="$horizontal"
    done
    bottom_border+="$bottom_right"
    
    # Create level-specific icon and color
    local icon
    local color
    case $level in
        "INFO") 
            icon="ℹ️ "
            color=$CYAN
            ;;
        "SUCCESS") 
            icon="✅ "
            color=$GREEN
            ;;
        "ERROR") 
            icon="❌ "
            color=$RED
            ;;
        *) 
            icon="⚠️ "
            color=$YELLOW
            ;;
    esac
    
    # Print formatted log
    echo -e "${color}${top_border}${NC}"
    echo -e "${color}${vertical}${NC} ${icon}${color}${level}${NC} - ${timestamp}"
    echo -e "${color}${vertical}${NC} ${message}"
    echo -e "${color}${bottom_border}${NC}\n"
}

find_free_port() {
    local port=$1
    while ss -tuln | grep -q ":$port"; do ((port++)); done
    echo "$port"
}

open_port() {
    local port=$1
    if command -v ufw &>/dev/null; then
        sudo ufw allow "$port" >/dev/null 2>&1 || true
    fi
}

read -rp "Enter your Validator Private Key (must start with 0x): " VALIDATOR_PRIVATE_KEY

if [[ ! "$VALIDATOR_PRIVATE_KEY" =~ ^0x[a-fA-F0-9]{64}$ ]]; then
    echo -e "${RED}Invalid private key format. It must start with '0x' followed by 64 hexadecimal characters.${NC}"
    exit 1
fi

log "INFO" "1. Update system"
sudo apt update && sudo apt upgrade -y

log "INFO" "2. Install Docker"
if ! command -v docker &>/dev/null; then
    sudo apt install -y ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
fi

log "INFO" "3. Install Docker Compose"
if ! command -v docker-compose &>/dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

log "INFO" "4. Install Node.js"
if ! command -v node &>/dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
fi

log "INFO" "5. Install Aztec CLI"
curl -sL https://install.aztec.network | bash
export PATH="$HOME/.aztec/bin:$PATH"
aztec-up alpha-testnet

ETH_RPC="https://ethereum-sepolia.publicnode.com"
CONS_RPC="https://rpc.sepolia.org"
BLOB_SINK_URL="https://rpc.drpc.org/eth/sepolia/beacon"
PUBLIC_IP=$(curl -s ifconfig.me || echo "127.0.0.1")

log "INFO" "6. Finding free ports"
HTTP_PORT=$(find_free_port 8080)
P2P_PORT=$(find_free_port $((HTTP_PORT + 1)))
METRICS_PORT=$(find_free_port $((P2P_PORT + 1)))

open_port "$HTTP_PORT"
open_port "$P2P_PORT"
open_port "$METRICS_PORT"

log "INFO" "7. Setting up folder & configuration files"
mkdir -p ~/aztec-node/data
cd ~/aztec-node

cat > .env <<EOF
ETHEREUM_HOSTS=$ETH_RPC
L1_CONSENSUS_HOST_URLS=$CONS_RPC
P2P_IP=$PUBLIC_IP
VALIDATOR_PRIVATE_KEY=$VALIDATOR_PRIVATE_KEY
DATA_DIRECTORY=/data
LOG_LEVEL=debug
BLOB_SINK_URL=$BLOB_SINK_URL
HTTP_PORT=$HTTP_PORT
P2P_PORT=$P2P_PORT
METRICS_PORT=$METRICS_PORT
EOF

chmod 644 .env

cat > docker-compose.yml <<EOF
version: "3.8"
services:
  node:
    image: aztecprotocol/alpha-testnet
    ports:
      - "8083:8080"
    environment:
      - ETHEREUM_HOSTS=\${ETHEREUM_HOSTS}
      - L1_CONSENSUS_HOST_URLS=\${L1_CONSENSUS_HOST_URLS}
      - P2P_IP=\${P2P_IP}
      - VALIDATOR_PRIVATE_KEY=\${VALIDATOR_PRIVATE_KEY}
      - DATA_DIRECTORY=\${DATA_DIRECTORY}
      - LOG_LEVEL=\${LOG_LEVEL}
      - BLOB_SINK_URL=\${BLOB_SINK_URL:-}
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --node --archiver --sequencer '
    volumes:
      - /home/ubuntu/Aztec-Node/data:/data
EOF

log "INFO" "8. Starting the node"
docker-compose --env-file .env up -d

log "SUCCESS" "Node active at:"
echo -e "${GREEN} : $PUBLIC_IP:$METRICS_PORT${NC}"
