# 🔮 Aztec Sequencer Node

> **Unveil the future of Ethereum scaling with Aztec's private and powerful sequencer technology**

---

## ⚡️ Quick Installation

```bash
bash <(curl -s https://raw.githubusercontent.com/furidngrt/Aztec-Sequencer-Node/refs/heads/master/Aztec.sh)
```

## 🔍 Node Monitoring Commands

### Watch Live Node Logs
Monitor your node's real-time activity:

```bash
cd aztec-node
```
```bash
docker-compose logs --tail=0 -f
```

### 📊 Check Current Block Height
Verify your node's synchronization progress:

```bash
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' \
http://localhost:8083 | jq -r ".result.proven.number"
```

### 🔐 Generate Proof for Validation
proof of your node's:

```bash
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getArchiveSiblingPath","params":["BLOCK NUMBER","BLOCK NUMBER"],"id":67}' \
http://localhost:8083 | jq -r ".result"
```

`["BLOCK NUMBER","BLOCK NUMBER"]` Replace with block number 

> **Note:** If proof output doesn't appear immediately, please wait 5-10 minutes as your node is initializing. For block reference, use the values specified in the Discord channel.

## 🔄 Update Instructions

When a new version is released, follow these steps to update your node:

1. Edit your `docker-compose.yml` file:

```bash
nano docker-compose.yml
```

2. Replace this line:

```yaml
image: aztecprotocol/aztec:0.85.0-alpha-testnet.5
```

With:

```yaml
image: aztecprotocol/aztec:alpha-testnet
```

3. Save and exit (`Ctrl+O`, then `Enter`, then `Ctrl+X`)

4. Update the image and restart your node:

```bash
docker-compose down
docker-compose pull
docker-compose --env-file .env up -d
```

### Optional: Update the Aztec CLI

If you're using the CLI and not just Docker Compose:

```bash
aztec-up alpha-testnet
```


## 🏆 Claim Your Operator Role

1. Join the official Aztec Discord: [https://discord.gg/aztec](https://discord.gg/aztec)
2. Navigate to the `#operators│start-here` channel
3. Use the command format:
   ```
   /operator start address: block-number: proof:
   ```

### Example submission:
```
address : 0x123...abc
block   : 20473
proof   : AAAX...XXX=
```

