// --------------------------------------------------------------------
// -- Accelarator module for FIR filter calculations
// --------------------------------------------------------------------
`define MATCH_TEST 32'h6027
`define MASK_TEST 32'hfe00707f
`define MATCH_LOADCONST 32'h1027
`define MASK_LOADCONST 32'h707f
`define MATCH_CALCULATE 32'h2027
`define MASK_CALCULATE 32'hfe00707f
`define MATCH_LOADH 32'h3027
`define MASK_LOADH 32'hfe00707f
`define MATCH_LOADS 32'h4027
`define MASK_LOADS 32'hfe00707f
`define MATCH_NUM_SHIFT 32'h00000000
  // opcodene ligger i /home/sp22/riscv-gnu-toolchain/binutils/include/opcode/riscv-opc.h

module FIR_accelerator import FIR_pkg::*; #(
  parameter N = 8,
  parameter K = 256,

  parameter WIDTH_COEFFICIENT = 32
)(
  input logic clk,
  input logic resetn,

  input        pcpi_valid,
  input [31:0] pcpi_insn,
  input [31:0] pcpi_rs1,
  input [31:0] pcpi_rs2,
  output reg        pcpi_wr,
  output reg [31:0] pcpi_rd,
  output reg        pcpi_wait,
  output reg        pcpi_ready
);

  localparam MCA_NUM_ADDITIONS = 16;

  logic start;                                                        // Start the calculation                

  logic signed [WIDTH_COEFFICIENT-1:0]  H_matrix [K-1:0][N-1:0];      // H matrix (coefficients)
  logic [N-1:0]                         S_matrix [K-1:0];             // S matrix (analog states)
  
  logic signed [WIDTH_COEFFICIENT-1:0]         sample_out;            // Output sample        

  state_e state, next_state;                                          // State machine 

  opcode_e pcpi_insn_decoded;                                         // Decoded instruction
  shift_h_addr_e shift_analog_state;                                  // State for shifting the analog states

  // --------------------------------------------------------------------
  // -- Assignments
  // --------------------------------------------------------------------

  assign pcpi_wait = 1'b0;

  // --------------------------------------------------------------------
  // -- State machine
  // --------------------------------------------------------------------
  always @(posedge clk or negedge resetn) begin : state_machine_b
    if (!resetn) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always_comb begin : state_machine_comb
    next_state = state;
    case (state)
      IDLE : begin
        if (pcpi_valid) begin
          next_state = CALCULATE;
        end
      end
      CALCULATE : begin
        next_state = IDLE;
      end
      default : begin
        next_state = IDLE;
      end
    endcase
  end

  always_ff @(posedge clk or negedge resetn) begin : state_machine_ff
    if (!resetn) begin
      start <= 1'b0;
    end else if ((start==0) && (pcpi_insn_decoded == OP_CALCULATE_O)) begin
      start <= 1'b1;
    end else begin start <= 1'b0; end
  end


  // --------------------------------------------------------------------
  // -- Shift the H matrix
  // --------------------------------------------------------------------
  always @(posedge clk or negedge resetn) begin : shift_h_matrix_b
    if (!resetn) begin
      // Resets the complete coefficient matrix
      for (int i = 0; i < K; i=i+1) begin
        for (int j = 0; j < N; j=j+1)begin
          H_matrix[i][j] <= '0;
        end
      end
    end else if (pcpi_valid && (state == CALCULATE) && (pcpi_insn_decoded == OP_SHIFT_H)) begin
      for (int i = 1; i < K; i = i+1) begin
        case (shift_analog_state) 
          AS0 : begin 
            H_matrix[i][0] <= H_matrix[i-1][0]; 
            H_matrix[0][0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS1 : begin 
            H_matrix[i][1] <= H_matrix[i-1][1]; 
            H_matrix[0][1] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS2 : begin 
            H_matrix[i][2] <= H_matrix[i-1][2]; 
            H_matrix[0][2] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS3 : begin 
            if (N > 3) begin
              H_matrix[i][3] <= H_matrix[i-1][3]; 
              H_matrix[0][3] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS4 : begin 
            if (N > 4) begin
              H_matrix[i][4] <= H_matrix[i-1][4]; 
              H_matrix[0][4] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS5 : begin 
            if (N > 5) begin
              H_matrix[i][5] <= H_matrix[i-1][5]; 
              H_matrix[0][5] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS6 : begin 
            if (N > 6) begin
              H_matrix[i][6] <= H_matrix[i-1][6]; 
              H_matrix[0][6] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS7 : begin 
            if (N > 7) begin
              H_matrix[i][7] <= H_matrix[i-1][7]; 
              H_matrix[0][7] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
        endcase
      end
    end
  end

  // --------------------------------------------------------------------
  // -- Shift the S matrix
  // --------------------------------------------------------------------
  always @( posedge clk or negedge resetn ) begin : shift_s_matrix_b
    if (!resetn) begin
      for (int i = 0; i < K; i=i+1) begin
        S_matrix[i] <= '0;
      end
    end else if (pcpi_valid && (state == CALCULATE) && ((pcpi_insn_decoded == OP_SHIFT_S) || pcpi_insn_decoded == OP_CALCULATE_O)) begin
      for (int i = 0; i < K-1; i=i+1) begin
        S_matrix[i] <= S_matrix[i+1];
      end
      S_matrix[K-1] <= pcpi_rs1[N-1:0];
    end
  end



  
  //--------------------------------------------------------------------
  // -- Decode the instruction
  //--------------------------------------------------------------------
  
  always @(posedge clk) begin
    if (pcpi_valid) begin
      if ((pcpi_insn & `MASK_CALCULATE) == `MATCH_CALCULATE) begin 
        pcpi_insn_decoded = OP_CALCULATE_O;
      end else if ((pcpi_insn & `MASK_LOADH) == `MATCH_LOADH) begin
        pcpi_insn_decoded = OP_SHIFT_H;
        shift_analog_state = pcpi_rs2[3:0];
      end else if ((pcpi_insn & `MASK_LOADS) == `MATCH_LOADS) begin
        pcpi_insn_decoded = OP_SHIFT_S;
      end
    end else begin
      pcpi_insn_decoded = OP_NOP;
    end

  end

  // --------------------------------------------------------------------
  // -- pcpi_rd and pcpi_wr
  // --------------------------------------------------------------------
  always_comb begin
    if (pcpi_insn_decoded == OP_CALCULATE_O && pcpi_valid) begin
      pcpi_rd <= sample_out;
      pcpi_wr <= 1'b1;
    end else begin
      pcpi_rd <= 32'b0;
      pcpi_wr <= 1'b0;
    end
  end

  // --------------------------------------------------------------------
  // -- pcpi_ready
  // --------------------------------------------------------------------
  always_comb begin
    if (pcpi_valid && state == CALCULATE) begin
      pcpi_ready <= 1'b1;
    end else begin
      pcpi_ready <= 1'b0;
    end
  end


  // The FIR adder module that does all calculations
  mca_hierchical_adder #(
    .K(K),
    .N(N),
    .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
    .MCA_NUM_ADDITIONS(MCA_NUM_ADDITIONS)
  ) adder
  (
  // Inputs
  .clk(clk), 
  .resetn(resetn),
  .start(start),
  .H_matrix(H_matrix),
  .S_matrix(S_matrix), 
  // Outputs
  .sample(sample_out)
  );

endmodule







