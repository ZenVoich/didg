# didg

CLI tool to fetch canister's public candid metadata and generate JS/TS bindings.

## Prerequisites

- [dfx](https://internetcomputer.org/docs/current/developer-docs/getting-started/install/#installing-dfx-via-dfxvm)
- [didc](https://github.com/dfinity/candid/releases)

## Installation

```bash
npm install -g didg
```

## Usage

```bash
didg <canister_id> <output_dir>
```

## Example

```bash
didg ryjl3-tyaaa-aaaaa-aaaba-cai declarations/ledger
```

Output structure:

```
declarations
└── ledger
    ├── index.js
    ├── ledger.did
    ├── ledger.did.d.ts
    └── ledger.did.js
```