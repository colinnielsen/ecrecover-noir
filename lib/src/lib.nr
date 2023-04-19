mod constants;
mod padding;
mod permutations;

fn keccak(input: [u64; constants::INPUT_SIZE], input_length: u64) -> [u64; constants::OUTPUT_SIZE] {
  let padded_input: [u64; constants::BLOCK_SIZE] = padding::pad(input, input_length);

  let final_state: [u64; constants::NUM_LANES] = permutations::absorb(padded_input);

  let output = permutations::squeeze(final_state);

  output
}
