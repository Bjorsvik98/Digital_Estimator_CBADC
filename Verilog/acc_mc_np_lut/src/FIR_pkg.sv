

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

  typedef enum logic [4:0] {
    AS0_00 = 5'b00000,
    AS1_00 = 5'b00001,
    AS2_00 = 5'b00010,
    AS3_00 = 5'b00011,
    AS4_00 = 5'b00100,
    AS5_00 = 5'b00101,
    AS6_00 = 5'b00110,
    AS7_00 = 5'b00111,

    AS0_01 = 5'b01000,
    AS1_01 = 5'b01001,
    AS2_01 = 5'b01010,
    AS3_01 = 5'b01011,
    AS4_01 = 5'b01100,
    AS5_01 = 5'b01101,
    AS6_01 = 5'b01110,
    AS7_01 = 5'b01111,

    AS0_10 = 5'b10000,
    AS1_10 = 5'b10001,
    AS2_10 = 5'b10010,
    AS3_10 = 5'b10011,
    AS4_10 = 5'b10100,
    AS5_10 = 5'b10101,
    AS6_10 = 5'b10110,
    AS7_10 = 5'b10111,

    AS0_11 = 5'b11000,
    AS1_11 = 5'b11001,
    AS2_11 = 5'b11010,
    AS3_11 = 5'b11011,
    AS4_11 = 5'b11100,
    AS5_11 = 5'b11101,
    AS6_11 = 5'b11110,
    AS7_11 = 5'b11111
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