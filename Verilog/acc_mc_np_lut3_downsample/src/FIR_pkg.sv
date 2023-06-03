

package FIR_pkg;

  typedef enum logic [2:0] {
    OP_SHIFT_H          = 3'b000,
    OP_SHIFT_S          = 3'b001,
    OP_CALCULATE_O      = 3'b010, 
    OP_NOP              = 3'b011,
    OP_NUM_SHIFT        = 3'b100,
    OP_N_CHANGE         = 3'b101,
    OP_K_CHANGE         = 3'b110
  } opcode_e;

  typedef enum logic [5:0] {
    AS0_000 = 6'b000000,
    AS1_000 = 6'b000001,
    AS2_000 = 6'b000010,
    AS3_000 = 6'b000011,
    AS4_000 = 6'b000100,
    AS5_000 = 6'b000101,
    AS6_000 = 6'b000110,
    AS7_000 = 6'b000111,

    AS0_001 = 6'b001000,
    AS1_001 = 6'b001001,
    AS2_001 = 6'b001010,
    AS3_001 = 6'b001011,
    AS4_001 = 6'b001100,
    AS5_001 = 6'b001101,
    AS6_001 = 6'b001110,
    AS7_001 = 6'b001111,

    AS0_010 = 6'b010000,
    AS1_010 = 6'b010001,
    AS2_010 = 6'b010010,
    AS3_010 = 6'b010011,
    AS4_010 = 6'b010100,
    AS5_010 = 6'b010101,
    AS6_010 = 6'b010110,
    AS7_010 = 6'b010111,

    AS0_011 = 6'b011000,
    AS1_011 = 6'b011001,
    AS2_011 = 6'b011010,
    AS3_011 = 6'b011011,
    AS4_011 = 6'b011100,
    AS5_011 = 6'b011101,
    AS6_011 = 6'b011110,
    AS7_011 = 6'b011111,

    AS0_100 = 6'b100000,
    AS1_100 = 6'b100001,
    AS2_100 = 6'b100010,
    AS3_100 = 6'b100011,
    AS4_100 = 6'b100100,
    AS5_100 = 6'b100101,
    AS6_100 = 6'b100110,
    AS7_100 = 6'b100111,

    AS0_101 = 6'b101000,
    AS1_101 = 6'b101001,
    AS2_101 = 6'b101010,
    AS3_101 = 6'b101011,
    AS4_101 = 6'b101100,
    AS5_101 = 6'b101101,
    AS6_101 = 6'b101110,
    AS7_101 = 6'b101111,

    AS0_110 = 6'b110000,
    AS1_110 = 6'b110001,
    AS2_110 = 6'b110010,
    AS3_110 = 6'b110011,
    AS4_110 = 6'b110100,
    AS5_110 = 6'b110101,
    AS6_110 = 6'b110110,
    AS7_110 = 6'b110111,

    AS0_111 = 6'b111000,
    AS1_111 = 6'b111001,
    AS2_111 = 6'b111010,
    AS3_111 = 6'b111011,
    AS4_111 = 6'b111100,
    AS5_111 = 6'b111101,
    AS6_111 = 6'b111110,
    AS7_111 = 6'b111111
  } shift_h_addr_e;


  typedef enum logic {
      IDLE      = 1'b0,
      CALCULATE = 1'b1
  } state_e;
 
  typedef enum logic {
    MCA_IDLE,
    MCA_ADDING
  } state_mca_e;

  typedef enum logic [1:0] {
    PARAM_S_SHIFT = 2'b00,
    PARAM_N_CHANGE = 2'b01,
    PARAM_K_CHANGE = 2'b10
  } param_change_e;
 



endpackage