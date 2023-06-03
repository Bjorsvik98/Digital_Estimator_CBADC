`timescale 1 ns / 1 ps


// --------------------------------------------------------------------------
// -- Module calculating all FIR filter additions
// --------------------------------------------------------------------------

module mca_hierchical_adder import FIR_pkg::*; #(
  parameter K = 256,                  // Should be as low as possible, but still meet SNR requirements Can not be higher than 512 and must be multiple of 4
  parameter N = 8,                    // Between 3 and 8
  parameter WIDTH_COEFFICIENT=32,         // Max 32
  parameter MCA_NUM_ADDITIONS=16,         // Equal to lowest NUM_ADDER_STAGES where N*K < NUM_ADD_CLK**NUM_ADDER_STAGES
  parameter reduce_AS1 = 2,
  parameter reduce_AS2 = 4,
  parameter reduce_AS3 = 6,
  parameter reduce_AS4 = 8,
  parameter reduce_AS5 = 10,
  parameter reduce_AS6 = 12,
  parameter reduce_AS7 = 14


)(
  input clk,
  input resetn,

  input logic start,

  input logic signed  [WIDTH_COEFFICIENT-1:0]     H_matrix_AS0  [K-1:0],
  input logic signed  [WIDTH_COEFFICIENT-reduce_AS1-1:0]   H_matrix_AS1  [K-1:0],
  input logic signed  [WIDTH_COEFFICIENT-reduce_AS2-1:0]   H_matrix_AS2  [K-1:0],
  input logic signed  [WIDTH_COEFFICIENT-reduce_AS3-1:0]   H_matrix_AS3  [K-1:0],
  input logic signed  [WIDTH_COEFFICIENT-reduce_AS4-1:0]   H_matrix_AS4  [K-1:0],
  input logic signed  [WIDTH_COEFFICIENT-reduce_AS5-1:0]  H_matrix_AS5  [K-1:0],
  input logic signed  [WIDTH_COEFFICIENT-reduce_AS6-1:0]  H_matrix_AS6  [K-1:0],
  input logic signed  [WIDTH_COEFFICIENT-reduce_AS7-1:0]  H_matrix_AS7  [K-1:0],
  input logic         [N-1:0]                     S_matrix      [K-1:0],

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

logic S_matrix_restructured [N-1:0][K-1:0];

always_comb begin
  for (int i=0; i<N; i=i+1) begin
    for (int j=0; j<K; j=j+1) begin
      S_matrix_restructured[i][K-j-1] = S_matrix[j][i];
    end
  end
end

// --------------------------------------------------------------------------
// -- Making a mca_single_as adder for each analog state
// --------------------------------------------------------------------------
generate
  mca_single_as #(
    .K(K),
    .N(N),
    .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
    .MCA_NUM_ADDITIONS(MCA_NUM_ADDITIONS)
  ) mca_single_as0 (
    .clk(clk),
    .resetn(resetn),
    .start(start),
    .H_matrix(H_matrix_AS0),
    .S_matrix(S_matrix_restructured[0]),    
    .sample(single_as_result[0])
  );
  mca_single_as #(
    .K(K),
    .N(N),
    .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-reduce_AS1),
    .MCA_NUM_ADDITIONS(MCA_NUM_ADDITIONS)
  ) mca_single_as1 (
    .clk(clk),
    .resetn(resetn),
    .start(start),
    .H_matrix(H_matrix_AS1),
    .S_matrix(S_matrix_restructured[1]),    
    .sample(single_as_result[1][WIDTH_COEFFICIENT-reduce_AS1-1:0])
  );
  genvar as1;
  for (as1=WIDTH_COEFFICIENT-reduce_AS1; as1<WIDTH_COEFFICIENT; as1++) begin
    assign single_as_result[1][as1] = single_as_result[1][WIDTH_COEFFICIENT-reduce_AS1-1];
  end
  mca_single_as #(
    .K(K),
    .N(N),
    .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-reduce_AS2),
    .MCA_NUM_ADDITIONS(MCA_NUM_ADDITIONS)
  ) mca_single_as2 (
    .clk(clk),
    .resetn(resetn),
    .start(start),
    .H_matrix(H_matrix_AS2),
    .S_matrix(S_matrix_restructured[2]),    
    .sample(single_as_result[2][WIDTH_COEFFICIENT-reduce_AS2-1:0])
  );
  genvar as2;
  for (as2=WIDTH_COEFFICIENT-reduce_AS2; as2<WIDTH_COEFFICIENT; as2++) begin
    assign single_as_result[2][as2] = single_as_result[2][WIDTH_COEFFICIENT-reduce_AS2-1];
  end
  if (N > 3) begin
    mca_single_as #(
      .K(K),
      .N(N),
      .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-reduce_AS3),
      .MCA_NUM_ADDITIONS(MCA_NUM_ADDITIONS)
    ) mca_single_as3 (
      .clk(clk),
      .resetn(resetn),
      .start(start),
      .H_matrix(H_matrix_AS3),
      .S_matrix(S_matrix_restructured[3]),    
      .sample(single_as_result[3][WIDTH_COEFFICIENT-reduce_AS3-1:0])
    );
    genvar as3;
    for (as3=WIDTH_COEFFICIENT-reduce_AS3; as3<WIDTH_COEFFICIENT; as3++) begin
      assign single_as_result[3][as3] = single_as_result[3][WIDTH_COEFFICIENT-reduce_AS3-1];
    end
  end
  if (N > 4) begin
    mca_single_as #(
      .K(K),
      .N(N),
      .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-reduce_AS4),
      .MCA_NUM_ADDITIONS(MCA_NUM_ADDITIONS)
    ) mca_single_as4 (
      .clk(clk),
      .resetn(resetn),
      .start(start),
      .H_matrix(H_matrix_AS4),
      .S_matrix(S_matrix_restructured[4]),    
      .sample(single_as_result[4][WIDTH_COEFFICIENT-reduce_AS4-1:0])
    );
    genvar as4;
    for (as4=WIDTH_COEFFICIENT-reduce_AS4; as4<WIDTH_COEFFICIENT; as4++) begin
      assign single_as_result[4][as4] = single_as_result[4][WIDTH_COEFFICIENT-reduce_AS4-1];
    end
  end
  if (N > 5) begin
    mca_single_as #(
      .K(K),
      .N(N),
      .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-reduce_AS5),
      .MCA_NUM_ADDITIONS(MCA_NUM_ADDITIONS)
    ) mca_single_as5 (
      .clk(clk),
      .resetn(resetn),
      .start(start),
      .H_matrix(H_matrix_AS5),
      .S_matrix(S_matrix_restructured[5]),    
      .sample(single_as_result[5][WIDTH_COEFFICIENT-reduce_AS5-1:0])
    );
    genvar as5;
    for (as5=WIDTH_COEFFICIENT-reduce_AS5; as5<WIDTH_COEFFICIENT; as5++) begin
      assign single_as_result[5][as5] = single_as_result[5][WIDTH_COEFFICIENT-reduce_AS5-1];
    end
  end
  if (N > 6) begin
    mca_single_as #(
      .K(K),
      .N(N),
      .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-reduce_AS6),
      .MCA_NUM_ADDITIONS(MCA_NUM_ADDITIONS)
    ) mca_single_as6 (
      .clk(clk),
      .resetn(resetn),
      .start(start),
      .H_matrix(H_matrix_AS6),
      .S_matrix(S_matrix_restructured[6]),    
      .sample(single_as_result[6][WIDTH_COEFFICIENT-reduce_AS6-1:0])
    );
    genvar as6;
    for (as6=WIDTH_COEFFICIENT-reduce_AS6; as6<WIDTH_COEFFICIENT; as6++) begin
      assign single_as_result[6][as6] = single_as_result[6][WIDTH_COEFFICIENT-reduce_AS6-1];
    end
  end
  if (N > 7) begin
    mca_single_as #(
      .K(K),
      .N(N),
      .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-reduce_AS7),
      .MCA_NUM_ADDITIONS(MCA_NUM_ADDITIONS)
    ) mca_single_as7 (
      .clk(clk),
      .resetn(resetn),
      .start(start),
      .H_matrix(H_matrix_AS7),
      .S_matrix(S_matrix_restructured[7]),    
      .sample(single_as_result[7][WIDTH_COEFFICIENT-reduce_AS7-1:0])
    );
    genvar as7;
    for (as7=WIDTH_COEFFICIENT-reduce_AS7; as7<WIDTH_COEFFICIENT; as7++) begin
      assign single_as_result[7][as7] = single_as_result[7][WIDTH_COEFFICIENT-reduce_AS7-1];
    end
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

