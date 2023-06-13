use dep::std;

fn u8_32s_to_u64_16(
    arr_a: [u8; 32],
    arr_b: [u8; 32],
) -> [u64; 16] {
    let mut combined_u64: [u64; 16] = [0; 16];
    
    for i in 0..4 {
        let mut value: u64 = 0;
        for j in 0..8 {
            value |= (arr_a[i*8+j] as u64) << ((56 - j*8) as u64);
        }
         combined_u64[i] = value;
    }
    for i in 4..8 {
        let mut value: u64 = 0;
        for j in 0..8 {
            value |= (arr_b[(i-4)*8+j] as u64) << ((56 - j*8) as u64);
        }
         combined_u64[i] = value;
    }

    combined_u64
}

unconstrained
fn u8_32s_to_u64_16_unconstrained(
    arr_a: [u8; 32],
    arr_b: [u8; 32],
) -> [u64; 16] {
    let mut combined_u64: [u64; 16] = [0; 16];
    
    for i in 0..4 {
        let mut value: u64 = 0;
        for j in 0..8 {
            value |= (arr_a[i*8+j] as u64) << ((56 - j*8) as u64);
        }
         combined_u64[i] = value;
    }
    for i in 4..8 {
        let mut value: u64 = 0;
        for j in 0..8 {
            value |= (arr_b[(i-4)*8+j] as u64) << ((56 - j*8) as u64);
        }
         combined_u64[i] = value;
    }

    combined_u64
}

#[test]
fn test_u8_32s_to_u64_16() {
    let arr_a: [u8; 32] = [
        131,24,83,91,84,16,93,74,122,174,96,192,143,196,95,150,135,24,27,79,223,198,37,189,26,117,63,167,57,127,237,117
    ];
    let arr_b: [u8; 32] = [
        53,71,241,28,168,105,102,70,242,243,172,176,142,49,1,106,250,194,62,99,12,93,17,245,159,97,254,245,123,13,42,165
    ];
    let out = u8_32s_to_u64_16(arr_a, arr_b);

    assert(out[0] == 9446391870127103306);
    assert(out[1] == 8840109498736861078);
    assert(out[2] == 9734560624431998397);
    assert(out[3] == 1906500004718046581);
    assert(out[4] == 3839302312743495238);
    assert(out[5] == 17506526050819047786);
    assert(out[6] == 18069073250093961717);
    assert(out[7] == 11484740855056378533);
    assert(out[8] == 0);
    assert(out[9] == 0);
    assert(out[10] == 0);
    assert(out[11] == 0);
    assert(out[12] == 0);
    assert(out[13] == 0);
    assert(out[14] == 0);
    assert(out[15] == 0);
    // the above output is the hex "0x8318535b54105d4a7aae60c08fc45f9687181b4fdfc625bd1a753fa7397fed753547f11ca8696646f2f3acb08e31016afac23e630c5d11f59f61fef57b0d2aa5"
}

fn u8_32_to_u8_64(
    arr_a: [u8; 32],
    arr_b: [u8; 32],
) -> [u8; 64] {
    let mut combined: [u8; 64] = [0; 64];

    for i in 0..32 {
        combined[i] = arr_a[i];
    }
    for i in 0..32 {
        combined[i + 32] = arr_b[i];
    }

    combined
}

unconstrained
fn u8_32_to_u8_64_unconstrained(
    arr_a: [u8; 32],
    arr_b: [u8; 32],
) -> [u8; 64] {
    let mut combined: [u8; 64] = [0; 64];

    for i in 0..32 {
        combined[i] = arr_a[i];
    }
    for i in 0..32 {
        combined[i + 32] = arr_b[i];
    }

    combined
}


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

unconstrained
fn u64_4_to_u8_32_unconstrained(
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

    assert(arr_out[0] == 13);
    assert(arr_out[1] == 223);
    assert(arr_out[2] == 118);
    assert(arr_out[3] == 95);
    assert(arr_out[4] == 221);
    assert(arr_out[5] == 248);
    assert(arr_out[6] == 93);
    assert(arr_out[7] == 74);
    assert(arr_out[8] == 122);
    assert(arr_out[9] == 174);
    assert(arr_out[10] == 96);
    assert(arr_out[11] == 192);
    assert(arr_out[12] == 143);
    assert(arr_out[13] == 196);
    assert(arr_out[14] == 95);
    assert(arr_out[15] == 150);
    assert(arr_out[16] == 135);
    assert(arr_out[17] == 24);
    assert(arr_out[18] == 27);
    assert(arr_out[19] == 79);
    assert(arr_out[20] == 223);
    assert(arr_out[21] == 198);
    assert(arr_out[22] == 37);
    assert(arr_out[23] == 189);
    assert(arr_out[24] == 26);
    assert(arr_out[25] == 117);
    assert(arr_out[26] == 63);
    assert(arr_out[27] == 167);
    assert(arr_out[28] == 57);
    assert(arr_out[29] == 127);
    assert(arr_out[30] == 237);
    assert(arr_out[31] == 117);
}

/// @dev this method is used to convert a u8 array to a u160 (which is not supported by Noir, so it's represented as a Field)
/// @dev will throw on Field overflow
fn u8_to_u160(
    array: [u8]
) -> Field {
    let mut addr: Field = 0;

    for i in 0..20 {
        // only take the last 20 bytes of the hash
        addr = (addr * 256) + (array[i] as Field);
    }

    addr
}

unconstrained
fn u8_to_u160_unconstrained(
    array: [u8]
) -> Field {
    let mut addr: Field = 0;

    for i in 0..20 {
        // only take the last 20 bytes of the hash
        addr = (addr * 256) + (array[i] as Field);
    }

    addr
}

fn u8_to_eth_address(
    array: [u8]
) -> Field {
    u8_to_u160(array)
}

unconstrained
fn u8_to_eth_address_unconstrained(
    array: [u8]
) -> Field {
    u8_to_u160(array)
}

#[test]
fn test_u8_32_to_u160() {
    // keccak hash of hardhat 0 address pub key (0xc1ffd3cfee2d9e5cd67643f8f39fd6e51aad88f6f4ce6ab8827279cfffb92266) as u8 array
    let hashed_pub_key = [
        193,255,211,207,238,45,158,92,214,118,67,248,243,159,214,229,26,173,136,246,244,206,106,184,130,114,121,207,255,185,34,102
    ];

    let mut right_20_bytes: [u8; 20] = [0; 20];
    for i in 0..20 {
        right_20_bytes[i] = hashed_pub_key[i + 12];
    }

    let addr = u8_to_u160(right_20_bytes);
    let addr_aliased = u8_to_eth_address(right_20_bytes);

    assert(addr == addr_aliased);
    assert(addr == 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266); // hardhat address 0
}

fn split_u8_64(
    arr: [u8; 64]
) -> ([u8; 32], [u8; 32]) {
    let mut arr_a: [u8; 32] = [0; 32];
    let mut arr_b: [u8; 32] = [0; 32];

    for i in 0..32 {
        arr_a[i] = arr[i];
        arr_b[i] = arr[i + 32];
    };

    (arr_a, arr_b)
}

unconstrained
fn split_u8_64_unconstrained(
    arr: [u8; 64]
) -> ([u8; 32], [u8; 32]) {
    let mut arr_a: [u8; 32] = [0; 32];
    let mut arr_b: [u8; 32] = [0; 32];

    for i in 0..32 {
        arr_a[i] = arr[i];
        arr_b[i] = arr[i + 32];
    };

    (arr_a, arr_b)
}

#[test]
fn test_split_u8_64() {
    let u8_64 = [
        193,255,211,207,238,45,158,92,214,118,67,248,243,159,214,229,26,173,136,246,244,206,106,184,130,114,121,207,255,185,34,102,
        193,255,211,207,238,45,158,92,214,118,67,248,243,159,214,229,26,173,136,246,244,206,106,184,130,114,121,207,255,185,34,102
    ];

    let (arr_a, arr_b) = split_u8_64(u8_64);

    for i in 0..32 {
        assert(arr_a[i] == u8_64[i]);
        assert(arr_b[i] == u8_64[i + 32]);
    }
}
