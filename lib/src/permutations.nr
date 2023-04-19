use crate::constants;

mod chi;
mod iota;
mod rhoPi;
mod theta;

// This is a simplified implementation of the Keccak256 absorb function where we assume the input is smaller than the
// internal state size.
fn absorb(input: [u64; constants::BLOCK_SIZE]) -> [u64; constants::NUM_LANES] {
  let mut state: [u64; constants::NUM_LANES] = [0; constants::NUM_LANES];

  // We should in theory XOR the input with the internal state. However we know that X ^ 0 = X so we can just write
  // the input into the state. We can do this as the input is guaranteed to be smaller than the state size.
  for i in 0..constants::BLOCK_SIZE {
    state[i] = input[i];
  };

  // TODO: apply keccak-p functions
  state = keccakf(state);

  state
}

fn squeeze(input: [u64; constants::NUM_LANES]) -> [u64; constants::OUTPUT_SIZE] {

  let mut result: [u64; constants::OUTPUT_SIZE] = [0; constants::OUTPUT_SIZE];

  for i in 0..constants::OUTPUT_SIZE {
      result[i] = input[i];
  };
  result
}

fn keccakfRound(state: [u64; constants::NUM_LANES], round_number: comptime Field) -> [u64; constants::NUM_LANES] {

  let state_after_theta = theta::theta(state);
  let state_after_rhoPi = rhoPi::rhoPi(state_after_theta);
  let state_after_chi = chi::chi(state_after_rhoPi);
  let new_state = iota::iota(state_after_chi, round_number);

  new_state
}

fn keccakf(input: [u64; constants::NUM_LANES]) -> [u64; constants::NUM_LANES] {
  let mut state = input;
  for i in 0..constants::NUM_ROUNDS {
    state = keccakfRound(state, i);
  };
  state
}

#[test]
fn test_keccakfRound(){
  let input: [u64; constants::NUM_LANES] = [0; constants::NUM_LANES];

  // Round 0
  let mut after_round_one: [u64; constants::NUM_LANES] = [0; constants::NUM_LANES];
  after_round_one[0] = 0x0000000000000001;
  constrain keccakfRound(input, 0) == after_round_one;
}

#[test]
fn test_keccakf(){
  // Test cases taken from:
  // https://github.com/XKCP/XKCP/blob/64404beeeb261b08a1076fe2f076e4e28dd9b040/tests/TestVectors/KeccakF-1600-IntermediateValues.txt
  let input_state: [u64; constants::NUM_LANES] = [0; constants::NUM_LANES];

  // Permutation 0
  let perm_zero_output: [u64; constants::NUM_LANES] = [
    0xF1258F7940E1DDE7, 0x84D5CCF933C0478A, 0xD598261EA65AA9EE, 0xBD1547306F80494D, 0x8B284E056253D057,
    0xFF97A42D7F8E6FD4, 0x90FEE5A0A44647C4, 0x8C5BDA0CD6192E76, 0xAD30A6F71B19059C, 0x30935AB7D08FFC64,
    0xEB5AA93F2317D635, 0xA9A6E6260D712103, 0x81A57C16DBCF555F, 0x43B831CD0347C826, 0x01F22F1A11A5569F,
    0x05E5635A21D9AE61, 0x64BEFEF28CC970F2, 0x613670957BC46611, 0xB87C5A554FD00ECB, 0x8C3EE88A1CCF32C8,
    0x940C7922AE3A2614, 0x1841F924A2C509E4, 0x16F53526E70465C2, 0x75F644E97F30A13B, 0xEAF1FF7B5CECA249,
  ];
  constrain keccakf(input_state) == perm_zero_output;

  // Permutation 1
  let perm_one_output: [u64; constants::NUM_LANES] = [
    0x2D5C954DF96ECB3C, 0x6A332CD07057B56D, 0x093D8D1270D76B6C, 0x8A20D9B25569D094, 0x4F9C4F99E5E7F156,
    0xF957B9A2DA65FB38, 0x85773DAE1275AF0D, 0xFAF4F247C3D810F7, 0x1F1B9EE6F79A8759, 0xE4FECC0FEE98B425,
    0x68CE61B6B9CE68A1, 0xDEEA66C4BA8F974F, 0x33C43D836EAFB1F5, 0xE00654042719DBD9, 0x7CF8A9F009831265,
    0xFD5449A6BF174743, 0x97DDAD33D8994B40, 0x48EAD5FC5D0BE774, 0xE3B8C8EE55B7B03C, 0x91A0226E649E42E9,
    0x900E3129E7BADD7B, 0x202A9EC5FAA3CCE8, 0x5B3402464E1C3DB6, 0x609F4E62A44C1059, 0x20D06CD26A8FBF5C,
  ];
  constrain keccakf(perm_zero_output) == perm_one_output;
}