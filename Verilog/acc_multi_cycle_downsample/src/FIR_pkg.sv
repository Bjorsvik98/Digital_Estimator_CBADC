

package FIR_pkg;

  typedef enum logic [1:0] {
    OP_SHIFT_H          = 2'b00,
    OP_SHIFT_S          = 2'b01,
    OP_CALCULATE_O      = 2'b10, 
    OP_NOP              = 2'b11
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
 



endpackage