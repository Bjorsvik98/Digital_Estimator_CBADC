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
  localparam N3OSR = 20;
  localparam N4OSR = 15;
  localparam N5OSR = 12;
  localparam N6OSR = 9;
  localparam N7OSR = 8;
  localparam N8OSR = 7;


  logic start;                                                        // Start the calculation                

  logic signed [WIDTH_COEFFICIENT-1:0]  H_matrix_000 [(K/3 + K%3)-1:0][N-1:0];      // H matrix (coefficients)
  logic signed [WIDTH_COEFFICIENT-1:0]  H_matrix_001 [(K/3 + K%3)-1:0][N-1:0];      // H matrix (coefficients)
  logic signed [WIDTH_COEFFICIENT-1:0]  H_matrix_010 [(K/3 + K%3)-1:0][N-1:0];      // H matrix (coefficients)
  logic signed [WIDTH_COEFFICIENT-1:0]  H_matrix_011 [(K/3 + K%3)-1:0][N-1:0];      // H matrix (coefficients)

  logic signed [WIDTH_COEFFICIENT-1:0]  H_matrix_100 [(K/3 + K%3)-1:0][N-1:0];      // H matrix (coefficients)
  logic signed [WIDTH_COEFFICIENT-1:0]  H_matrix_101 [(K/3 + K%3)-1:0][N-1:0];      // H matrix (coefficients)
  logic signed [WIDTH_COEFFICIENT-1:0]  H_matrix_110 [(K/3 + K%3)-1:0][N-1:0];      // H matrix (coefficients)
  logic signed [WIDTH_COEFFICIENT-1:0]  H_matrix_111 [(K/3 + K%3)-1:0][N-1:0];      // H matrix (coefficients)


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
  always @(posedge clk or negedge resetn) begin : shift_H_matrix_b
    if (!resetn) begin
      // Resets the complete coefficient matrix
      for (int i = 0; i < (K/3 + K%3); i=i+1) begin
        for (int j = 0; j < N; j=j+1)begin
          H_matrix_000[i][j] <= '0;
          H_matrix_001[i][j] <= '0;
          H_matrix_010[i][j] <= '0;
          H_matrix_011[i][j] <= '0;

          H_matrix_000[i][j] <= '0;
          H_matrix_001[i][j] <= '0;
          H_matrix_010[i][j] <= '0;
          H_matrix_011[i][j] <= '0;
        end
      end
    end else if (pcpi_valid && (state == CALCULATE) && (pcpi_insn_decoded == OP_SHIFT_H)) begin
      for (int i = 1; i < K/3 + K%3; i = i+1) begin
        case (shift_analog_state) 
          AS0_000 : begin 
            H_matrix_000[i][0] <= H_matrix_000[i-1][0]; 
            H_matrix_000[0][0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS1_000 : begin 
            H_matrix_000[i][1] <= H_matrix_000[i-1][1]; 
            H_matrix_000[0][1] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS2_000 : begin 
            H_matrix_000[i][2] <= H_matrix_000[i-1][2]; 
            H_matrix_000[0][2] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS3_000 : begin 
            if (N > 3) begin
              H_matrix_000[i][3] <= H_matrix_000[i-1][3]; 
              H_matrix_000[0][3] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS4_000 : begin 
            if (N > 4) begin
              H_matrix_000[i][4] <= H_matrix_000[i-1][4]; 
              H_matrix_000[0][4] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS5_000 : begin 
            if (N > 5) begin
              H_matrix_000[i][5] <= H_matrix_000[i-1][5]; 
              H_matrix_000[0][5] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS6_000 : begin 
            if (N > 6) begin
              H_matrix_000[i][6] <= H_matrix_000[i-1][6]; 
              H_matrix_000[0][6] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS7_000 : begin 
            if (N > 7) begin
              H_matrix_000[i][7] <= H_matrix_000[i-1][7]; 
              H_matrix_000[0][7] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS0_001 : begin 
            H_matrix_001[i][0] <= H_matrix_001[i-1][0]; 
            H_matrix_001[0][0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS1_001 : begin 
            H_matrix_001[i][1] <= H_matrix_001[i-1][1]; 
            H_matrix_001[0][1] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS2_001 : begin 
            H_matrix_001[i][2] <= H_matrix_001[i-1][2]; 
            H_matrix_001[0][2] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS3_001 : begin 
            if (N > 3) begin
              H_matrix_001[i][3] <= H_matrix_001[i-1][3]; 
              H_matrix_001[0][3] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS4_001 : begin 
            if (N > 4) begin
              H_matrix_001[i][4] <= H_matrix_001[i-1][4]; 
              H_matrix_001[0][4] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS5_001 : begin 
            if (N > 5) begin
              H_matrix_001[i][5] <= H_matrix_001[i-1][5]; 
              H_matrix_001[0][5] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS6_001 : begin 
            if (N > 6) begin
              H_matrix_001[i][6] <= H_matrix_001[i-1][6]; 
              H_matrix_001[0][6] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS7_001 : begin 
            if (N > 7) begin
              H_matrix_001[i][7] <= H_matrix_001[i-1][7]; 
              H_matrix_001[0][7] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS0_010 : begin 
            H_matrix_010[i][0] <= H_matrix_010[i-1][0]; 
            H_matrix_010[0][0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS1_010 : begin 
            H_matrix_010[i][1] <= H_matrix_010[i-1][1]; 
            H_matrix_010[0][1] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS2_010 : begin 
            H_matrix_010[i][2] <= H_matrix_010[i-1][2]; 
            H_matrix_010[0][2] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS3_010 : begin 
            if (N > 3) begin
              H_matrix_010[i][3] <= H_matrix_010[i-1][3]; 
              H_matrix_010[0][3] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS4_010 : begin 
            if (N > 4) begin
              H_matrix_010[i][4] <= H_matrix_010[i-1][4]; 
              H_matrix_010[0][4] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS5_010 : begin 
            if (N > 5) begin
              H_matrix_010[i][5] <= H_matrix_010[i-1][5]; 
              H_matrix_010[0][5] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS6_010 : begin 
            if (N > 6) begin
              H_matrix_010[i][6] <= H_matrix_010[i-1][6]; 
              H_matrix_010[0][6] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS7_010 : begin 
            if (N > 7) begin
              H_matrix_010[i][7] <= H_matrix_010[i-1][7]; 
              H_matrix_010[0][7] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS0_011 : begin 
            H_matrix_011[i][0] <= H_matrix_011[i-1][0]; 
            H_matrix_011[0][0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS1_011 : begin 
            H_matrix_011[i][1] <= H_matrix_011[i-1][1]; 
            H_matrix_011[0][1] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS2_011 : begin 
            H_matrix_011[i][2] <= H_matrix_011[i-1][2]; 
            H_matrix_011[0][2] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS3_011 : begin 
            if (N > 3) begin
              H_matrix_011[i][3] <= H_matrix_011[i-1][3]; 
              H_matrix_011[0][3] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS4_011 : begin 
            if (N > 4) begin
              H_matrix_011[i][4] <= H_matrix_011[i-1][4]; 
              H_matrix_011[0][4] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS5_011 : begin 
            if (N > 5) begin
              H_matrix_011[i][5] <= H_matrix_011[i-1][5]; 
              H_matrix_011[0][5] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS6_011 : begin 
            if (N > 6) begin
              H_matrix_011[i][6] <= H_matrix_011[i-1][6]; 
              H_matrix_011[0][6] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS7_011 : begin 
            if (N > 7) begin
              H_matrix_011[i][7] <= H_matrix_011[i-1][7]; 
              H_matrix_011[0][7] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS0_100 : begin 
            H_matrix_100[i][0] <= H_matrix_100[i-1][0]; 
            H_matrix_100[0][0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS1_100 : begin 
            H_matrix_100[i][1] <= H_matrix_100[i-1][1]; 
            H_matrix_100[0][1] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS2_100 : begin 
            H_matrix_100[i][2] <= H_matrix_100[i-1][2]; 
            H_matrix_100[0][2] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS3_100 : begin 
            if (N > 3) begin
              H_matrix_100[i][3] <= H_matrix_100[i-1][3]; 
              H_matrix_100[0][3] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS4_100 : begin 
            if (N > 4) begin
              H_matrix_100[i][4] <= H_matrix_100[i-1][4]; 
              H_matrix_100[0][4] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS5_100 : begin 
            if (N > 5) begin
              H_matrix_100[i][5] <= H_matrix_100[i-1][5]; 
              H_matrix_100[0][5] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS6_100 : begin 
            if (N > 6) begin
              H_matrix_100[i][6] <= H_matrix_100[i-1][6]; 
              H_matrix_100[0][6] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS7_100 : begin 
            if (N > 7) begin
              H_matrix_100[i][7] <= H_matrix_100[i-1][7]; 
              H_matrix_100[0][7] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS0_101 : begin 
            H_matrix_101[i][0] <= H_matrix_101[i-1][0]; 
            H_matrix_101[0][0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS1_101 : begin 
            H_matrix_101[i][1] <= H_matrix_101[i-1][1]; 
            H_matrix_101[0][1] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS2_101 : begin 
            H_matrix_101[i][2] <= H_matrix_101[i-1][2]; 
            H_matrix_101[0][2] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS3_101 : begin 
            if (N > 3) begin
              H_matrix_101[i][3] <= H_matrix_101[i-1][3]; 
              H_matrix_101[0][3] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS4_101 : begin 
            if (N > 4) begin
              H_matrix_101[i][4] <= H_matrix_101[i-1][4]; 
              H_matrix_101[0][4] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS5_101 : begin 
            if (N > 5) begin
              H_matrix_101[i][5] <= H_matrix_101[i-1][5]; 
              H_matrix_101[0][5] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS6_101 : begin 
            if (N > 6) begin
              H_matrix_101[i][6] <= H_matrix_101[i-1][6]; 
              H_matrix_101[0][6] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS7_101 : begin 
            if (N > 7) begin
              H_matrix_101[i][7] <= H_matrix_101[i-1][7]; 
              H_matrix_101[0][7] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS0_110 : begin 
            H_matrix_110[i][0] <= H_matrix_110[i-1][0]; 
            H_matrix_110[0][0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS1_110 : begin 
            H_matrix_110[i][1] <= H_matrix_110[i-1][1]; 
            H_matrix_110[0][1] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS2_110 : begin 
            H_matrix_110[i][2] <= H_matrix_110[i-1][2]; 
            H_matrix_110[0][2] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS3_110 : begin 
            if (N > 3) begin
              H_matrix_110[i][3] <= H_matrix_110[i-1][3]; 
              H_matrix_110[0][3] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS4_110 : begin 
            if (N > 4) begin
              H_matrix_110[i][4] <= H_matrix_110[i-1][4]; 
              H_matrix_110[0][4] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS5_110 : begin 
            if (N > 5) begin
              H_matrix_110[i][5] <= H_matrix_110[i-1][5]; 
              H_matrix_110[0][5] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS6_110 : begin 
            if (N > 6) begin
              H_matrix_110[i][6] <= H_matrix_110[i-1][6]; 
              H_matrix_110[0][6] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS7_110 : begin 
            if (N > 7) begin
              H_matrix_110[i][7] <= H_matrix_110[i-1][7]; 
              H_matrix_110[0][7] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS0_111 : begin 
            H_matrix_111[i][0] <= H_matrix_111[i-1][0]; 
            H_matrix_111[0][0] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS1_111 : begin 
            H_matrix_111[i][1] <= H_matrix_111[i-1][1]; 
            H_matrix_111[0][1] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS2_111 : begin 
            H_matrix_111[i][2] <= H_matrix_111[i-1][2]; 
            H_matrix_111[0][2] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
          end
          AS3_111 : begin 
            if (N > 3) begin
              H_matrix_111[i][3] <= H_matrix_111[i-1][3]; 
              H_matrix_111[0][3] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS4_111 : begin 
            if (N > 4) begin
              H_matrix_111[i][4] <= H_matrix_111[i-1][4]; 
              H_matrix_111[0][4] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS5_111 : begin 
            if (N > 5) begin
              H_matrix_111[i][5] <= H_matrix_111[i-1][5]; 
              H_matrix_111[0][5] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS6_111 : begin 
            if (N > 6) begin
              H_matrix_111[i][6] <= H_matrix_111[i-1][6]; 
              H_matrix_111[0][6] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
            end
          end
          AS7_111 : begin 
            if (N > 7) begin
              H_matrix_111[i][7] <= H_matrix_111[i-1][7]; 
              H_matrix_111[0][7] <= $signed(pcpi_rs1[WIDTH_COEFFICIENT-1:0]); 
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
        // If we want one more DSR we can get that but need to change SaveControlSequence in the python code on 
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
        S_matrix[K-8] <= pcpi_rs1[2*N-1:1*N];
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
        shift_analog_state = pcpi_rs2[5:0];
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
  .H_matrix_000(H_matrix_000),
  .H_matrix_001(H_matrix_001),
  .H_matrix_010(H_matrix_010),
  .H_matrix_011(H_matrix_011),
  .H_matrix_100(H_matrix_100),
  .H_matrix_101(H_matrix_101),
  .H_matrix_110(H_matrix_110),
  .H_matrix_111(H_matrix_111),
  .S_matrix(S_matrix), 
  // Outputs
  .sample(sample_out)
  );

endmodule







