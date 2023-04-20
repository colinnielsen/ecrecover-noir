## Notes

To build the prover and verifier toml against the circuit

1. `nargo check`

2. Fill the prover

To create a proof in `proofs/`

3. `nargo prove [PROOF_NAME]`

To verifies the proof file in `proofs/`

4. `nargo verify [PROOF_NAME]`

empty keccak hahes
String = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
Address = 0x5380c7b7ae81a58eb98d9c78de4a1fd7fd9535fc953ed2be602daaa41767312a
Bytes = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
Uint = 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563

### Prover.toml

x + y of hardhat 0 address:

- private key = ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
- pub key = 0x8318535b54105d4a7aae60c08fc45f9687181b4fdfc625bd1a753fa7397fed753547f11ca8696646f2f3acb08e31016afac23e630c5d11f59f61fef57b0d2aa5
- keccak of pub key ^ 0xc1ffd3cfee2d9e5cd67643f8f39fd6e51aad88f6f4ce6ab8827279cfffb92266
- addr (right most 20 bytes) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
