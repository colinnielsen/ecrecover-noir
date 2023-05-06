use dep::std;

mod helpers;

struct PubKey {
    pub_x: [u8; 32],
    pub_y: [u8; 32],
}

impl PubKey {
    fn from_xy(pub_x: [u8; 32], pub_y: [u8; 32]) -> PubKey {
        PubKey {
            pub_x,
            pub_y,
        }
    }

    fn from_unified(pub_key: [u8; 64]) -> PubKey {
        let keys = helpers::split_pub_key(pub_key);

        PubKey {
            pub_x: keys[0],
            pub_y: keys[1],
        }
    }

    fn from_uncompressed(pub_key: [u8; 65]) -> PubKey {
        let keys = helpers::split_uncompressed_pub_key(pub_key);

        PubKey {
            pub_x: keys[0],
            pub_y: keys[1],
        }
    }

    fn verify_sig(self, signature: [u8; 64], hashed_message: [u8; 32]) -> bool {
        let isValid = std::ecdsa_secp256k1::verify_signature(self.pub_x, self.pub_y, signature, hashed_message);
        isValid == 1
    }

    fn to_eth_address(self) -> Field {
        let pub_key = helpers::unify_pub_x_pub_y(self.pub_x, self.pub_y);
        let hashed_pub_key = std::hash::sha256(pub_key);

        helpers::u8_32_to_u160(hashed_pub_key)
    }
}
