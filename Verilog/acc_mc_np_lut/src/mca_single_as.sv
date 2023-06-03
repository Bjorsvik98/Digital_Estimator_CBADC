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

  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_00 [(K/2)-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_01 [(K/2)-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_10 [(K/2)-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_11 [(K/2)-1:0],
  input logic S_matrix [K-1:0],

  output logic signed [WIDTH_COEFFICIENT-1:0] sample
);


// --------------------------------------------------------------------------
// -- Local parameters
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// -- Signal declarations
// --------------------------------------------------------------------------

logic signed [WIDTH_COEFFICIENT-1:0] adder_input_stage_1 [(MCA_NUM_ADDITIONS*2)-1:0];

logic signed [WIDTH_COEFFICIENT-1:0] final_adder_input [MCA_NUM_ADDITIONS-1:0];
  
// --------------------------------------------------------------------------
// -- assignments
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// -- Adder stage 2
// --------------------------------------------------------------------------

  // genvar stage_2;
  // generate
  //   if ((K/(2*MCA_NUM_ADDITIONS)) > MCA_NUM_ADDITIONS) begin
  //     for (stage_2 = 0; stage_2 < (K/(MCA_NUM_ADDITIONS*2)); stage_2++) begin : stage_2_generate
  //       mca_lut #(
  //         .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
  //         .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
  //       ) mca_adder_stage_2 (
  //         .clk(clk),
  //         .resetn(resetn),
  //         .start(start),
  //         .operands_00(H_matrix_00[stage_2*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
  //         .operands_01(H_matrix_01[stage_2*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
  //         .operands_10(H_matrix_10[stage_2*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
  //         .operands_11(H_matrix_11[stage_2*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
  //         .S_values(S_matrix[2*stage_2*MCA_NUM_ADDITIONS+:2*MCA_NUM_ADDITIONS]),
  //         .enable(1'b1),
  //         .res(adder_input_stage_1[stage_2])
  //       );
  //     end
  //     for (stage_2 = (K/(MCA_NUM_ADDITIONS*2)); stage_2 < 2*MCA_NUM_ADDITIONS; stage_2++) begin
  //       assign adder_input_stage_1[stage_2] = '0;
  //     end
  //   end
  // endgenerate


// --------------------------------------------------------------------------
// -- Adder stage 1
// --------------------------------------------------------------------------

  genvar stage_1;
  generate
    // if ((K/MCA_NUM_ADDITIONS) < MCA_NUM_ADDITIONS+1) begin
      for (stage_1 = 0; stage_1 < (K/(MCA_NUM_ADDITIONS*2)); stage_1++) begin : stage_1_generate
        mca_lut #(
          .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
          .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
        ) mca_adder_stage_1 (
          .clk(clk),
          .resetn(resetn),
          .start(start),
          .operands_00(H_matrix_00[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .operands_01(H_matrix_01[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .operands_10(H_matrix_10[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .operands_11(H_matrix_11[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .S_values(S_matrix[2*stage_1*MCA_NUM_ADDITIONS+:2*MCA_NUM_ADDITIONS]),
          .enable(1'b1),
          .res(final_adder_input[stage_1])
        );
      end
      for (stage_1 = (K/(MCA_NUM_ADDITIONS*2)); stage_1 < MCA_NUM_ADDITIONS; stage_1++) begin
        assign final_adder_input[stage_1] = '0;
      end
    // end
    // else begin
    //   for (stage_1 = 0; stage_1 < 2; stage_1++) begin : stage_1_second_generate
    //     multi_clk_adder #(
    //       .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
    //       .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
    //     ) mca_adder_stage_1 (
    //       .clk(clk),
    //       .resetn(resetn),
    //       .start(start),
    //       .operands(adder_input_stage_1[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
    //       .enable(1'b1),
    //       .res(final_adder_input[stage_1])
    //     );
    //   end
    //   for (stage_1 = 2; stage_1 < MCA_NUM_ADDITIONS+1; stage_1++) begin
    //     assign final_adder_input[stage_1] = '0;
    //   end
    // end
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

