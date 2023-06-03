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
  parameter N_MAX = 8,
  parameter K_MAX = 512,

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
  localparam N3OSR = 20;
  localparam N4OSR = 15;
  localparam N5OSR = 12;
  localparam N6OSR = 9;
  localparam N7OSR = 8;
  localparam N8OSR = 7;

  logic start;                                                        // Start the calculation                

  logic signed [WIDTH_COEFFICIENT-1:0]  H_matrix [K_MAX-1:0][N_MAX-1:0];      // H matrix (coefficients)
  logic [N_MAX-1:0]                         S_matrix [K_MAX-1:0];             // S matrix (analog states)
  
  logic signed [WIDTH_COEFFICIENT-1:0]         sample_out;            // Output sample        

  state_e state, next_state;                                          // State machine 

  opcode_e pcpi_insn_decoded;                                         // Decoded instruction
  shift_h_addr_e shift_analog_state;                                  // State for shifting the analog states


  logic [N_MAX-1:0] N;
  logic [K_MAX/MCA_NUM_ADDITIONS-1:0] K;

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
      for (int i = 0; i < K_MAX; i=i+1) begin
        for (int j = 0; j < N_MAX; j=j+1)begin
          H_matrix[i][j] <= '0;
        end
      end
    end else if (pcpi_valid && (state == CALCULATE) && (pcpi_insn_decoded == OP_SHIFT_H)) begin
      for (int i = 1; i < K_MAX; i = i+1) begin
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
            if (N_MAX > 3) begin
              H_matrix[i][3] <= H_matrix[i-1][3]; 
              H_matrix[0][3] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS4 : begin 
            if (N_MAX > 4) begin
              H_matrix[i][4] <= H_matrix[i-1][4]; 
              H_matrix[0][4] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS5 : begin 
            if (N_MAX > 5) begin
              H_matrix[i][5] <= H_matrix[i-1][5]; 
              H_matrix[0][5] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS6 : begin 
            if (N_MAX > 6) begin
              H_matrix[i][6] <= H_matrix[i-1][6]; 
              H_matrix[0][6] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS7 : begin 
            if (N_MAX > 7) begin
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
      for (int i = 0; i < K_MAX; i=i+1) begin
        S_matrix[i] <= '0;
      end
    end else if (pcpi_valid && (state == CALCULATE) && ((pcpi_insn_decoded == OP_SHIFT_S) || pcpi_insn_decoded == OP_CALCULATE_O)) begin
      if (N_MAX==3) begin
        if (K[0]) begin
          for (int i = K_MAX-32; i < K_MAX-N3OSR; i=i+1) begin
            S_matrix[i] <= S_matrix[i+N3OSR];
          end
        end
        if (K_MAX > 32) begin
          if (K[2]) begin
            for (int i = K_MAX-2*32; i < K_MAX-32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 2*32) begin
        if (K[4]) begin
            for (int i = K_MAX-3*32; i < K_MAX-2*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 3*32) begin
          if (K[6]) begin
            for (int i = K_MAX-4*32; i < K_MAX-3*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 4*32) begin
          if (K[8]) begin
            for (int i = K_MAX-5*32; i < K_MAX-4*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 5*32) begin
          if (K[10]) begin
            for (int i = K_MAX-6*32; i < K_MAX-5*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 6*32) begin
          if (K[12]) begin
            for (int i = K_MAX-7*32; i < K_MAX-6*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 7*32) begin
          if (K[14]) begin
            for (int i = K_MAX-8*32; i < K_MAX-7*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 8*32) begin
          if (K[16]) begin
            for (int i = K_MAX-9*32; i < K_MAX-8*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 9*32) begin
          if (K[18]) begin
            for (int i = K_MAX-10*32; i < K_MAX-9*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 10*32) begin
          if (K[20]) begin
            for (int i = K_MAX-11*32; i < K_MAX-10*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 11*32) begin
          if (K[22]) begin
            for (int i = K_MAX-12*32; i < K_MAX-11*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 12*32) begin
          if (K[24]) begin
            for (int i = K_MAX-13*32; i < K_MAX-12*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 13*32) begin
          if (K[26]) begin
            for (int i = K_MAX-14*32; i < K_MAX-13*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 14*32) begin
          if (K[28]) begin
            for (int i = K_MAX-15*32; i < K_MAX-14*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end
        if (K_MAX > 15*32) begin
          if (K[30]) begin
            for (int i = K_MAX-16*32; i < K_MAX-15*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N3OSR];
            end
          end
        end

        S_matrix[K_MAX-11] <=pcpi_rs1[10*N_MAX-1:9*N_MAX];
        S_matrix[K_MAX-12] <= pcpi_rs1[9*N_MAX-1:8*N_MAX];
        S_matrix[K_MAX-13] <= pcpi_rs1[8*N_MAX-1:7*N_MAX];
        S_matrix[K_MAX-14] <= pcpi_rs1[7*N_MAX-1:6*N_MAX];
        S_matrix[K_MAX-15] <= pcpi_rs1[6*N_MAX-1:5*N_MAX];
        S_matrix[K_MAX-16] <= pcpi_rs1[5*N_MAX-1:4*N_MAX];
        S_matrix[K_MAX-17] <= pcpi_rs1[4*N_MAX-1:3*N_MAX];
        S_matrix[K_MAX-18] <= pcpi_rs1[3*N_MAX-1:2*N_MAX];
        S_matrix[K_MAX-19] <= pcpi_rs1[2*N_MAX-1:N_MAX];
        S_matrix[K_MAX-20] <= pcpi_rs1[N_MAX-1:0];
        S_matrix[K_MAX-1] <=pcpi_rs2[10*N_MAX-1:9*N_MAX];
        S_matrix[K_MAX-2] <= pcpi_rs2[9*N_MAX-1:8*N_MAX];
        S_matrix[K_MAX-3] <= pcpi_rs2[8*N_MAX-1:7*N_MAX];
        S_matrix[K_MAX-4] <= pcpi_rs2[7*N_MAX-1:6*N_MAX];
        S_matrix[K_MAX-5] <= pcpi_rs2[6*N_MAX-1:5*N_MAX];
        S_matrix[K_MAX-6] <= pcpi_rs2[5*N_MAX-1:4*N_MAX];
        S_matrix[K_MAX-7] <= pcpi_rs2[4*N_MAX-1:3*N_MAX];
        S_matrix[K_MAX-8] <= pcpi_rs2[3*N_MAX-1:2*N_MAX];
        S_matrix[K_MAX-9] <= pcpi_rs2[2*N_MAX-1:N_MAX];
        S_matrix[K_MAX-10] <=  pcpi_rs2[N_MAX-1:0];
        // If we want one more DSR we can get that but need to change SaveControlSequence in the python code on 
        // the sp22 server, to add the extra sequence and comment out the following line. The "problem" is that
        // we need bits from both rs1 and rs2, which is possible but not implemented in the python code.
        // S_matrix[K-21] <= {pcpi_rs1[31:30], pcpi_rs2[30]};
      end
      if (N_MAX==4) begin
        if (K[0]) begin
          for (int i = K_MAX-32; i < K_MAX-N4OSR; i=i+1) begin
            S_matrix[i] <= S_matrix[i+N4OSR];
          end
        end
        if (K_MAX > 32) begin
          if (K[2]) begin
            for (int i = K_MAX-2*32; i < K_MAX-32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 2*32) begin
        if (K[4]) begin
            for (int i = K_MAX-3*32; i < K_MAX-2*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 3*32) begin
          if (K[6]) begin
            for (int i = K_MAX-4*32; i < K_MAX-3*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 4*32) begin
          if (K[8]) begin
            for (int i = K_MAX-5*32; i < K_MAX-4*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 5*32) begin
          if (K[10]) begin
            for (int i = K_MAX-6*32; i < K_MAX-5*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 6*32) begin
          if (K[12]) begin
            for (int i = K_MAX-7*32; i < K_MAX-6*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 7*32) begin
          if (K[14]) begin
            for (int i = K_MAX-8*32; i < K_MAX-7*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 8*32) begin
          if (K[16]) begin
            for (int i = K_MAX-9*32; i < K_MAX-8*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 9*32) begin
          if (K[18]) begin
            for (int i = K_MAX-10*32; i < K_MAX-9*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 10*32) begin
          if (K[20]) begin
            for (int i = K_MAX-11*32; i < K_MAX-10*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 11*32) begin
          if (K[22]) begin
            for (int i = K_MAX-12*32; i < K_MAX-11*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 12*32) begin
          if (K[24]) begin
            for (int i = K_MAX-13*32; i < K_MAX-12*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 13*32) begin
          if (K[26]) begin
            for (int i = K_MAX-14*32; i < K_MAX-13*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 14*32) begin
          if (K[28]) begin
            for (int i = K_MAX-15*32; i < K_MAX-14*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end
        if (K_MAX > 15*32) begin
          if (K[30]) begin
            for (int i = K_MAX-16*32; i < K_MAX-15*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N4OSR];
            end
          end
        end

        S_matrix[K_MAX-9] <=pcpi_rs1 [7*N_MAX-1:6*N_MAX];
        S_matrix[K_MAX-10] <=pcpi_rs1[6*N_MAX-1:5*N_MAX];
        S_matrix[K_MAX-11] <=pcpi_rs1[5*N_MAX-1:4*N_MAX];
        S_matrix[K_MAX-12] <=pcpi_rs1[4*N_MAX-1:3*N_MAX];
        S_matrix[K_MAX-13] <=pcpi_rs1[3*N_MAX-1:2*N_MAX];
        S_matrix[K_MAX-14] <=pcpi_rs1[2*N_MAX-1:N_MAX];
        S_matrix[K_MAX-15] <= pcpi_rs1 [N_MAX-1:0];
        S_matrix[K_MAX-1] <= pcpi_rs2[8*N_MAX-1:7*N_MAX];
        S_matrix[K_MAX-2] <= pcpi_rs2[7*N_MAX-1:6*N_MAX];
        S_matrix[K_MAX-3] <= pcpi_rs2[6*N_MAX-1:5*N_MAX];
        S_matrix[K_MAX-4] <= pcpi_rs2[5*N_MAX-1:4*N_MAX];
        S_matrix[K_MAX-5] <= pcpi_rs2[4*N_MAX-1:3*N_MAX];
        S_matrix[K_MAX-6] <= pcpi_rs2[3*N_MAX-1:2*N_MAX];
        S_matrix[K_MAX-7] <= pcpi_rs2[2*N_MAX-1:N_MAX];
        S_matrix[K_MAX-8] <= pcpi_rs2[1*N_MAX-1:0];
      end
      if (N_MAX==5) begin
        if (K[0]) begin
          for (int i = K_MAX-32; i < K_MAX-N5OSR; i=i+1) begin
            S_matrix[i] <= S_matrix[i+N5OSR];
          end
        end
        if (K_MAX > 32) begin
          if (K[2]) begin
            for (int i = K_MAX-2*32; i < K_MAX-32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 2*32) begin
        if (K[4]) begin
            for (int i = K_MAX-3*32; i < K_MAX-2*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 3*32) begin
          if (K[6]) begin
            for (int i = K_MAX-4*32; i < K_MAX-3*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 4*32) begin
          if (K[8]) begin
            for (int i = K_MAX-5*32; i < K_MAX-4*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 5*32) begin
          if (K[10]) begin
            for (int i = K_MAX-6*32; i < K_MAX-5*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 6*32) begin
          if (K[12]) begin
            for (int i = K_MAX-7*32; i < K_MAX-6*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 7*32) begin
          if (K[14]) begin
            for (int i = K_MAX-8*32; i < K_MAX-7*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 8*32) begin
          if (K[16]) begin
            for (int i = K_MAX-9*32; i < K_MAX-8*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 9*32) begin
          if (K[18]) begin
            for (int i = K_MAX-10*32; i < K_MAX-9*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 10*32) begin
          if (K[20]) begin
            for (int i = K_MAX-11*32; i < K_MAX-10*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 11*32) begin
          if (K[22]) begin
            for (int i = K_MAX-12*32; i < K_MAX-11*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 12*32) begin
          if (K[24]) begin
            for (int i = K_MAX-13*32; i < K_MAX-12*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 13*32) begin
          if (K[26]) begin
            for (int i = K_MAX-14*32; i < K_MAX-13*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 14*32) begin
          if (K[28]) begin
            for (int i = K_MAX-15*32; i < K_MAX-14*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        if (K_MAX > 15*32) begin
          if (K[30]) begin
            for (int i = K_MAX-16*32; i < K_MAX-15*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N5OSR];
            end
          end
        end
        S_matrix[K_MAX-7] <= pcpi_rs1[6*N_MAX-1:5*N_MAX];
        S_matrix[K_MAX-8] <= pcpi_rs1[5*N_MAX-1:4*N_MAX];
        S_matrix[K_MAX-9] <= pcpi_rs1[4*N_MAX-1:3*N_MAX];
        S_matrix[K_MAX-10] <= pcpi_rs1[3*N_MAX-1:2*N_MAX];
        S_matrix[K_MAX-11] <= pcpi_rs1[2*N_MAX-1:N_MAX];
        S_matrix[K_MAX-12] <= pcpi_rs1[N_MAX-1:0];
        S_matrix[K_MAX-1] <= pcpi_rs2[6*N_MAX-1:5*N_MAX];
        S_matrix[K_MAX-2] <= pcpi_rs2[5*N_MAX-1:4*N_MAX];
        S_matrix[K_MAX-3] <= pcpi_rs2[4*N_MAX-1:3*N_MAX];
        S_matrix[K_MAX-4] <= pcpi_rs2[3*N_MAX-1:2*N_MAX];
        S_matrix[K_MAX-5] <= pcpi_rs2[2*N_MAX-1:N_MAX];
        S_matrix[K_MAX-6] <= pcpi_rs2[N_MAX-1:0];
      end
      if (N_MAX==6) begin
        if (K[0]) begin
          for (int i = K_MAX-32; i < K_MAX-N6OSR; i=i+1) begin
            S_matrix[i] <= S_matrix[i+N6OSR];
          end
        end
        if (K_MAX > 32) begin
          if (K[2]) begin
            for (int i = K_MAX-2*32; i < K_MAX-32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 2*32) begin
        if (K[4]) begin
            for (int i = K_MAX-3*32; i < K_MAX-2*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 3*32) begin
          if (K[6]) begin
            for (int i = K_MAX-4*32; i < K_MAX-3*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 4*32) begin
          if (K[8]) begin
            for (int i = K_MAX-5*32; i < K_MAX-4*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 5*32) begin
          if (K[10]) begin
            for (int i = K_MAX-6*32; i < K_MAX-5*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 6*32) begin
          if (K[12]) begin
            for (int i = K_MAX-7*32; i < K_MAX-6*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 7*32) begin
          if (K[14]) begin
            for (int i = K_MAX-8*32; i < K_MAX-7*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 8*32) begin
          if (K[16]) begin
            for (int i = K_MAX-9*32; i < K_MAX-8*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 9*32) begin
          if (K[18]) begin
            for (int i = K_MAX-10*32; i < K_MAX-9*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 10*32) begin
          if (K[20]) begin
            for (int i = K_MAX-11*32; i < K_MAX-10*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 11*32) begin
          if (K[22]) begin
            for (int i = K_MAX-12*32; i < K_MAX-11*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 12*32) begin
          if (K[24]) begin
            for (int i = K_MAX-13*32; i < K_MAX-12*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 13*32) begin
          if (K[26]) begin
            for (int i = K_MAX-14*32; i < K_MAX-13*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 14*32) begin
          if (K[28]) begin
            for (int i = K_MAX-15*32; i < K_MAX-14*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        if (K_MAX > 15*32) begin
          if (K[30]) begin
            for (int i = K_MAX-16*32; i < K_MAX-15*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N6OSR];
            end
          end
        end
        S_matrix[K_MAX-6] <= pcpi_rs1[4*N_MAX-1:3*N_MAX];
        S_matrix[K_MAX-7] <= pcpi_rs1[3*N_MAX-1:2*N_MAX];
        S_matrix[K_MAX-8] <= pcpi_rs1[2*N_MAX-1:1*N_MAX];
        S_matrix[K_MAX-9] <= pcpi_rs1[N_MAX-1:0];
        S_matrix[K_MAX-1] <= pcpi_rs2[5*N_MAX-1:4*N_MAX];
        S_matrix[K_MAX-2] <= pcpi_rs2[4*N_MAX-1:3*N_MAX];
        S_matrix[K_MAX-3] <= pcpi_rs2[3*N_MAX-1:2*N_MAX];
        S_matrix[K_MAX-4] <= pcpi_rs2[2*N_MAX-1:N_MAX];
        S_matrix[K_MAX-5] <= pcpi_rs2[N_MAX-1:0];
      end
      if (N_MAX==7) begin
        if (K[0]) begin
          for (int i = K_MAX-32; i < K_MAX-N7OSR; i=i+1) begin
            S_matrix[i] <= S_matrix[i+N7OSR];
          end
        end
        if (K_MAX > 32) begin
          if (K[2]) begin
            for (int i = K_MAX-2*32; i < K_MAX-32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 2*32) begin
          if (K[4]) begin
            for (int i = K_MAX-3*32; i < K_MAX-2*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 3*32) begin
          if (K[6]) begin
            for (int i = K_MAX-4*32; i < K_MAX-3*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 4*32) begin
          if (K[8]) begin
            for (int i = K_MAX-5*32; i < K_MAX-4*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 5*32) begin
          if (K[10]) begin
            for (int i = K_MAX-6*32; i < K_MAX-5*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 6*32) begin
          if (K[12]) begin
            for (int i = K_MAX-7*32; i < K_MAX-6*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 7*32) begin
          if (K[14]) begin
            for (int i = K_MAX-8*32; i < K_MAX-7*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 8*32) begin
          if (K[16]) begin
            for (int i = K_MAX-9*32; i < K_MAX-8*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 9*32) begin
          if (K[18]) begin
            for (int i = K_MAX-10*32; i < K_MAX-9*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 10*32) begin
          if (K[20]) begin
            for (int i = K_MAX-11*32; i < K_MAX-10*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 11*32) begin
          if (K[22]) begin
            for (int i = K_MAX-12*32; i < K_MAX-11*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 12*32) begin
          if (K[24]) begin
            for (int i = K_MAX-13*32; i < K_MAX-12*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 13*32) begin
          if (K[26]) begin
            for (int i = K_MAX-14*32; i < K_MAX-13*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 14*32) begin
          if (K[28]) begin
            for (int i = K_MAX-15*32; i < K_MAX-14*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end
        if (K_MAX > 15*32) begin
          if (K[30]) begin
            for (int i = K_MAX-16*32; i < K_MAX-15*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N7OSR];
            end
          end
        end

        S_matrix[K_MAX-5] <= pcpi_rs1[4*N_MAX-1:3*N_MAX];
        S_matrix[K_MAX-6] <= pcpi_rs1[3*N_MAX-1:2*N_MAX];
        S_matrix[K_MAX-7] <= pcpi_rs1[2*N_MAX-1:N_MAX];
        S_matrix[K_MAX-8] <= pcpi_rs1[N_MAX-1:0];
        S_matrix[K_MAX-1] <= pcpi_rs2[4*N_MAX-1:3*N_MAX];
        S_matrix[K_MAX-2] <= pcpi_rs2[3*N_MAX-1:2*N_MAX];
        S_matrix[K_MAX-3] <= pcpi_rs2[2*N_MAX-1:N_MAX];
        S_matrix[K_MAX-4] <= pcpi_rs2[N_MAX-1:0];
      end
      if (N_MAX==8) begin
        if (K[0]) begin
          for (int i = K_MAX-32; i < K_MAX-N8OSR; i=i+1) begin
            S_matrix[i] <= S_matrix[i+N8OSR];
          end
        end
        if (K_MAX > 32) begin
          if (K[2]) begin
            for (int i = K_MAX-2*32; i < K_MAX-32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 2*32) begin
          if (K[4]) begin
            for (int i = K_MAX-3*32; i < K_MAX-2*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 3*32) begin
          if (K[6]) begin
            for (int i = K_MAX-4*32; i < K_MAX-3*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 4*32) begin
          if (K[8]) begin
            for (int i = K_MAX-5*32; i < K_MAX-4*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 5*32) begin
          if (K[10]) begin
            for (int i = K_MAX-6*32; i < K_MAX-5*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 6*32) begin
          if (K[12]) begin
            for (int i = K_MAX-7*32; i < K_MAX-6*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 7*32) begin
          if (K[14]) begin
            for (int i = K_MAX-8*32; i < K_MAX-7*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 8*32) begin
          if (K[16]) begin
            for (int i = K_MAX-9*32; i < K_MAX-8*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 9*32) begin
          if (K[18]) begin
            for (int i = K_MAX-10*32; i < K_MAX-9*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 10*32) begin
          if (K[20]) begin
            for (int i = K_MAX-11*32; i < K_MAX-10*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 11*32) begin
          if (K[22]) begin
            for (int i = K_MAX-12*32; i < K_MAX-11*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 12*32) begin
          if (K[24]) begin
            for (int i = K_MAX-13*32; i < K_MAX-12*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 13*32) begin
          if (K[26]) begin
            for (int i = K_MAX-14*32; i < K_MAX-13*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 14*32) begin
          if (K[28]) begin
            for (int i = K_MAX-15*32; i < K_MAX-14*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end
        if (K_MAX > 15*32) begin
          if (K[30]) begin
            for (int i = K_MAX-16*32; i < K_MAX-15*32; i=i+1) begin
              S_matrix[i] <= S_matrix[i+N8OSR];
            end
          end
        end

        S_matrix[K_MAX-5] <= pcpi_rs1[3*N_MAX-1:2*N_MAX];
        S_matrix[K_MAX-6] <= pcpi_rs1[2*N_MAX-1:N_MAX];
        S_matrix[K_MAX-7] <= pcpi_rs1[N_MAX-1:0];
        S_matrix[K_MAX-1] <= pcpi_rs2[4*N_MAX-1:3*N_MAX];
        S_matrix[K_MAX-2] <= pcpi_rs2[3*N_MAX-1:2*N_MAX];
        S_matrix[K_MAX-3] <= pcpi_rs2[2*N_MAX-1:N_MAX];
        S_matrix[K_MAX-4] <= pcpi_rs2[N_MAX-1:0];
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
      end else if (((pcpi_insn & `MASK_TEST) == `MATCH_TEST) && pcpi_rs2[1:0] == PARAM_S_SHIFT) begin
        pcpi_insn_decoded = OP_NUM_SHIFT;
      end else if (((pcpi_insn & `MASK_TEST) == `MATCH_TEST) && pcpi_rs2[1:0] == PARAM_N_CHANGE) begin
        pcpi_insn_decoded = OP_N_CHANGE;
      end else if (((pcpi_insn & `MASK_TEST) == `MATCH_TEST) && pcpi_rs2[1:0] == PARAM_K_CHANGE) begin
        pcpi_insn_decoded = OP_K_CHANGE;
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

  // --------------------------------------------------------------------
  // -- change N register
  // --------------------------------------------------------------------
  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      N <= '0;
    end else if (pcpi_valid  && (pcpi_insn_decoded == OP_N_CHANGE)) begin
      N <= pcpi_rs1[N_MAX-1:0];
      // #2;
      // $display("N changed to %d", N);
    end
  end

  // --------------------------------------------------------------------
  // -- change K register
  // --------------------------------------------------------------------
  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      K <= '0;
    end else if (pcpi_valid  && (pcpi_insn_decoded == OP_K_CHANGE)) begin
      K <= pcpi_rs1[K_MAX/MCA_NUM_ADDITIONS-1:0];
      // #2;
      // $display("K changed to %d", K);

    end
  end


  // The FIR adder module that does all calculations
  mca_hierchical_adder #(
    .K_MAX(K_MAX),
    .N_MAX(N_MAX),
    .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
    .MCA_NUM_ADDITIONS(MCA_NUM_ADDITIONS)
  ) adder
  (
  // Inputs
  .clk(clk), 
  .resetn(resetn),
  .N(N),
  .K(K),

  .start(start),

  .H_matrix(H_matrix),
  .S_matrix(S_matrix), 
  // Outputs
  .sample(sample_out)
  );

endmodule







