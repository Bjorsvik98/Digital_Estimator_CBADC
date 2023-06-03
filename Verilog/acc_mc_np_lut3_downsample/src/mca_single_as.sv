`timescale 1 ns / 1 ps


// --------------------------------------------------------------------------
// -- Module calculating all FIR filter additions
// --------------------------------------------------------------------------

module mca_single_as import FIR_pkg::*; #(
  parameter K = 256,                  // Should be as low as possible, but still meet SNR requirements Can not be higher than 512 and must be multiple of 4
  parameter N = 8,                    //
  parameter WIDTH_COEFFICIENT=32,     // Max 32
  parameter MCA_NUM_ADDITIONS=16      // Equal to lowest NUM_ADDER_STAGES where N*K < NUM_ADD_CLK**NUM_ADDER_STAGES

)(
  input clk,
  input resetn,

  input logic start,

  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_000 [(K/3 + K%3)-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_001 [(K/3 + K%3)-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_010 [(K/3 + K%3)-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_011 [(K/3 + K%3)-1:0],

  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_100 [(K/3 + K%3)-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_101 [(K/3 + K%3)-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_110 [(K/3 + K%3)-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_111 [(K/3 + K%3)-1:0],

  input logic S_matrix [K-1:0],

  output logic signed [WIDTH_COEFFICIENT-1:0] sample
);


// --------------------------------------------------------------------------
// -- Local parameters
// --------------------------------------------------------------------------

localparam N3_REST = 11; // (512/3)%16
localparam N4_REST = 6; 
localparam N5_REST = 6;
localparam N6_REST = 11;
localparam N7_REST = 11;
localparam N8_REST = 6;
// --------------------------------------------------------------------------
// -- Signal declarations
// --------------------------------------------------------------------------


logic signed [WIDTH_COEFFICIENT-1:0] final_adder_input [MCA_NUM_ADDITIONS-1:0];
// --------------------------------------------------------------------------
// -- assignments
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// -- Adder stage 1
// --------------------------------------------------------------------------

  genvar stage_1;
  generate
    for (stage_1 = 0; stage_1 < (K/(MCA_NUM_ADDITIONS*3)); stage_1++) begin : stage_1_generate
      mca_lut #(
        .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
        .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
      ) mca_adder_stage_1 (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .operands_000(H_matrix_000[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
        .operands_001(H_matrix_001[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
        .operands_010(H_matrix_010[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
        .operands_011(H_matrix_011[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),

        .operands_100(H_matrix_100[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
        .operands_101(H_matrix_101[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
        .operands_110(H_matrix_110[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
        .operands_111(H_matrix_111[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),

        .S_values(S_matrix[3*stage_1*MCA_NUM_ADDITIONS+:3*MCA_NUM_ADDITIONS]),
        .enable(1'b1),
        .res(final_adder_input[stage_1])
      );
    end
    if ((N==3)) begin
      mca_lut #(
        .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
        .NUM_ADDITIONS(N3_REST)
      ) mca_adder_stage_1_2 (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .operands_000(H_matrix_000[K/3-N3_REST-1+:N3_REST]),
        .operands_001(H_matrix_001[K/3-N3_REST-1+:N3_REST]),
        .operands_010(H_matrix_010[K/3-N3_REST-1+:N3_REST]),
        .operands_011(H_matrix_011[K/3-N3_REST-1+:N3_REST]),

        .operands_100(H_matrix_100[K/3-N3_REST-1+:N3_REST]),
        .operands_101(H_matrix_101[K/3-N3_REST-1+:N3_REST]),
        .operands_110(H_matrix_110[K/3-N3_REST-1+:N3_REST]),
        .operands_111(H_matrix_111[K/3-N3_REST-1+:N3_REST]),

        .S_values(S_matrix[K-1:K-N3_REST*3]),
        .enable(1'b1),
        .res(final_adder_input[(K/(MCA_NUM_ADDITIONS*3))])
      );
    end
    if ((N==4)) begin
      mca_lut #(
        .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
        .NUM_ADDITIONS(N4_REST)
      ) mca_adder_stage_1_2 (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .operands_000(H_matrix_000[K/3-N4_REST-1+:N4_REST]),
        .operands_001(H_matrix_001[K/3-N4_REST-1+:N4_REST]),
        .operands_010(H_matrix_010[K/3-N4_REST-1+:N4_REST]),
        .operands_011(H_matrix_011[K/3-N4_REST-1+:N4_REST]),

        .operands_100(H_matrix_100[K/3-N4_REST-1+:N4_REST]),
        .operands_101(H_matrix_101[K/3-N4_REST-1+:N4_REST]),
        .operands_110(H_matrix_110[K/3-N4_REST-1+:N4_REST]),
        .operands_111(H_matrix_111[K/3-N4_REST-1+:N4_REST]),

        .S_values(S_matrix[K-1:K-N4_REST*3]),
        .enable(1'b1),
        .res(final_adder_input[(K/(MCA_NUM_ADDITIONS*3))])
      );
    end
    if ((N==5)) begin
      mca_lut #(
        .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
        .NUM_ADDITIONS(N5_REST)
      ) mca_adder_stage_1_2 (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .operands_000(H_matrix_000[K/3-N5_REST-1+:N5_REST]),
        .operands_001(H_matrix_001[K/3-N5_REST-1+:N5_REST]),
        .operands_010(H_matrix_010[K/3-N5_REST-1+:N5_REST]),
        .operands_011(H_matrix_011[K/3-N5_REST-1+:N5_REST]),

        .operands_100(H_matrix_100[K/3-N5_REST-1+:N5_REST]),
        .operands_101(H_matrix_101[K/3-N5_REST-1+:N5_REST]),
        .operands_110(H_matrix_110[K/3-N5_REST-1+:N5_REST]),
        .operands_111(H_matrix_111[K/3-N5_REST-1+:N5_REST]),

        .S_values(S_matrix[K-1:K-N5_REST*3]),
        .enable(1'b1),
        .res(final_adder_input[(K/(MCA_NUM_ADDITIONS*3))])
      );
    end
    if ((N==6)) begin
      mca_lut #(
        .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
        .NUM_ADDITIONS(N6_REST)
      ) mca_adder_stage_1_2 (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .operands_000(H_matrix_000[K/3-N6_REST-1+:N6_REST]),
        .operands_001(H_matrix_001[K/3-N6_REST-1+:N6_REST]),
        .operands_010(H_matrix_010[K/3-N6_REST-1+:N6_REST]),
        .operands_011(H_matrix_011[K/3-N6_REST-1+:N6_REST]),

        .operands_100(H_matrix_100[K/3-N6_REST-1+:N6_REST]),
        .operands_101(H_matrix_101[K/3-N6_REST-1+:N6_REST]),
        .operands_110(H_matrix_110[K/3-N6_REST-1+:N6_REST]),
        .operands_111(H_matrix_111[K/3-N6_REST-1+:N6_REST]),

        .S_values(S_matrix[K-1:K-N6_REST*3]),
        .enable(1'b1),
        .res(final_adder_input[(K/(MCA_NUM_ADDITIONS*3))])
      );
    end
    if ((N==7)) begin
      mca_lut #(
        .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
        .NUM_ADDITIONS(N7_REST)
      ) mca_adder_stage_1_2 (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .operands_000(H_matrix_000[K/3-N7_REST-1+:N7_REST]),
        .operands_001(H_matrix_001[K/3-N7_REST-1+:N7_REST]),
        .operands_010(H_matrix_010[K/3-N7_REST-1+:N7_REST]),
        .operands_011(H_matrix_011[K/3-N7_REST-1+:N7_REST]),

        .operands_100(H_matrix_100[K/3-N7_REST-1+:N7_REST]),
        .operands_101(H_matrix_101[K/3-N7_REST-1+:N7_REST]),
        .operands_110(H_matrix_110[K/3-N7_REST-1+:N7_REST]),
        .operands_111(H_matrix_111[K/3-N7_REST-1+:N7_REST]),

        .S_values(S_matrix[K-1:K-N7_REST*3]),
        .enable(1'b1),
        .res(final_adder_input[(K/(MCA_NUM_ADDITIONS*3))])
      );
    end
    if ((N==8)) begin
      mca_lut #(
        .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
        .NUM_ADDITIONS(N8_REST)
      ) mca_adder_stage_1_2 (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .operands_000(H_matrix_000[K/3-N8_REST-1+:N8_REST]),
        .operands_001(H_matrix_001[K/3-N8_REST-1+:N8_REST]),
        .operands_010(H_matrix_010[K/3-N8_REST-1+:N8_REST]),
        .operands_011(H_matrix_011[K/3-N8_REST-1+:N8_REST]),

        .operands_100(H_matrix_100[K/3-N8_REST-1+:N8_REST]),
        .operands_101(H_matrix_101[K/3-N8_REST-1+:N8_REST]),
        .operands_110(H_matrix_110[K/3-N8_REST-1+:N8_REST]),
        .operands_111(H_matrix_111[K/3-N8_REST-1+:N8_REST]),

        .S_values(S_matrix[K-1:K-N8_REST*3]),
        .enable(1'b1),
        .res(final_adder_input[(K/(MCA_NUM_ADDITIONS*3))])
      );
    end

    for (stage_1 = ((K-1)/(MCA_NUM_ADDITIONS*3)+1); stage_1 < MCA_NUM_ADDITIONS; stage_1++) begin
      assign final_adder_input[stage_1] = '0;
    end
  endgenerate

// --------------------------------------------------------------------------
// -- Final addition
// --------------------------------------------------------------------------

  multi_clk_adder #(
    .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
    .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
  ) mca_adder_final (
    .clk(clk),
    .resetn(resetn),
    .start(start),
    .operands(final_adder_input),
    .enable(1'b1),
    .res(sample)
  );


endmodule

