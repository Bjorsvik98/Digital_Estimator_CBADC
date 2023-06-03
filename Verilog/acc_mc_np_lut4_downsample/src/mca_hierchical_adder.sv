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

  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_0000 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_0001 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_0010 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_0011 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_0100 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_0101 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_0110 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_0111 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_1000 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_1001 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_1010 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_1011 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_1100 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_1101 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_1110 [(K/4)-1:0][N-1:0],
  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_1111 [(K/4)-1:0][N-1:0],
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

logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_0000 [N-1:0][(K/4)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_0001 [N-1:0][(K/4)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_0010 [N-1:0][(K/4)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_0011 [N-1:0][(K/4)-1:0];

logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_0100 [N-1:0][(K/4)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_0101 [N-1:0][(K/4)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_0110 [N-1:0][(K/4)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_0111 [N-1:0][(K/4)-1:0];


logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_1000 [N-1:0][(K/4)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_1001 [N-1:0][(K/4)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_1010 [N-1:0][(K/4)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_1011 [N-1:0][(K/4)-1:0];

logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_1100 [N-1:0][(K/4)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_1101 [N-1:0][(K/4)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_1110 [N-1:0][(K/4)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured_1111 [N-1:0][(K/4)-1:0];

logic S_matrix_restructured [N-1:0][K-1:0];

always_comb begin
  for (int i=0; i<N; i=i+1) begin
    for (int j=0; j<K; j=j+1) begin
      H_matrix_restructured_0000[i][j] = H_matrix_0000[j][i];
      H_matrix_restructured_0001[i][j] = H_matrix_0001[j][i];
      H_matrix_restructured_0010[i][j] = H_matrix_0010[j][i];
      H_matrix_restructured_0011[i][j] = H_matrix_0011[j][i];

      H_matrix_restructured_0100[i][j] = H_matrix_0100[j][i];
      H_matrix_restructured_0101[i][j] = H_matrix_0101[j][i];
      H_matrix_restructured_0110[i][j] = H_matrix_0110[j][i];
      H_matrix_restructured_0111[i][j] = H_matrix_0111[j][i];

      H_matrix_restructured_1000[i][j] = H_matrix_1000[j][i];
      H_matrix_restructured_1001[i][j] = H_matrix_1001[j][i];
      H_matrix_restructured_1010[i][j] = H_matrix_1010[j][i];
      H_matrix_restructured_1011[i][j] = H_matrix_1011[j][i];

      H_matrix_restructured_1100[i][j] = H_matrix_1100[j][i];
      H_matrix_restructured_1101[i][j] = H_matrix_1101[j][i];
      H_matrix_restructured_1110[i][j] = H_matrix_1110[j][i];
      H_matrix_restructured_1111[i][j] = H_matrix_1111[j][i];

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

      .H_matrix_0000(H_matrix_restructured_0000[i]),
      .H_matrix_0001(H_matrix_restructured_0001[i]),
      .H_matrix_0010(H_matrix_restructured_0010[i]),
      .H_matrix_0011(H_matrix_restructured_0011[i]),

      .H_matrix_0100(H_matrix_restructured_0100[i]),
      .H_matrix_0101(H_matrix_restructured_0101[i]),
      .H_matrix_0110(H_matrix_restructured_0110[i]),
      .H_matrix_0111(H_matrix_restructured_0111[i]),

      .H_matrix_1000(H_matrix_restructured_1000[i]),
      .H_matrix_1001(H_matrix_restructured_1001[i]),
      .H_matrix_1010(H_matrix_restructured_1010[i]),
      .H_matrix_1011(H_matrix_restructured_1011[i]),

      .H_matrix_1100(H_matrix_restructured_1100[i]),
      .H_matrix_1101(H_matrix_restructured_1101[i]),
      .H_matrix_1110(H_matrix_restructured_1110[i]),
      .H_matrix_1111(H_matrix_restructured_1111[i]),

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

