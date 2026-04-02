# VeilChain (Zig) Testnet Node

VeilChain is a Zig-based blockchain node scaffold aligned with the whitepaper architecture:

- PoW mining with Blake3-backed block hashing
- ASERT-like difficulty retargeting
- Chain validation and append rules
- Shielded-ledger primitives (note commitment, nullifier set, commitment tree)
- Local multi-node testnet runner

## Quick Start

```bash
zig build
zig build test
zig build test-integration
zig build run -- status
zig build run -- mine 5
zig build run -- testnet 3 3
```

## Layout

- `src/consensus`: PoW, ASERT, chain management
- `src/crypto`: hash wrappers
- `src/ledger`: note and nullifier primitives
- `src/testnet`: local testnet simulator
- `src/p2p` and `src/rpc`: protocol and RPC stubs for next phases

## Production Readiness Path

The project includes a hardened foundation and deterministic execution model. Remaining production items:

- persistent storage (state DB, canonical block store, reorg handling)
- authenticated QUIC p2p networking and peer scoring
- full shielded transaction circuit and proof verification
- mempool policies and fee market implementation
- RPC API compatibility for wallets and ops
- observability (metrics, tracing, structured logs)
