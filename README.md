# ECRecover Noir

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Noir-Tests](https://github.com/colinnielsen/noir-array-helpers/actions/workflows/noir.yml/badge.svg)](https://github.com/colinnielsen/noir-array-helpers/actions/workflows/noir.yml)

**This software is unaudited and should not be used in production. Use at your own risk.**

<hr>

**ECRecover Noir** includes tools to help prove secp256k1 signatures (Ethereum's curve) in Noir Circuits.

The goal of this lib is to have a function, which mimics the functionality of Solidity's [`ecrecover`](https://docs.soliditylang.org/en/v0.8.17/units-and-global-variables.html#mathematical-and-cryptographic-functions) function, where given a `hash` and a `signature`, it returns the Ethereum address that signed the message. Unfortunately, for this naive implmentation we need the Ethereum account's full Public key (two concatenated 32byte x and y coordinates on the secp256k1 curve). An address's Public key is safe for public storage, and can actually be determined from any signed message, or an Etheruem transaction. See [this section](#getting-an-accounts-public-key) for a typescript helper. There are also inputs in the [Prover.toml](./Prover.toml) file for reference.

A fully fledged `ecrecover` may be released in the future, but it would be an incredibly massive, unoptimized circuit. For now, this is a good starting point.

<br>

## Installation

In your `Nargo.toml` file, add the following dependency:

```toml
[dependencies]
ecrecover = { tag = "v0.10.1", git = "https://github.com/colinnielsen/ecrecover-noir" }
```

## Simple Usage

```rust
use dep::std;
use dep::ecrecover;

fn main(
  pub_key_x: [u8; 32],
  pub_key_y: [u8; 32],
  signature: [u8; 64],
  hashed_message: pub [u8; 32]
) -> pub Field {
  let address = ecrecover::ecrecover(pub_key_x, pub_key_y, signature, hashed_message);
  std::println(address);

  address // address is represented as `Field`, but is constrained to be within 160 bits
}
```

## PubKey struct

Behind the scenes, this library uses the `PubKey` struct to handle different operations in a module called [`secp256k1`](/src/secp256k1.nr).

### Definition

```rust
struct PubKey {
    pub_x: [u8; 32],
    pub_y: [u8; 32],
}
```

### Initialization

#### `PubKey::from_xy(pub_x: [u8; 32], pub_y: [u8; 32]) -> PubKey`

Initialize a `PubKey` struct using a the x and y coordinates of the public key:

**NOTE**: given Nargo `v0.6.0`, this is the most efficient initializer, and should be preferred. The other initializers will match efficiency once the `unconstrained` keyword is implemented.

```rust
use dep::ecrecover;
// ...
let key = ecrecover::secp256k1::PubKey::from_xy(pub_x, pub_y);
```

#### `PubKey::from_unified(pub_key: [u8; 64]) -> PubKey`

A helper constructor, which splits the inputs a concatenated public key for you:

```rust
use dep::ecrecover;
// ...
let key = ecrecover::secp256k1::PubKey::from_unified(pub_key);
```

#### `PubKey::from_uncompressed(pub_key: [u8; 65]) -> PubKey`

Another helper constructor, which assumes the 0x04 prefix for uncompressed public keys (`pub_key[0] == 0x04` is checked):

```rust
use dep::ecrecover;
// ...
let key = ecrecover::secp256k1::PubKey::from_uncompressed(pub_key);
```

<br>

#### Methods

The following methods are available on the `PubKey` struct:

#### `PubKey.verify_sig(signature: [u8; 64], hashed_message: [u8; 32]) -> bool`

Returns whether the signature is valid for the hashed message:

```rust
use dep::ecrecover;
// ...
let key = ecrecover::secp256k1::PubKey::from_xy(pub_x, pub_y);
let is_valid = key.verify_sig(signature, hashed_message);

std::println(is_valid); // true
```

#### `PubKey.to_eth_address(self) -> Field`

Converts the `PubKey` to an Ethereum address as a 160 bit Field element - this is done by keccak256 hashing the concatenated x and y coordinates of the public key, and returning the last 160 bits:

```rust
let key = ecrecover::secp256k1::PubKey::from_xy(pub_x, pub_y);
let addr = key.to_eth_address();

std::println(addr); // 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
```

#### `PubKey.ecrecover(signature: [u8; 64], hashed_message: [u8; 32]) -> Field`

A convenience method, which combines the `verify_sig` and `to_eth_address` methods into one. This is the method used in the main `ecrecover` function:

```rust
let key = ecrecover::secp256k1::PubKey::from_xy(pub_x, pub_y);
let addr = key.ecrecover(signature, hashed_message);

std::println(addr); // 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
```

<br>
<br>

# References

## Getting An Account's Public Key

### From a signed message:

You can use the following typescript + ethers code to get an account's public key from a signed message:

```typescript
import { ethers } from "ethers";

async function main() {
  // hardhat wallet 0
  const sender = new ethers.Wallet(
    "ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
  );

  console.log("\x1b[34m%s\x1b[0m", "signing message 🖋: ", message);

  const signature = await sender.signMessage(message); // get the signature of the message, this will be 130 bytes (concatenated r, s, and v)

  console.log("signature 📝: ", signature);

  let pubKey_uncompressed = ethers.utils.recoverPublicKey(digest, signature);
  console.log("uncompressed pubkey: ", pubKey_uncompressed);

  // recoverPublicKey returns `0x{hex"4"}{pubKeyXCoord}{pubKeyYCoord}` - so slice 0x04 to expose just the concatenated x and y
  //    see https://github.com/indutny/elliptic/issues/86 for a non-explanation explanation 😂
  let pubKey = pubKey_uncompressed.slice(4);

  let pub_key_x = pubKey.substring(0, 64);
  console.log("public key x coordinate 📊: ", pub_key_x);

  let pub_key_y = pubKey.substring(64);
  console.log("public key y coordinate 📊: ", pub_key_y);
}

main();
```

### From a transaction (TODO):

<br>

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/colinnielsen/noir-array-helpers/blob/main/LICENSE) file for details.
