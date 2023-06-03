`timescale 1 ns / 1 ps


// --------------------------------------------------------------------------
// -- Module calculating all FIR filter additions
// --------------------------------------------------------------------------

module mca_single_as import FIR_pkg::*; #(
  parameter K_MAX = 512,                  // Should be as low as possible, but still meet SNR requirements Can not be higher than 512 and must be multiple of 4
  parameter N_MAX = 8,                    //
  parameter WIDTH_COEFFICIENT=32,     // Max 32
  parameter MCA_NUM_ADDITIONS=16      // Equal to lowest NUM_ADDER_STAGES where N*K < NUM_ADD_CLK**NUM_ADDER_STAGES

)(
  input clk,
  input resetn,

  input logic start,
  input logic [K_MAX/MCA_NUM_ADDITIONS-1:0] K,

  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix [K_MAX-1:0],
  input logic S_matrix [K_MAX-1:0],
  input logic enable_N,

  output logic signed [WIDTH_COEFFICIENT-1:0] sample
);


// --------------------------------------------------------------------------
// -- Local parameters
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// -- Signal declarations
// --------------------------------------------------------------------------

logic enable_adder [K_MAX/MCA_NUM_ADDITIONS-1:0];
  
// --------------------------------------------------------------------------
// -- assignments
// --------------------------------------------------------------------------
for (genvar i = 0; i < K_MAX/MCA_NUM_ADDITIONS; i++) begin
  assign enable_adder[i] = enable_N & (K[i] == 1);
end

logic signed [WIDTH_COEFFICIENT-1:0] adder_input_stage_1 [32-1:0];

logic signed [WIDTH_COEFFICIENT-1:0] final_adder_input [1:0];


// --------------------------------------------------------------------------
// -- Adder stage 2
// --------------------------------------------------------------------------

  genvar stage_2;
  generate
    for (stage_2 = 0; stage_2 < (K_MAX/MCA_NUM_ADDITIONS); stage_2++) begin : stage_2_generate
      mca_add_sub #(
        .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
        .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
      ) mca_adder_stage_2 (
        .clk(clk & enable_adder[stage_2]),
        .resetn(resetn),
        .start(start),
        .operands(H_matrix[stage_2*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
        .S_values(S_matrix[stage_2*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
        .enable(enable_adder[stage_2]),
        .res(adder_input_stage_1[stage_2])
      );
    end
    for (stage_2 = K_MAX/MCA_NUM_ADDITIONS; stage_2 < 32; stage_2++) begin : stage_2_set0
      assign adder_input_stage_1[stage_2] = '0;
    end
  endgenerate

// --------------------------------------------------------------------------
// -- Adder stage 1
// --------------------------------------------------------------------------

  genvar stage_1;
  generate
    for (stage_1 = 0; stage_1 < 2; stage_1++) begin : stage_1_generate
      multi_clk_adder #(
        .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
        .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
      ) mca_adder_stage_1 (
        .clk(clk & enable_N),
        .resetn(resetn),
        .start(start),
        .operands(adder_input_stage_1[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
        .enable(enable_N),
        .res(final_adder_input[stage_1])
      );
    end
  endgenerate

// --------------------------------------------------------------------------
// -- Final addition
// --------------------------------------------------------------------------

  multi_clk_adder #(
    .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
    .NUM_ADDITIONS(2)
  ) mca_adder_final (
    .clk(clk),
    .resetn(resetn),
    .start(start),
    .operands(final_adder_input),
    .enable(enable_N),
    .res(sample)
  );


endmodule

