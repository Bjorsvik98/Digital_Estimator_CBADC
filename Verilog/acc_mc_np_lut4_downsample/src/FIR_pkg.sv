

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

  typedef enum logic [6:0] {
    AS0_0000 = 7'b00000,
    AS1_0000 = 7'b00001,
    AS2_0000 = 7'b00010,
    AS3_0000 = 7'b00011,
    AS4_0000 = 7'b00100,
    AS5_0000 = 7'b00101,
    AS6_0000 = 7'b00110,
    AS7_0000 = 7'b00111,

    AS0_0001 = 7'b0001000,
    AS1_0001 = 7'b0001001,
    AS2_0001 = 7'b0001010,
    AS3_0001 = 7'b0001011,
    AS4_0001 = 7'b0001100,
    AS5_0001 = 7'b0001101,
    AS6_0001 = 7'b0001110,
    AS7_0001 = 7'b0001111,

    AS0_0010 = 7'b0010000,
    AS1_0010 = 7'b0010001,
    AS2_0010 = 7'b0010010,
    AS3_0010 = 7'b0010011,
    AS4_0010 = 7'b0010100,
    AS5_0010 = 7'b0010101,
    AS6_0010 = 7'b0010110,
    AS7_0010 = 7'b0010111,

    AS0_0011 = 7'b0011000,
    AS1_0011 = 7'b0011001,
    AS2_0011 = 7'b0011010,
    AS3_0011 = 7'b0011011,
    AS4_0011 = 7'b0011100,
    AS5_0011 = 7'b0011101,
    AS6_0011 = 7'b0011110,
    AS7_0011 = 7'b0011111,

    AS0_0100 = 7'b0100000,
    AS1_0100 = 7'b0100001,
    AS2_0100 = 7'b0100010,
    AS3_0100 = 7'b0100011,
    AS4_0100 = 7'b0100100,
    AS5_0100 = 7'b0100101,
    AS6_0100 = 7'b0100110,
    AS7_0100 = 7'b0100111,

    AS0_0101 = 7'b0101000,
    AS1_0101 = 7'b0101001,
    AS2_0101 = 7'b0101010,
    AS3_0101 = 7'b0101011,
    AS4_0101 = 7'b0101100,
    AS5_0101 = 7'b0101101,
    AS6_0101 = 7'b0101110,
    AS7_0101 = 7'b0101111,

    AS0_0110 = 7'b0110000,
    AS1_0110 = 7'b0110001,
    AS2_0110 = 7'b0110010,
    AS3_0110 = 7'b0110011,
    AS4_0110 = 7'b0110100,
    AS5_0110 = 7'b0110101,
    AS6_0110 = 7'b0110110,
    AS7_0110 = 7'b0110111,

    AS0_0111 = 7'b0111000,
    AS1_0111 = 7'b0111001,
    AS2_0111 = 7'b0111010,
    AS3_0111 = 7'b0111011,
    AS4_0111 = 7'b0111100,
    AS5_0111 = 7'b0111101,
    AS6_0111 = 7'b0111110,
    AS7_0111 = 7'b0111111,

    AS0_1000 = 7'b1000000,
    AS1_1000 = 7'b1000001,
    AS2_1000 = 7'b1000010,
    AS3_1000 = 7'b1000011,
    AS4_1000 = 7'b1000100,
    AS5_1000 = 7'b1000101,
    AS6_1000 = 7'b1000110,
    AS7_1000 = 7'b1000111,

    AS0_1001 = 7'b1001000,
    AS1_1001 = 7'b1001001,
    AS2_1001 = 7'b1001010,
    AS3_1001 = 7'b1001011,
    AS4_1001 = 7'b1001100,
    AS5_1001 = 7'b1001101,
    AS6_1001 = 7'b1001110,
    AS7_1001 = 7'b1001111,
    
    AS0_1010 = 7'b1010000,
    AS1_1010 = 7'b1010001,
    AS2_1010 = 7'b1010010,
    AS3_1010 = 7'b1010011,
    AS4_1010 = 7'b1010100,
    AS5_1010 = 7'b1010101,
    AS6_1010 = 7'b1010110,
    AS7_1010 = 7'b1010111,

    AS0_1011 = 7'b1011000,
    AS1_1011 = 7'b1011001,
    AS2_1011 = 7'b1011010,
    AS3_1011 = 7'b1011011,
    AS4_1011 = 7'b1011100,
    AS5_1011 = 7'b1011101, 
    AS6_1011 = 7'b1011110,
    AS7_1011 = 7'b1011111,

    AS0_1100 = 7'b1100000,
    AS1_1100 = 7'b1100001,
    AS2_1100 = 7'b1100010,
    AS3_1100 = 7'b1100011,
    AS4_1100 = 7'b1100100,
    AS5_1100 = 7'b1100101,
    AS6_1100 = 7'b1100110,
    AS7_1100 = 7'b1100111,

    AS0_1101 = 7'b1101000,
    AS1_1101 = 7'b1101001,
    AS2_1101 = 7'b1101010,
    AS3_1101 = 7'b1101011,
    AS4_1101 = 7'b1101100,
    AS5_1101 = 7'b1101101,
    AS6_1101 = 7'b1101110,
    AS7_1101 = 7'b1101111,

    AS0_1110 = 7'b1110000,
    AS1_1110 = 7'b1110001,
    AS2_1110 = 7'b1110010,  
    AS3_1110 = 7'b1110011,
    AS4_1110 = 7'b1110100,
    AS5_1110 = 7'b1110101,
    AS6_1110 = 7'b1110110,
    AS7_1110 = 7'b1110111,

    AS0_1111 = 7'b1111000,
    AS1_1111 = 7'b1111001,
    AS2_1111 = 7'b1111010,
    AS3_1111 = 7'b1111011,
    AS4_1111 = 7'b1111100,
    AS5_1111 = 7'b1111101,
    AS6_1111 = 7'b1111110,
    AS7_1111 = 7'b1111111
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