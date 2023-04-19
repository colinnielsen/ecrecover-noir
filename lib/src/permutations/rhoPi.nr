use crate::constants;

// This function is a combination of the rho and pi functions as defined in the Keccak256 specification.
// We merge these two functions as rho consists of a rotation of the bits within each lane and pi is a remapping of
// the lane indices. We can then efficiently perform both of these steps simultaneously by writing the output of rho
// directly into the remapped lane specified by pi.
fn rhoPi(state: [u64; constants::NUM_LANES]) -> [u64; constants::NUM_LANES] {
    // These are precomputed pairs of indices within the state array which specify how to perform the pi mapping.
    // Lanes are remapped such that the lane sitting at index READ_LANE_OFFSETS[i] is remapped to WRITE_LANE_OFFSETS[i].
    let READ_LANE_OFFSETS: [comptime Field; 24] = [1, 10, 7, 11, 17, 18, 3, 5, 16, 8, 21, 24, 4, 15, 23, 19, 13, 12, 2, 20, 14, 22, 9, 6];
    let WRITE_LANE_OFFSETS: [comptime Field; 24] = [10, 7, 11, 17, 18, 3, 5, 16, 8, 21, 24, 4, 15, 23, 19, 13, 12, 2, 20, 14, 22, 9, 6, 1];

    // This array defines the rho mapping to be applied to each lane.
    // Each lane is rotated by the specified number of bits, mapping the z coordinate as `z -> (z - T[i]) % LANE_LENGTH`
    // This array is defined as `T[i] = ((i+1)(i+2) / 2) % LANE_LENGTH`
    // This definition adds an additional modulo compared to the spec but makes it easier to calculate correct offsets.
    let T: [comptime u64; 24] = [1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 2, 14, 27, 41, 56, 8, 25, 43, 62, 18, 39, 61, 20, 44];

    let mut new_state: [u64; constants::NUM_LANES] = [0; constants::NUM_LANES];

    // The center lane is unaffected by the rho and pi functions so we write it directly into the new state.
    new_state[0] = state[0];

    // Now for the remaining lanes we write the rotated lane outputted from rho into the remapped lane specified by pi.
    for i in 0..constants::NUM_LANES - 1 {
        new_state[WRITE_LANE_OFFSETS[i]] = rotl64(state[READ_LANE_OFFSETS[i]], T[i]);
    };

    new_state
}

fn rotl64(num: u64, rot: comptime u64) -> u64 {
  (num << rot) + (num >> (64 - rot))
}


#[test]
fn test_rhoPi(){
  // Test cases taken from:
  // https://github.com/XKCP/XKCP/blob/64404beeeb261b08a1076fe2f076e4e28dd9b040/tests/TestVectors/KeccakF-1600-IntermediateValues.txt
  
  // Round 0
  let round_zero_input: [u64; constants::NUM_LANES] = [0; constants::NUM_LANES];
  constrain rhoPi(round_zero_input) == round_zero_input;

  // Round 1
  let round_one_input = [
    0x0000000000000001,0x0000000000000001,0x0000000000000000,0x0000000000000000,0x0000000000000002,
    0x0000000000000000,0x0000000000000001,0x0000000000000000,0x0000000000000000,0x0000000000000002,
    0x0000000000000000,0x0000000000000001,0x0000000000000000,0x0000000000000000,0x0000000000000002,
    0x0000000000000000,0x0000000000000001,0x0000000000000000,0x0000000000000000,0x0000000000000002,
    0x0000000000000000,0x0000000000000001,0x0000000000000000,0x0000000000000000,0x0000000000000002
  ];
  let round_one_output = [
    0x0000000000000001, 0x0000100000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000008000,
    0x0000000000000000, 0x0000000000200000, 0x0000000000000000, 0x0000200000000000, 0x0000000000000000,
    0x0000000000000002, 0x0000000000000000, 0x0000000000000000, 0x0000000000000200, 0x0000000000000000,
    0x0000000010000000, 0x0000000000000000, 0x0000000000000400, 0x0000000000000000, 0x0000000000000000,
    0x0000000000000000, 0x0000000000000000, 0x0000010000000000, 0x0000000000000000, 0x0000000000000004,
  ];
  constrain rhoPi(round_one_input) == round_one_output;

  // Round 2
  let round_two_input: [u64; constants::NUM_LANES] = [
    0x0000700000600487, 0x0000130010018C89, 0x0000700020208606, 0x000021000041840D, 0x0000320030018B01,
    0x0000700000608404, 0x0000230010218C89, 0x0000700020200606, 0x000001000041840C, 0x0000220030210B01,
    0x0000700000608406, 0x0000030010018E89, 0x0000700020200606, 0x000021000041860E, 0x0000220030010B01,
    0x0000700010608004, 0x0000030010018C89, 0x0000700020200206, 0x000021001041840C, 0x0000220030010B01,
    0x0000710000608404, 0x0000030010018C89, 0x0000710020200602, 0x000021000041840C, 0x0000220030010B05,
  ];
  let round_two_output = [
    0x0000700000600487, 0x18C8900002300102, 0x0030300003800101, 0x2002083081800004, 0x08800C0042C14000,
    0x00041840D0000210, 0x20030210B0100002, 0x0003800003042030, 0x3191200000600200, 0x40000E20040400C0,
    0x0000260020031912, 0x001C000808018180, 0x0000830C1C000042, 0x00220030010B0100, 0xC400018210100001,
    0x01800C5808000190, 0x0608404000070000, 0x000C0040063A2400, 0x3800101001030000, 0x0C00002100004184,
    0x80001C0008082181, 0x06000000800020C2, 0x0085808000110018, 0xC100080000E00020, 0x00000C0040063224,
  ];
  constrain rhoPi(round_two_input) == round_two_output;
}