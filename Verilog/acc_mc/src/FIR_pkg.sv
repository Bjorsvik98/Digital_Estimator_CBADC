

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

  typedef enum logic [3:0] {
    AS0 = 4'b0000,
    AS1 = 4'b0001,
    AS2 = 4'b0010,
    AS3 = 4'b0011,
    AS4 = 4'b0100,
    AS5 = 4'b0101,
    AS6 = 4'b0110,
    AS7 = 4'b0111,

    AS0_n = 4'b1000,
    AS1_n = 4'b1001,
    AS2_n = 4'b1010,
    AS3_n = 4'b1011,
    AS4_n = 4'b1100,
    AS5_n = 4'b1101,
    AS6_n = 4'b1110,
    AS7_n = 4'b1111
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