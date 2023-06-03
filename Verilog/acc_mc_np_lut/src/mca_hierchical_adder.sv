`timescale 1 ns / 1 ps


// --------------------------------------------------------------------------
// -- Module calculating all FIR filter additions
// --------------------------------------------------------------------------

module mca_hierchical_adder import FIR_pkg::*; #(
  parameter K = 256,                  // Should be as low as possible, but still meet SNR requirements Can not be higher than 512 and must be multiple of 4
  parameter N = 8,                    // Between 3 and 8
  parameter WIDTH_COEFFICIENT=32,         // Max 32
  parameter MCA_NUM_ADDITIONS=16          // Equal to lowest NUM_ADDER_STAGES where N*K < NUM_ADD_CLK**NUM_ADDER_STAGES
)(
  input clk,
  input resetn,

  input logic start,

  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_00 [(K/2)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_01 [(K/2)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_10 [(K/2)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_11 [(K/2)-1:0][N-1:0],
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
logic signed [WIDTH_COEFFICIENT-1:0] single_as_result [N-1:0];

logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_00 [N-1:0][(K/2)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_01 [N-1:0][(K/2)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_10 [N-1:0][(K/2)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_11 [N-1:0][(K/2)-1:0];
logic S_matrix_restructured [N-1:0][K-1:0];

always_comb begin
  for (int i=0; i<N; i=i+1) begin
    for (int j=0; j<K; j=j+1) begin
      H_matrix_restructured_00[i][j] = H_matrix_00[j][i];
      H_matrix_restructured_01[i][j] = H_matrix_01[j][i];
      H_matrix_restructured_10[i][j] = H_matrix_10[j][i];
      H_matrix_restructured_11[i][j] = H_matrix_11[j][i];
      S_matrix_restructured[i][K-j-1] = S_matrix[j][i];
    end
  end
end


// --------------------------------------------------------------------------
// -- Making a mca_single_as adder for each analog state
// --------------------------------------------------------------------------
genvar i; 
generate
  for (i=0; i<N; i=i+1) begin
    mca_single_as #(
      .K(K),
      .N(N),
      .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
      .MCA_NUM_ADDITIONS(MCA_NUM_ADDITIONS)
    ) mca_single_as (
      .clk(clk),
      .resetn(resetn),
      .start(start),

      .H_matrix_00(H_matrix_restructured_00[i]),
      .H_matrix_01(H_matrix_restructured_01[i]),
      .H_matrix_10(H_matrix_restructured_10[i]),
      .H_matrix_11(H_matrix_restructured_11[i]),
      .S_matrix(S_matrix_restructured[i]),    

      .sample(single_as_result[i])
    );
  end
endgenerate

// --------------------------------------------------------------------------
// -- Final addition
// --------------------------------------------------------------------------

  multi_clk_adder #(
    .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
    .NUM_ADDITIONS(N)
  ) mca_adder_final (
    .clk(clk),
    .resetn(resetn),
    .start(start),
    .operands(single_as_result),
    .enable(1'b1),
    .res(sample)
  );


endmodule

