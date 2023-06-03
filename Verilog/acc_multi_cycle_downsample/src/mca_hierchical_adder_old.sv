`timescale 1 ns / 1 ps


// --------------------------------------------------------------------------
// -- Module calculating all FIR filter additions
// --------------------------------------------------------------------------

module mca_hierchical_adder import FIR_pkg::*; #(
  parameter K = 256,                  // Should be as low as possible, but still meet SNR requirements Can not be higher than 512 and must be multiple of 4
  parameter N = 8,                    // Between 3 and 8
  parameter WIDTH_COEFFICIENT=32,     // Max 32
  parameter MCA_NUM_ADDITIONS=16,     // Equal to lowest NUM_ADDER_STAGES where N*K < NUM_ADD_CLK**NUM_ADDER_STAGES
  parameter NUM_INPUTS_S3=2055,
  parameter NUM_INPUTS_S2=150,
  parameter NUM_INPUTS_S1=15,
  parameter NUM_S3_ADDERS=137,
  parameter NUM_S2_ADDERS=10,
  parameter NUM_S1_ADDERS=1
)(
  input clk,
  input resetn,

  input logic start,

  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix [K-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_neg [K-1:0][N-1:0],
  input logic [N-1:0] S_matrix [K-1:0],

  output logic signed [WIDTH_COEFFICIENT-1:0] sample
);


// --------------------------------------------------------------------------
// -- Local parameters
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// -- assignments
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// -- Signal declarations
// --------------------------------------------------------------------------
  
  logic signed [WIDTH_COEFFICIENT-1:0] adder_input_stage_3 [NUM_INPUTS_S3-1:0];

  logic signed [WIDTH_COEFFICIENT-1:0] adder_input_stage_2 [NUM_INPUTS_S2-1:0];

  logic signed [WIDTH_COEFFICIENT-1:0] adder_input_stage_1 [NUM_INPUTS_S1-1:0];

  logic signed [WIDTH_COEFFICIENT-1:0] final_adder_input [MCA_NUM_ADDITIONS-1:0];

// --------------------------------------------------------------------------
// -- Add/subtract logic for coefficients
// --------------------------------------------------------------------------
  always_comb begin
    for (int i = 0; i < K; i++) begin
      for (int j = 0; j < N; j++) begin
        adder_input_stage_3[i*N+j] = (S_matrix[i][j] == 1) ? H_matrix[K-i-1][j] : H_matrix_neg[K-i-1][j];
      end
    end
    for (int i = K*N; i < NUM_INPUTS_S3; i++) begin
      adder_input_stage_3[i] = 0;
    end
  end


// --------------------------------------------------------------------------
// -- Adder stage 3
// --------------------------------------------------------------------------

  genvar stage_3;
  generate
    for (stage_3 = 0; stage_3 < NUM_S3_ADDERS; stage_3++) begin : stage_3_generate
      multi_clk_adder #(
        .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
        .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
      ) mca_adder_stage_3 (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .operands(adder_input_stage_3[stage_3*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
        .enable(1'b1),
        .res(adder_input_stage_2[stage_3])
      );
    end
  endgenerate
  // Initialize rest of adder_input_stage_2 to 0
  always_comb begin
    for (int i = NUM_S3_ADDERS; i < NUM_INPUTS_S2; i++) begin
      adder_input_stage_2[i] = 0;
    end
  end

 


// --------------------------------------------------------------------------
// -- Adder stage 2
// --------------------------------------------------------------------------

  genvar stage_2;
  generate
    for (stage_2 = 0; stage_2 < NUM_S2_ADDERS; stage_2++) begin : stage_2_generate
      multi_clk_adder #(
        .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
        .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
      ) mca_adder_stage_2 (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .operands(adder_input_stage_2[stage_2*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
        .enable(1'b1),
        .res(adder_input_stage_1[stage_2])
      );
    end
  endgenerate
  // Initialize rest of adder_input_stage_1 to 0
  always_comb begin
    for (int i = NUM_S2_ADDERS; i < NUM_INPUTS_S1; i++) begin
      adder_input_stage_1[i] = 0;
    end
  end


// --------------------------------------------------------------------------
// -- Adder stage 1
// --------------------------------------------------------------------------

  genvar stage_1;
  generate
    for (stage_1 = 0; stage_1 < NUM_S1_ADDERS; stage_1++) begin : stage_1_generate
      multi_clk_adder #(
        .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
        .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
      ) mca_adder_stage_1 (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .operands(adder_input_stage_1[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
        .enable(1'b1),
        .res(final_adder_input[stage_1])
      );
    end
  endgenerate
  // Initialize rest of final_adder_input to 0
  always_comb begin
    for (int i = NUM_S1_ADDERS; i < MCA_NUM_ADDITIONS; i++) begin
      final_adder_input[i] = 0;
    end
  end

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

