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
docker-compose logs -f
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

> **Note:** If proof output doesn't appear immediately, please wait 5-10 minutes as your node is initializing. For block reference, use the values specified in the Discord channel.

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

