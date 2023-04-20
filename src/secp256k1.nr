use dep::std;
use dep::keccak256;
use dep::keccak256::constants;

mod helpers;

struct PubKey {
    pub_x: [u8; 32],
    pub_y: [u8; 32],
}

impl PubKey {
    fn new(pub_x: [u8; 32], pub_y: [u8; 32]) -> PubKey {
        PubKey {
            pub_x,
            pub_y,
        }
    }

    fn verify_sig(self, signature: [u8; 64], hashed_message: [u8; 32]) -> bool {
        let isValid = std::ecdsa_secp256k1::verify_signature(self.pub_x, self.pub_y, signature, hashed_message);
        isValid == 1
    }

    fn to_eth_address(self) -> Field {
        let pub_key = helpers::coordinates_to_u64_array(self.pub_x, self.pub_y);
        // pass 512 bits as the input size, as public keys are 512 bits
        let hashed_pub_key = keccak256::keccak(pub_key, 512);
        // TODO (4/20/23):
        //  given: 0x8318535b54105d4a7aae60c08fc45f9687181b4fdfc625bd1a753fa7397fed753547f11ca8696646f2f3acb08e31016afac23e630c5d11f59f61fef57b0d2aa5
        //  current hash_out is: 0x26509d68e5c6169ca7a4533a0b3123e29d1efdcc38e15c672c30ad0e7fc7450f
        //  
        //  This is not correct and I am waiting for noir-keccak to be completed
        let hashed_pub_key_u8 = helpers::u64_4_to_u8_32(hashed_pub_key);
        let addr = helpers::u8_32_to_u160(hashed_pub_key_u8);

        addr
    }
}
