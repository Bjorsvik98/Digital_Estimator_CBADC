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
  localparam reduce_AS1 = 2;
  localparam reduce_AS2 = 3;
  localparam reduce_AS3 = 4;
  localparam reduce_AS4 = 5;
  localparam reduce_AS5 = 6;
  localparam reduce_AS6 = 8;
  localparam reduce_AS7 = 9;

  localparam N3OSR = 23;
  localparam N4OSR = 15;
  localparam N5OSR = 12;
  localparam N6OSR = 9;
  localparam N7OSR = 8;
  localparam N8OSR = 7;


  logic start;                                                        // Start the calculation                

  logic signed [WIDTH_COEFFICIENT-1:0]  H_matrix_AS0 [K-1:0];      // H matrix (coefficients)
  logic signed [WIDTH_COEFFICIENT-reduce_AS1-1:0]  H_matrix_AS1 [K-1:0];      // H matrix (coefficients)
  logic signed [WIDTH_COEFFICIENT-reduce_AS2-1:0]  H_matrix_AS2 [K-1:0];      // H matrix (coefficients)
  logic signed [WIDTH_COEFFICIENT-reduce_AS3-1:0]  H_matrix_AS3 [K-1:0];
  logic signed [WIDTH_COEFFICIENT-reduce_AS4-1:0]  H_matrix_AS4 [K-1:0];
  logic signed [WIDTH_COEFFICIENT-reduce_AS5-1:0] H_matrix_AS5 [K-1:0];
  logic signed [WIDTH_COEFFICIENT-reduce_AS6-1:0] H_matrix_AS6 [K-1:0];
  logic signed [WIDTH_COEFFICIENT-reduce_AS7-1:0] H_matrix_AS7 [K-1:0];

  genvar H_set_0;
    for (H_set_0 = 0; H_set_0 < K; H_set_0++) begin
      if (N < 4) assign H_matrix_AS3[H_set_0] = '0;
      if (N < 5) assign H_matrix_AS4[H_set_0] = '0;
      if (N < 6) assign H_matrix_AS5[H_set_0] = '0;
      if (N < 7) assign H_matrix_AS6[H_set_0] = '0;
      if (N < 8) assign H_matrix_AS7[H_set_0] = '0;
    end
  
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
        H_matrix_AS0[i] <= '0;
        H_matrix_AS1[i] <= '0;
        H_matrix_AS2[i] <= '0;
        if (N > 3) H_matrix_AS3[i] <= '0;
        if (N > 4) H_matrix_AS4[i] <= '0;
        if (N > 5) H_matrix_AS5[i] <= '0;
        if (N > 6) H_matrix_AS6[i] <= '0;
        if (N > 7) H_matrix_AS7[i] <= '0;
      end
    end else if (pcpi_valid && (state == CALCULATE) && (pcpi_insn_decoded == OP_SHIFT_H)) begin
      for (int i = 1; i < K; i = i+1) begin
        case (shift_analog_state) 
          AS0 : begin 
            H_matrix_AS0[i] <= H_matrix_AS0[i-1]; 
            H_matrix_AS0[0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS1 : begin 
            H_matrix_AS1[i] <= H_matrix_AS1[i-1]; 
            H_matrix_AS1[0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-reduce_AS1-1:0]); 
          end
          AS2 : begin 
            H_matrix_AS2[i] <= H_matrix_AS2[i-1]; 
            H_matrix_AS2[0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-reduce_AS2-1:0]); 
          end
          AS3 : begin 
            if (N > 3) begin
              H_matrix_AS3[i] <= H_matrix_AS3[i-1]; 
              H_matrix_AS3[0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-reduce_AS3-1:0]); 
            end
          end
          AS4 : begin 
            if (N > 4) begin
              H_matrix_AS4[i] <= H_matrix_AS4[i-1]; 
              H_matrix_AS4[0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-reduce_AS4-1:0]); 
            end
          end
          AS5 : begin 
            if (N > 5) begin
              H_matrix_AS5[i] <= H_matrix_AS5[i-1]; 
              H_matrix_AS5[0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-reduce_AS5-1:0]); 
            end
          end
          AS6 : begin 
            if (N > 6) begin
              H_matrix_AS6[i] <= H_matrix_AS6[i-1]; 
              H_matrix_AS6[0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-reduce_AS6-1:0]); 
            end
          end
          AS7 : begin 
            if (N > 7) begin
              H_matrix_AS7[i] <= H_matrix_AS7[i-1]; 
              H_matrix_AS7[0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-reduce_AS7-1:0]); 
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
      if (N==3) begin
        for (int i = 0; i < K-N3OSR; i=i+1) begin
          S_matrix[i] <= S_matrix[i+N3OSR];
        end
        S_matrix[K-11] <= pcpi_rs1[10*N-1:9*N];
        S_matrix[K-12] <= pcpi_rs1[9*N-1:8*N];
        S_matrix[K-13] <= pcpi_rs1[8*N-1:7*N];
        S_matrix[K-14] <= pcpi_rs1[7*N-1:6*N];
        S_matrix[K-15] <= pcpi_rs1[6*N-1:5*N];
        S_matrix[K-16] <= pcpi_rs1[5*N-1:4*N];
        S_matrix[K-17] <= pcpi_rs1[4*N-1:3*N];
        S_matrix[K-18] <= pcpi_rs1[3*N-1:2*N];
        S_matrix[K-19] <= pcpi_rs1[2*N-1:N];
        S_matrix[K-20] <= pcpi_rs1[N-1:0];
        S_matrix[K-1] <= pcpi_rs2[10*N-1:9*N];
        S_matrix[K-2] <= pcpi_rs2[9*N-1:8*N];
        S_matrix[K-3] <= pcpi_rs2[8*N-1:7*N];
        S_matrix[K-4] <= pcpi_rs2[7*N-1:6*N];
        S_matrix[K-5] <= pcpi_rs2[6*N-1:5*N];
        S_matrix[K-6] <= pcpi_rs2[5*N-1:4*N];
        S_matrix[K-7] <= pcpi_rs2[4*N-1:3*N];
        S_matrix[K-8] <= pcpi_rs2[3*N-1:2*N];
        S_matrix[K-9] <= pcpi_rs2[2*N-1:N];
        S_matrix[K-10] <= pcpi_rs2[N-1:0];
        // If we want one more DSR we can get that but need to change SaveControlSequense in the python code on 
        // the sp22 server, to add the extra sequence and comment out the following line. The "problem" is that
        // we need bits from both rs1 and rs2, which is possible but not implemented in the python code.
        // S_matrix[K-21] <= {pcpi_rs1[31:30], pcpi_rs2[30]};
      end
      if (N==4) begin
        for (int i = 0; i < K-N4OSR; i=i+1) begin
          S_matrix[i] <= S_matrix[i+N4OSR];
        end
        S_matrix[K-9] <= pcpi_rs1[7*N-1:6*N];
        S_matrix[K-10] <= pcpi_rs1[6*N-1:5*N];
        S_matrix[K-11] <= pcpi_rs1[5*N-1:4*N];
        S_matrix[K-12] <= pcpi_rs1[4*N-1:3*N];
        S_matrix[K-13] <= pcpi_rs1[3*N-1:2*N];
        S_matrix[K-14] <= pcpi_rs1[2*N-1:N];
        S_matrix[K-15] <= pcpi_rs1[N-1:0];
        S_matrix[K-1] <= pcpi_rs2[8*N-1:7*N];
        S_matrix[K-2] <= pcpi_rs2[7*N-1:6*N];
        S_matrix[K-3] <= pcpi_rs2[6*N-1:5*N];
        S_matrix[K-4] <= pcpi_rs2[5*N-1:4*N];
        S_matrix[K-5] <= pcpi_rs2[4*N-1:3*N];
        S_matrix[K-6] <= pcpi_rs2[3*N-1:2*N];
        S_matrix[K-7] <= pcpi_rs2[2*N-1:1*N];
        S_matrix[K-8] <= pcpi_rs2[1*N-1:0];
      end
      if (N==5) begin
        for (int i = 0; i < K-N5OSR; i=i+1) begin
          S_matrix[i] <= S_matrix[i+N5OSR];
        end
        S_matrix[K-7] <= pcpi_rs1[6*N-1:5*N];
        S_matrix[K-8] <= pcpi_rs1[5*N-1:4*N];
        S_matrix[K-9] <= pcpi_rs1[4*N-1:3*N];
        S_matrix[K-10] <= pcpi_rs1[3*N-1:2*N];
        S_matrix[K-11] <= pcpi_rs1[2*N-1:N];
        S_matrix[K-12] <= pcpi_rs1[N-1:0];
        S_matrix[K-1] <= pcpi_rs2[6*N-1:5*N];
        S_matrix[K-2] <= pcpi_rs2[5*N-1:4*N];
        S_matrix[K-3] <= pcpi_rs2[4*N-1:3*N];
        S_matrix[K-4] <= pcpi_rs2[3*N-1:2*N];
        S_matrix[K-5] <= pcpi_rs2[2*N-1:N];
        S_matrix[K-6] <= pcpi_rs2[N-1:0];
      end
      if (N==6) begin
        for (int i = 0; i < K-N6OSR; i=i+1) begin
          S_matrix[i] <= S_matrix[i+N6OSR];
        end
        S_matrix[K-6] <= pcpi_rs1[4*N-1:3*N];
        S_matrix[K-7] <= pcpi_rs1[3*N-1:2*N];
        S_matrix[K-8] <= pcpi_rs1[2*N-1:N];
        S_matrix[K-9] <= pcpi_rs1[N-1:0];
        S_matrix[K-1] <= pcpi_rs2[5*N-1:4*N];
        S_matrix[K-2] <= pcpi_rs2[4*N-1:3*N];
        S_matrix[K-3] <= pcpi_rs2[3*N-1:2*N];
        S_matrix[K-4] <= pcpi_rs2[2*N-1:N];
        S_matrix[K-5] <= pcpi_rs2[N-1:0];
      end
      if (N==7) begin
        for (int i = 0; i < K-N7OSR; i=i+1) begin
          S_matrix[i] <= S_matrix[i+N7OSR];
        end
        S_matrix[K-5] <= pcpi_rs1[4*N-1:3*N];
        S_matrix[K-6] <= pcpi_rs1[3*N-1:2*N];
        S_matrix[K-7] <= pcpi_rs1[2*N-1:N];
        S_matrix[K-8] <= pcpi_rs1[N-1:0];
        S_matrix[K-1] <= pcpi_rs2[4*N-1:3*N];
        S_matrix[K-2] <= pcpi_rs2[3*N-1:2*N];
        S_matrix[K-3] <= pcpi_rs2[2*N-1:N];
        S_matrix[K-4] <= pcpi_rs2[N-1:0];
      end
      if (N==8) begin
        for (int i = 0; i < K-N8OSR; i=i+1) begin
          S_matrix[i] <= S_matrix[i+N8OSR];
        end
        S_matrix[K-5] <= pcpi_rs1[3*N-1:2*N];
        S_matrix[K-6] <= pcpi_rs1[2*N-1:N];
        S_matrix[K-7] <= pcpi_rs1[N-1:0];
        S_matrix[K-1] <= pcpi_rs2[4*N-1:3*N];
        S_matrix[K-2] <= pcpi_rs2[3*N-1:2*N];
        S_matrix[K-3] <= pcpi_rs2[2*N-1:N];
        S_matrix[K-4] <= pcpi_rs2[N-1:0];
      end
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
    .MCA_NUM_ADDITIONS(MCA_NUM_ADDITIONS),
    .reduce_AS1(reduce_AS1),
    .reduce_AS2(reduce_AS2),
    .reduce_AS3(reduce_AS3),
    .reduce_AS4(reduce_AS4),
    .reduce_AS5(reduce_AS5),
    .reduce_AS6(reduce_AS6),
    .reduce_AS7(reduce_AS7)
  ) adder
  (// Inputs
    .clk(clk), 
    .resetn(resetn),
    .start(start),
    .H_matrix_AS0(H_matrix_AS0),
    .H_matrix_AS1(H_matrix_AS1),
    .H_matrix_AS2(H_matrix_AS2),
    .H_matrix_AS3(H_matrix_AS3),
    .H_matrix_AS4(H_matrix_AS4),
    .H_matrix_AS5(H_matrix_AS5),
    .H_matrix_AS6(H_matrix_AS6),
    .H_matrix_AS7(H_matrix_AS7),
    .S_matrix(S_matrix), 
    // Outputs
    .sample(sample_out)
      );
endmodule







