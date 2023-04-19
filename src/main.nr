use dep::std;
use dep::keccak256;
use dep::keccak256::constants;
mod array_utils;

fn main(
    pub_key_x: [u8; 32],
    pub_key_y: [u8; 32],
    signature: [u8; 64], // clip v value
    hashed_message: pub [u8; 32]
) -> pub [u64; 4] {
    let isValid = std::ecdsa_secp256k1::verify_signature(pub_key_x, pub_key_y, signature, hashed_message);
    constrain isValid == 1;

    let pub_key_u64 = array_utils::coordinates_to_u64_array(pub_key_x, pub_key_y);
    std::println(pub_key_u64);
    // pass 512 bits as the input size, as public keys are 512 bits
    let hash_out = keccak256::keccak(pub_key_u64, 512);
    // current hash_out is 0x26509d68e5c6169ca7a4533a0b3123e29d1efdcc38e15c672c30ad0e7fc7450f, which is not expected
    std::println(hash_out);

    // pub_key_u64
    hash_out
}
