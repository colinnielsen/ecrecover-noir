use dep::std;

unconstrained
fn coordinates_to_u64_array(
    array_x: [u8; 32],
    array_y: [u8; 32],
) -> [u64; 16] {
    let mut combined_u64: [u64; 16] = [0; 16];
    
    for i in 0..4 {
        let mut value: u64 = 0;
        for j in 0..8 {
            value |= (array_x[i*8+j] as u64) << ((56 - j*8) as u64);
        }
         combined_u64[i] = value;
    }
    for i in 4..8 {
        let mut value: u64 = 0;
        for j in 0..8 {
            value |= (array_y[(i-4)*8+j] as u64) << ((56 - j*8) as u64);
        }
         combined_u64[i] = value;
    }

    combined_u64
}

#[test]
fn test_coordinates_to_u64_array() {
    let pub_key_x: [u8; 32] = [
        131,24,83,91,84,16,93,74,122,174,96,192,143,196,95,150,135,24,27,79,223,198,37,189,26,117,63,167,57,127,237,117
    ];
    let pub_key_y: [u8; 32] = [
        53,71,241,28,168,105,102,70,242,243,172,176,142,49,1,106,250,194,62,99,12,93,17,245,159,97,254,245,123,13,42,165
    ];
    let pub_key = coordinates_to_u64_array(pub_key_x, pub_key_y);

    constrain pub_key[0] == 9446391870127103306;
    constrain pub_key[1] == 8840109498736861078;
    constrain pub_key[2] == 9734560624431998397;
    constrain pub_key[3] == 1906500004718046581;
    constrain pub_key[4] == 3839302312743495238;
    constrain pub_key[5] == 17506526050819047786;
    constrain pub_key[6] == 18069073250093961717;
    constrain pub_key[7] == 11484740855056378533;
    constrain pub_key[8] == 0;
    constrain pub_key[9] == 0;
    constrain pub_key[10] == 0;
    constrain pub_key[11] == 0;
    constrain pub_key[12] == 0;
    constrain pub_key[13] == 0;
    constrain pub_key[14] == 0;
    constrain pub_key[15] == 0;
    // the above output is the hex "0x8318535b54105d4a7aae60c08fc45f9687181b4fdfc625bd1a753fa7397fed753547f11ca8696646f2f3acb08e31016afac23e630c5d11f59f61fef57b0d2aa5"
    // which is the correct public key for the x + y coordinate
}

unconstrained
fn unify_pub_x_pub_y(
    array_x: [u8; 32],
    array_y: [u8; 32],
) -> [u8; 64] {
    let mut combined: [u8; 64] = [0; 64];

    for i in 0..32 {
        combined[i] = array_x[i];
    }
    for i in 0..32 {
        combined[i + 32] = array_y[i];
    }

    combined
}

unconstrained
fn u64_4_to_u8_32(
    array: [u64; 4]
) -> [u8; 32] {
    let mut output: [u8; 32] = [0; 32];
    let mut output_index = 0;

    for num_idx in 0..4 {
        for bit_pos in 0..8 {
            let shift_amount: u64 = 56 - (bit_pos * 8) as u64;
            output[output_index] = ((array[num_idx] >> shift_amount) & 255) as u8;
            output_index += 1;
        }
    }

    output
}

#[test]
fn test_u64_4_to_u8_32() {
    let hash: [u64; 4] = [
        19446391870127103306,
        8840109498736861078,
        9734560624431998397,
        1906500004718046581
    ];
 
    let arr_out = u64_4_to_u8_32(hash);

    constrain arr_out[0] == 13;
    constrain arr_out[1] == 223;
    constrain arr_out[2] == 118;
    constrain arr_out[3] == 95;
    constrain arr_out[4] == 221;
    constrain arr_out[5] == 248;
    constrain arr_out[6] == 93;
    constrain arr_out[7] == 74;
    constrain arr_out[8] == 122;
    constrain arr_out[9] == 174;
    constrain arr_out[10] == 96;
    constrain arr_out[11] == 192;
    constrain arr_out[12] == 143;
    constrain arr_out[13] == 196;
    constrain arr_out[14] == 95;
    constrain arr_out[15] == 150;
    constrain arr_out[16] == 135;
    constrain arr_out[17] == 24;
    constrain arr_out[18] == 27;
    constrain arr_out[19] == 79;
    constrain arr_out[20] == 223;
    constrain arr_out[21] == 198;
    constrain arr_out[22] == 37;
    constrain arr_out[23] == 189;
    constrain arr_out[24] == 26;
    constrain arr_out[25] == 117;
    constrain arr_out[26] == 63;
    constrain arr_out[27] == 167;
    constrain arr_out[28] == 57;
    constrain arr_out[29] == 127;
    constrain arr_out[30] == 237;
    constrain arr_out[31] == 117;
}

fn u8_32_to_u160(
    array: [u8; 32]
) -> Field {
    let mut addr: Field = 0;

    for i in 0..20 {
        // only take the last 20 bytes of the hash
        addr = (addr * 256) + (array[i + 12] as Field);
    }

    addr
}

#[test]
fn test_u8_32_to_u160() {
    // keccak hash of hardhat 0 address pub key (0xc1ffd3cfee2d9e5cd67643f8f39fd6e51aad88f6f4ce6ab8827279cfffb92266) as u8 array
    let hashed_pub_key = [
        193,255,211,207,238,45,158,92,214,118,67,248,243,159,214,229,26,173,136,246,244,206,106,184,130,114,121,207,255,185,34,102
    ];
    let addr = u8_32_to_u160(hashed_pub_key);

    constrain addr == 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266; // hardhat address 0
}

unconstrained
fn split_pub_key(
    pub_key: [u8; 64]
) -> [[u8; 32]; 2] {
    let mut pub_key_x: [u8; 32] = [0; 32];
    let mut pub_key_y: [u8; 32] = [0; 32];

    for i in 0..32 {
        pub_key_x[i] = pub_key[i];
        pub_key_y[i] = pub_key[i + 32];
    }

    [pub_key_x, pub_key_y]
}

unconstrained
fn split_uncompressed_pub_key(
    pub_key: [u8; 65]
) -> [[u8; 32]; 2] {
    let mut pub_key_x: [u8; 32] = [0; 32];
    let mut pub_key_y: [u8; 32] = [0; 32];

    for i in 0..32 {
        pub_key_x[i] = pub_key[i + 1];
        pub_key_y[i] = pub_key[i + 32 + 1];
    }

    [pub_key_x, pub_key_y]
}


//
//// playground
//


// #[test]
// fn test_keccak256() {
//     let mut arr: [u64; 16] = [0; 16];
//     arr[0] = 1;

//     let out = keccak256::keccak(arr, 1);
//     constrain out[0] == 0;
// }

// fn u64_4_to_ethereum_addr(
//     array: [u64; 4]
// ) -> Field {
//     let mut addr = 0;
//     let u32_representation = u64_4_to_u8_32(array);

//     for i in 0..20 {
//         let reverse_i = 32 - i;

//     }
// }

// fn u64_4_to_ethereum_addr(
//     array: [u64; 4]
// ) -> Field {
//     let u8_32 = u64_4_to_u8_32(array);
//     let right_most = right_20_bytes(u8_32);

//     let mut addr: Field = 0;
//     for i in 0..20 {
//         addr = (addr * 256) + right_most[i] as Field;
//     }

//     addr
// }

// #[test]
// fn test_right_20_bytes(
//     array: [u8; 32]
// ) -> [u8; 20] {
//     let mut output = [0; 20];

//     for i in 0..20 {
//         output[i] = array[i + 12];
//     }

//     output
// }

// fn split_pub_key_to_u64_array(
//     prefix: u8,
//     array_x: [u8; 32],
//     array_y: [u8; 32],
// ) -> [u64; 16] {
//     let mut combined_u64: [u64; 16] = [0; 16];
    
//     combined_u64[0] = (prefix as u64) << 56;
//     for i in 0..4 {
//         let mut value: u64 = 0;
//         for j in 0..8 {
//             value |= (array_x[i * 8 + j] as u64) << ((56 - j * 8) as u64);
//         }
//         combined_u64[i] |= value >> (8 * (i + 1) as u64);
//         if i < 3 {
//             combined_u64[i + 1] = value << (8 * (7 - i) as u64);
//         }
//     }

//     for i in 4..8 {
//         let mut value: u64 = 0;
//         for j in 0..8 {
//             value |= (array_y[(i - 4) * 8 + j] as u64) << ((56 - j * 8) as u64);
//         }
//         combined_u64[i] = value;
//     }

//     combined_u64
// }