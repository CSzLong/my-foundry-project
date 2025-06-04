## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```


```bash
manga-nft-client $ node createAccount.js
地址: 0x1E86A3da7301AC98DD170278E2c5cF9D6d9616C7
私钥: 0x8a6572ce1640d63f799a89300769b900cda504871a64a499391eb84d0f9ccd26
助记词: raise own put skirt glimpse worry affair sick energy column elbow gas
manga-nft-client $ node createAccount.js
地址: 0x9d7D6b191255919A608027F138B577bE8b701509
私钥: 0xc624bbcb85e61428c226c72bda1001b04c6645b50b2e52ff9296d91031ecf299
助记词: vault power isolate also park basket leaf fluid sorry need border empty
manga-nft-client $ node createAccount.js
地址: 0xE1a4Ea9dA78b2c3efdF3B9168fafB8A1CE3A9FF5
私钥: 0xb9003731f8912f6e19957a1434e3023a594daba4157f2c5b9c0e46d3421737a9
助记词: humble always disease endorse vital spell check bless dice enable fade security
manga-nft-client $ node createAccount.js
地址: 0x79077202FDde410d2298492DCD66A52d50444109
私钥: 0xff10ddc402a3b01f3caf695c6846a547ce982825f0c9e97dd7329148ad397093
助记词: ignore army fossil custom turn giant mouse shield hand pen there patient
manga-nft-client $ node createAccount.js
地址: 0xdbe41aFD9e285b446735Ca523C53a01Ad98e78C9
私钥: 0xa964475d567008584074d8a222dbaf2115aebfc32e3db867b5eb8951d768e57b
助记词: onion giant snap knife try exercise panel east sell wrap trade kite
manga-nft-client $ node createAccount.js
地址: 0xb37580bfE68Ed89A0121d8D8897Db4edCD7658b3
私钥: 0xe7281050a44229b2a3b2e54ee7321e90fc35ac908c028cf45a330e2517464674
助记词: pattern sock pepper spatial hawk monitor ribbon loyal envelope liquid eternal chunk
```