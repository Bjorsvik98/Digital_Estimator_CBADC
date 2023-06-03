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

  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_000 [(K/3 + K%3)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_001 [(K/3 + K%3)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_010 [(K/3 + K%3)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_011 [(K/3 + K%3)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_100 [(K/3 + K%3)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_101 [(K/3 + K%3)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_110 [(K/3 + K%3)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_111 [(K/3 + K%3)-1:0][N-1:0],
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

logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_000 [N-1:0][(K/3 + K%3)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_001 [N-1:0][(K/3 + K%3)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_010 [N-1:0][(K/3 + K%3)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_011 [N-1:0][(K/3 + K%3)-1:0];

logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_100 [N-1:0][(K/3 + K%3)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_101 [N-1:0][(K/3 + K%3)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_110 [N-1:0][(K/3 + K%3)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_111 [N-1:0][(K/3 + K%3)-1:0];

logic S_matrix_restructured [N-1:0][K-1:0];

always_comb begin
  for (int i=0; i<N; i=i+1) begin
    for (int j=0; j<K; j=j+1) begin
      H_matrix_restructured_000[i][j] = H_matrix_000[j][i];
      H_matrix_restructured_001[i][j] = H_matrix_001[j][i];
      H_matrix_restructured_010[i][j] = H_matrix_010[j][i];
      H_matrix_restructured_011[i][j] = H_matrix_011[j][i];

      H_matrix_restructured_100[i][j] = H_matrix_100[j][i];
      H_matrix_restructured_101[i][j] = H_matrix_101[j][i];
      H_matrix_restructured_110[i][j] = H_matrix_110[j][i];
      H_matrix_restructured_111[i][j] = H_matrix_111[j][i];

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

      .H_matrix_000(H_matrix_restructured_000[i]),
      .H_matrix_001(H_matrix_restructured_001[i]),
      .H_matrix_010(H_matrix_restructured_010[i]),
      .H_matrix_011(H_matrix_restructured_011[i]),

      .H_matrix_100(H_matrix_restructured_100[i]),
      .H_matrix_101(H_matrix_restructured_101[i]),
      .H_matrix_110(H_matrix_restructured_110[i]),
      .H_matrix_111(H_matrix_restructured_111[i]),

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

