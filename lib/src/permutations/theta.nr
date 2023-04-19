use crate::constants;

fn theta(state: [u64; constants::NUM_LANES]) -> [u64; constants::NUM_LANES] {
    // The theta function works by calculating the parity of each of the columns in the state array. We store these
    // in the C[x, z] arrays.
    // C[x, z] = A[x, 0, z] ^ A[x, 1, z] ^ A[x, 2, z] ^ A[x, 3, z] ^ A[x, 4, z]
    let c0: u64 = state[0] ^ state[5] ^ state[10] ^ state[15] ^ state[20];
    let c1: u64 = state[1] ^ state[6] ^ state[11] ^ state[16] ^ state[21];
    let c2: u64 = state[2] ^ state[7] ^ state[12] ^ state[17] ^ state[22];
    let c3: u64 = state[3] ^ state[8] ^ state[13] ^ state[18] ^ state[23];
    let c4: u64 = state[4] ^ state[9] ^ state[14] ^ state[19] ^ state[24];

    // D[x, z] = C[(x - 1) mod 5, z] ^ C[(x + 1) mod 5, (z - 1) mod LANE_LENGTH]
    let d0: u64 = c4 ^ rotl64(c1, 1);
    let d1: u64 = c0 ^ rotl64(c2, 1);
    let d2: u64 = c1 ^ rotl64(c3, 1);
    let d3: u64 = c2 ^ rotl64(c4, 1);
    let d4: u64 = c3 ^ rotl64(c0, 1);

    // The labelling convention for the state array is `lane(x, y) = state[5y + x]`.
    let mut new_state = [0; constants::NUM_LANES];
    for y in 0..constants::COLUMN_LENGTH {
        new_state[5 * y + 0] = state[5 * y + 0] ^ d0;
        new_state[5 * y + 1] = state[5 * y + 1] ^ d1;
        new_state[5 * y + 2] = state[5 * y + 2] ^ d2;
        new_state[5 * y + 3] = state[5 * y + 3] ^ d3;
        new_state[5 * y + 4] = state[5 * y + 4] ^ d4;
    };

    new_state
}

fn rotl64(num: u64, rot: comptime u64) -> u64 {
  (num << rot) + (num >> (64 - rot))
}

#[test]
fn test_rotl64() {
  constrain rotl64(0x0000000000000001, 1) == 0x0000000000000002;
  constrain rotl64(0x8000000000000001, 1) == 0x0000000000000003;
  constrain rotl64(0xf000012300000001, 1) == 0xe000024600000003;
  constrain rotl64(0xf000012300000001, 64) == 0xf000012300000001;
}

#[test]
fn test_theta(){
  // Test cases taken from:
  // https://github.com/XKCP/XKCP/blob/64404beeeb261b08a1076fe2f076e4e28dd9b040/tests/TestVectors/KeccakF-1600-IntermediateValues.txt
  
  // Round 0
  let round_zero_input: [u64; constants::NUM_LANES] = [0; constants::NUM_LANES];
  constrain theta(round_zero_input) == round_zero_input;

  // Round 1
  let mut round_one_input: [u64; constants::NUM_LANES] = [0; constants::NUM_LANES];
  round_one_input[0] = 0x0000000000000001;
  let round_one_output = [
    0x0000000000000001,0x0000000000000001,0x0000000000000000,0x0000000000000000,0x0000000000000002,
    0x0000000000000000,0x0000000000000001,0x0000000000000000,0x0000000000000000,0x0000000000000002,
    0x0000000000000000,0x0000000000000001,0x0000000000000000,0x0000000000000000,0x0000000000000002,
    0x0000000000000000,0x0000000000000001,0x0000000000000000,0x0000000000000000,0x0000000000000002,
    0x0000000000000000,0x0000000000000001,0x0000000000000000,0x0000000000000000,0x0000000000000002
  ];
  constrain theta(round_one_input) == round_one_output;

  // Round 2
  let round_two_input: [u64; constants::NUM_LANES] = [
    0x0000000000008083, 0x0000100000000000, 0x0000000000008000, 0x0000000000000001, 0x0000100000008000,
    0x0000000000000000, 0x0000200000200000, 0x0000000000000000, 0x0000200000000000, 0x0000000000200000,
    0x0000000000000002, 0x0000000000000200, 0x0000000000000000, 0x0000000000000202, 0x0000000000000000,
    0x0000000010000400, 0x0000000000000000, 0x0000000000000400, 0x0000000010000000, 0x0000000000000000,
    0x0000010000000000, 0x0000000000000000, 0x0000010000000004, 0x0000000000000000, 0x0000000000000004,
  ];
  let round_two_output = [
    0x0000700000600487, 0x0000130010018C89, 0x0000700020208606, 0x000021000041840D, 0x0000320030018B01,
    0x0000700000608404, 0x0000230010218C89, 0x0000700020200606, 0x000001000041840C, 0x0000220030210B01,
    0x0000700000608406, 0x0000030010018E89, 0x0000700020200606, 0x000021000041860E, 0x0000220030010B01,
    0x0000700010608004, 0x0000030010018C89, 0x0000700020200206, 0x000021001041840C, 0x0000220030010B01,
    0x0000710000608404, 0x0000030010018C89, 0x0000710020200602, 0x000021000041840C, 0x0000220030010B05,
  ];
  constrain theta(round_two_input) == round_two_output;
}