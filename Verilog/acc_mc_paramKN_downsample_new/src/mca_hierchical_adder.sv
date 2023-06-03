`timescale 1 ns / 1 ps


// --------------------------------------------------------------------------
// -- Module calculating all FIR filter additions
// --------------------------------------------------------------------------

module mca_hierchical_adder import FIR_pkg::*; #(
  parameter K_MAX = 256,                  // Should be as low as possible, but still meet SNR requirements Can not be higher than 512 and must be multiple of 4
  parameter N_MAX = 8,                    // Between 3 and 8
  parameter WIDTH_COEFFICIENT=32,         // Max 32
  parameter MCA_NUM_ADDITIONS=16          // Equal to lowest NUM_ADDER_STAGES where N*K < NUM_ADD_CLK**NUM_ADDER_STAGES
)(
  input clk,
  input resetn,
  input logic [N_MAX-1:0] N,
  input logic [K_MAX/MCA_NUM_ADDITIONS-1:0] K,

  input logic start,

  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix [K_MAX-1:0][N_MAX-1:0],
  input logic [N_MAX-1:0] S_matrix [K_MAX-1:0],

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
logic signed [WIDTH_COEFFICIENT-1:0] single_as_result [N_MAX-1:0];

logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_restructured [N_MAX-1:0][K_MAX-1:0];
logic S_matrix_restructured [N_MAX-1:0][K_MAX-1:0];

always_comb begin
  for (int i=0; i<N_MAX; i=i+1) begin
    for (int j=0; j<K_MAX; j=j+1) begin
      H_matrix_restructured[i][j] = H_matrix[j][i];
      S_matrix_restructured[i][K_MAX-j-1] = S_matrix[j][i];
    end
  end
end

// --------------------------------------------------------------------------
// -- Making a mca_single_as adder for each analog state
// --------------------------------------------------------------------------
genvar i; 
generate
  for (i=0; i<N_MAX; i=i+1) begin
    mca_single_as #(
      .K_MAX(K_MAX),
      .N_MAX(N_MAX),
      .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
      .MCA_NUM_ADDITIONS(MCA_NUM_ADDITIONS)
    ) mca_single_as (
      .clk(clk),
      .resetn(resetn),

      .start(start),
      .K(K),

      .H_matrix(H_matrix_restructured[i]),
      .S_matrix(S_matrix_restructured[i]),
      .enable_N(N[i]),
      
      .sample(single_as_result[i])
    );
  end
endgenerate

// --------------------------------------------------------------------------
// -- Final addition
// --------------------------------------------------------------------------

  multi_clk_adder #(
    .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
    .NUM_ADDITIONS(N_MAX)
  ) mca_adder_final (
    .clk(clk),
    .resetn(resetn),
    .start(start),
    .operands(single_as_result),
    .enable(1'b1),
    .res(sample)
  );


endmodule

