use dep::std;

mod helpers;

struct PubKey {
    pub_x: [u8; 32],
    pub_y: [u8; 32],
}

unconstrained
fn split_uncompressed_pub_key(
    pub_key: [u8; 65]
) -> ([u8; 32], [u8; 32]) {
    let mut pub_key_x: [u8; 32] = [0; 32];
    let mut pub_key_y: [u8; 32] = [0; 32];

    for i in 0..32 {
        pub_key_x[i] = pub_key[i + 1];
        pub_key_y[i] = pub_key[i + 32 + 1];
    };

    (pub_key_x, pub_key_y)
}

impl PubKey {
    fn from_xy(pub_x: [u8; 32], pub_y: [u8; 32]) -> PubKey {
        PubKey {
            pub_x,
            pub_y,
        }
    }

    fn from_unified(pub_key: [u8; 64]) -> PubKey {
        let (key_x, key_y) = helpers::split_u8_64_unconstrained(pub_key);

        PubKey {
            pub_x: key_x,
            pub_y: key_y,
        }
    }

    fn from_uncompressed(pub_key: [u8; 65]) -> PubKey {
        let (key_x, key_y) = split_uncompressed_pub_key(pub_key);

        PubKey {
            pub_x: key_x,
            pub_y: key_y,
        }
    }

    fn verify_sig(self, signature: [u8; 64], hashed_message: [u8; 32]) -> bool {
        let isValid = std::ecdsa_secp256k1::verify_signature(self.pub_x, self.pub_y, signature, hashed_message);
        isValid == 1
    }

    fn to_eth_address(self) -> Field {
        let pub_key = helpers::u8_32_to_u8_64_unconstrained(self.pub_x, self.pub_y);
        let hashed_pub_key = std::hash::keccak256(pub_key);

        let mut right_20_bytes: [u8; 20] = [0; 20];
        for i in 0..20 {
            right_20_bytes[i] = hashed_pub_key[i + 12];
        }

        helpers::u8_to_eth_address(right_20_bytes)
    }
}
