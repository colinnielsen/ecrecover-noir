// Input size related

// The input must be at least 2 bits smaller than the block size to accommodate the padding bits.
global INPUT_SIZE: Field = 16;
// Blocks are 136 bytes. 138 * 8 = 1088 bits.
global BLOCK_SIZE: Field = 17;

global OUTPUT_SIZE: Field = 4;

// State size related
global LANE_LENGTH: Field = 64;
global COLUMN_LENGTH: Field = 5;
global NUM_LANES: Field = 25;

// Misc
global NUM_ROUNDS: Field = 24;
