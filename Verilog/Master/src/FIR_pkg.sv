

package FIR_pkg;

  typedef enum logic [1:0] {
    OP_SHIFT_H          = 2'b00,
    OP_SHIFT_S          = 2'b01,
    OP_CALCULATE_O      = 2'b10, 
    OP_NOP              = 2'b11
  } opcode_e;

  typedef enum logic [2:0] {
    AS0 = 3'b000,
    AS1 = 3'b001,
    AS2 = 3'b010,
    AS3 = 3'b011,
    AS4 = 3'b100,
    AS5 = 3'b101,
    AS6 = 3'b110,
    AS7 = 3'b111
  } shift_h_addr_e;


  typedef enum logic {
      IDLE      = 1'b0,
      CALCULATE = 1'b1
  } state_e;
 


endpackage