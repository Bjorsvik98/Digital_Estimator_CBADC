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

  input logic signed [WIDTH_COEFFICIENT-1:0] H_matrix [K-1:0],
  input logic S_matrix [K-1:0],

  output logic signed [WIDTH_COEFFICIENT-1:0] sample
);


// --------------------------------------------------------------------------
// -- Local parameters
// --------------------------------------------------------------------------
localparam red_1 = 1;
localparam red_2 = 2;
localparam red_3 = 3;
localparam red_4 = 4;
localparam red_5 = 5;
localparam red_6 = 7;
localparam red_7 = 8;

localparam red_1_lim = 32;
localparam red_2_lim = 64;
localparam red_3_lim = 96;
localparam red_4_lim = 128;
localparam red_5_lim = 160;
localparam red_6_lim = 192;
localparam red_7_lim = 224;

// --------------------------------------------------------------------------
// -- Signal declarations
// --------------------------------------------------------------------------
logic signed [WIDTH_COEFFICIENT-red_7-1:0] H_matrix_red7 [2*(256-red_7_lim)-1:0];
logic S_matrix_red7 [2*(red_1_lim)-1:0];
logic signed [WIDTH_COEFFICIENT-red_6-1:0] H_matrix_red6 [2*(red_7_lim-red_6_lim)-1:0];
logic S_matrix_red6 [2*(red_1_lim)-1:0];
logic signed [WIDTH_COEFFICIENT-red_5-1:0] H_matrix_red5 [2*(red_6_lim-red_5_lim)-1:0];
logic S_matrix_red5 [2*(red_1_lim)-1:0];
logic signed [WIDTH_COEFFICIENT-red_4-1:0] H_matrix_red4 [2*(red_5_lim-red_4_lim)-1:0];
logic S_matrix_red4 [2*(red_1_lim)-1:0];
logic signed [WIDTH_COEFFICIENT-red_3-1:0] H_matrix_red3 [2*(red_4_lim-red_3_lim)-1:0];
logic S_matrix_red3 [2*(red_1_lim)-1:0];
logic signed [WIDTH_COEFFICIENT-red_2-1:0] H_matrix_red2 [2*(red_3_lim-red_2_lim)-1:0];
logic S_matrix_red2 [2*(red_1_lim)-1:0];
logic signed [WIDTH_COEFFICIENT-red_1-1:0] H_matrix_red1 [2*(red_2_lim-red_1_lim)-1:0];
logic S_matrix_red1 [2*(red_1_lim)-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] H_matrix_red0 [(2*red_1_lim)-1:0];
logic S_matrix_red0 [2*(red_1_lim)-1:0];

logic signed [WIDTH_COEFFICIENT-1:0] adder_input_stage_1 [32-1:0];
logic signed [WIDTH_COEFFICIENT-1:0] final_adder_input [MCA_NUM_ADDITIONS-1:0];

// --------------------------------------------------------------------------
// -- assignments
// --------------------------------------------------------------------------
genvar gv_red7, gv_red6, gv_red5, gv_red4, gv_red3, gv_red2, gv_red1, gv_red0;
generate
  if (K > 2*red_7_lim) begin
    for (gv_red7 = 0; gv_red7 < red_1_lim; gv_red7++) begin
      assign H_matrix_red7[gv_red7] = H_matrix[gv_red7][WIDTH_COEFFICIENT-red_7-1:0];
      assign S_matrix_red7[gv_red7] = S_matrix[gv_red7];
      assign H_matrix_red7[gv_red7+red_1_lim] = H_matrix[(K/2)+red_7_lim+gv_red7][WIDTH_COEFFICIENT-red_7-1:0];
      assign S_matrix_red7[gv_red7+red_1_lim] = S_matrix[(K/2)+red_7_lim+gv_red7];
    end
  end
  if (K > 2*red_6_lim) begin
    for (gv_red6 = 0; gv_red6 < red_1_lim; gv_red6++) begin
      assign H_matrix_red6[gv_red6] = H_matrix[(K/2)-red_7_lim+gv_red6][WIDTH_COEFFICIENT-red_6-1:0];
      assign S_matrix_red6[gv_red6] = S_matrix[(K/2)-red_7_lim+gv_red6];
      assign H_matrix_red6[gv_red6+red_1_lim] = H_matrix[(K/2)+red_6_lim+gv_red6][WIDTH_COEFFICIENT-red_6-1:0];
      assign S_matrix_red6[gv_red6+red_1_lim] = S_matrix[(K/2)+red_6_lim+gv_red6];
    end
  end 
  if (K > 2*red_5_lim) begin
    for (gv_red5 = 0; gv_red5 < red_1_lim; gv_red5++) begin
      assign H_matrix_red5[gv_red5] = H_matrix[(K/2)-red_6_lim+gv_red5][WIDTH_COEFFICIENT-red_5-1:0];
      assign S_matrix_red5[gv_red5] = S_matrix[(K/2)-red_6_lim+gv_red5];
      assign H_matrix_red5[gv_red5+red_1_lim] = H_matrix[(K/2)+red_5_lim+gv_red5][WIDTH_COEFFICIENT-red_5-1:0];
      assign S_matrix_red5[gv_red5+red_1_lim] = S_matrix[(K/2)+red_5_lim+gv_red5];
    end
  end
  if (K > 2*red_4_lim) begin
    for (gv_red4 = 0; gv_red4 < red_1_lim; gv_red4++) begin
      assign H_matrix_red4[gv_red4] = H_matrix[(K/2)-red_5_lim+gv_red4][WIDTH_COEFFICIENT-red_4-1:0];
      assign S_matrix_red4[gv_red4] = S_matrix[(K/2)-red_5_lim+gv_red4];
      assign H_matrix_red4[gv_red4+red_1_lim] = H_matrix[(K/2)+red_4_lim+gv_red4][WIDTH_COEFFICIENT-red_4-1:0];
      assign S_matrix_red4[gv_red4+red_1_lim] = S_matrix[(K/2)+red_4_lim+gv_red4];
    end
  end 
  if (K > 2*red_3_lim) begin
    for (gv_red3 = 0; gv_red3 < red_1_lim; gv_red3++) begin
      assign H_matrix_red3[gv_red3] = H_matrix[(K/2)-red_4_lim+gv_red3][WIDTH_COEFFICIENT-red_3-1:0];
      assign S_matrix_red3[gv_red3] = S_matrix[(K/2)-red_4_lim+gv_red3];
      assign H_matrix_red3[gv_red3+red_1_lim] = H_matrix[(K/2)+red_3_lim+gv_red3][WIDTH_COEFFICIENT-red_3-1:0];
      assign S_matrix_red3[gv_red3+red_1_lim] = S_matrix[(K/2)+red_3_lim+gv_red3];
    end
  end 
  if (K > 2*red_2_lim) begin
    for (gv_red2 = 0; gv_red2 < red_1_lim; gv_red2++) begin
      assign H_matrix_red2[gv_red2] = H_matrix[(K/2)-red_3_lim+gv_red2][WIDTH_COEFFICIENT-red_2-1:0];
      assign S_matrix_red2[gv_red2] = S_matrix[(K/2)-red_3_lim+gv_red2];
      assign H_matrix_red2[gv_red2+red_1_lim] = H_matrix[(K/2)+red_2_lim+gv_red2][WIDTH_COEFFICIENT-red_2-1:0];
      assign S_matrix_red2[gv_red2+red_1_lim] = S_matrix[(K/2)+red_2_lim+gv_red2];
    end
  end
  if (K > 2*red_1_lim) begin
    for (gv_red1 = 0; gv_red1 < red_1_lim; gv_red1++) begin
      assign H_matrix_red1[gv_red1] = H_matrix[(K/2)-red_2_lim+gv_red1][WIDTH_COEFFICIENT-red_1-1:0];
      assign S_matrix_red1[gv_red1] = S_matrix[(K/2)-red_2_lim+gv_red1];
      assign H_matrix_red1[gv_red1+red_1_lim] = H_matrix[(K/2)+red_1_lim+gv_red1][WIDTH_COEFFICIENT-red_1-1:0];
      assign S_matrix_red1[gv_red1+red_1_lim] = S_matrix[(K/2)+red_1_lim+gv_red1];
    end
  end
  if (K > 0) begin
    assign H_matrix_red0 = H_matrix[(K/2)+red_1_lim-1:(K/2)-red_1_lim];
    assign S_matrix_red0 = S_matrix[(K/2)+red_1_lim-1:(K/2)-red_1_lim];
  end
endgenerate

// --------------------------------------------------------------------------
// -- Adder stage 2
// --------------------------------------------------------------------------

  genvar stage_2_0;
  genvar stage_2_1;
  genvar stage_2_2;
  genvar stage_2_3;
  genvar stage_2_4;
  genvar stage_2_5;
  genvar stage_2_6;
  genvar stage_2_7;
  generate 
    for (stage_2_7 = 0; stage_2_7 < 4; stage_2_7++) begin
      if (K > 2*red_7_lim) begin
        mca_add_sub #(
          .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-red_7),
          .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
        ) mca_adder_stage_2_7 (
          .clk(clk),
          .resetn(resetn),
          .start(start),
          .enable(1'b1),
          .operands(H_matrix_red7[stage_2_7*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .S_values(S_matrix_red7[stage_2_7*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .res(adder_input_stage_1[stage_2_7+28][WIDTH_COEFFICIENT-red_7-1:0])
        );
        genvar gv_ext_red7;
        for (gv_ext_red7 = WIDTH_COEFFICIENT-red_7; gv_ext_red7 < WIDTH_COEFFICIENT; gv_ext_red7++) begin
          assign adder_input_stage_1[stage_2_7+28][gv_ext_red7] = adder_input_stage_1[stage_2_7+28][WIDTH_COEFFICIENT-red_7-1];
        end
      end else begin
        assign adder_input_stage_1[stage_2_7+28] = 0;
      end
    end
    for (stage_2_6 = 0; stage_2_6 < 4; stage_2_6++) begin
      if (K > 2*red_6_lim) begin
        mca_add_sub #(
          .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-red_6),
          .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
        ) mca_adder_stage_2_6 (
          .clk(clk),
          .resetn(resetn),
          .start(start),
          .enable(1'b1),
          .operands(H_matrix_red6[stage_2_6*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .S_values(S_matrix_red6[stage_2_6*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .res(adder_input_stage_1[stage_2_6+24][WIDTH_COEFFICIENT-red_6-1:0])
        );
        genvar gv_ext_red6;
        for (gv_ext_red6 = WIDTH_COEFFICIENT-red_6; gv_ext_red6 < WIDTH_COEFFICIENT; gv_ext_red6++) begin
          assign adder_input_stage_1[stage_2_6+24][gv_ext_red6] = adder_input_stage_1[stage_2_6+24][WIDTH_COEFFICIENT-red_6-1];
        end
      end else begin
        assign adder_input_stage_1[stage_2_6+24] = 0;
      end
    end
    for (stage_2_5 = 0; stage_2_5 < 4; stage_2_5++) begin
      if (K > 2*red_5_lim) begin
        mca_add_sub #(
          .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-red_5),
          .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
        ) mca_adder_stage_2_5 (
          .clk(clk),
          .resetn(resetn),
          .start(start),
          .enable(1'b1),
          .operands(H_matrix_red5[stage_2_5*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .S_values(S_matrix_red5[stage_2_5*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .res(adder_input_stage_1[stage_2_5+20][WIDTH_COEFFICIENT-red_5-1:0])
        );
        genvar gv_ext_red5;
        for (gv_ext_red5 = WIDTH_COEFFICIENT-red_5; gv_ext_red5 < WIDTH_COEFFICIENT; gv_ext_red5++) begin
          assign adder_input_stage_1[stage_2_5+20][gv_ext_red5] = adder_input_stage_1[stage_2_5+20][WIDTH_COEFFICIENT-red_5-1];
        end
      end else begin
        assign adder_input_stage_1[stage_2_5+20] = 0;
      end
    end
    for (stage_2_4 = 0; stage_2_4 < 4; stage_2_4++) begin
      if (K > 2*red_4_lim) begin
        mca_add_sub #(
          .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-red_4),
          .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
        ) mca_adder_stage_2_4 (
          .clk(clk),
          .resetn(resetn),
          .start(start),
          .enable(1'b1),
          .operands(H_matrix_red4[stage_2_4*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .S_values(S_matrix_red4[stage_2_4*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .res(adder_input_stage_1[stage_2_4+16][WIDTH_COEFFICIENT-red_4-1:0])
        );
        genvar gv_ext_red4;
        for (gv_ext_red4 = WIDTH_COEFFICIENT-red_4; gv_ext_red4 < WIDTH_COEFFICIENT; gv_ext_red4++) begin
          assign adder_input_stage_1[stage_2_4+16][gv_ext_red4] = adder_input_stage_1[stage_2_4+16][WIDTH_COEFFICIENT-red_4-1];
        end
      end else begin
        assign adder_input_stage_1[stage_2_4+16] = 0;
      end
    end
    for (stage_2_3 = 0; stage_2_3 < 4; stage_2_3++) begin
      if (K > 2*red_3_lim) begin
        mca_add_sub #(
          .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-red_3),
          .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
        ) mca_adder_stage_2_3 (
          .clk(clk),
          .resetn(resetn),
          .start(start),
          .enable(1'b1),
          .operands(H_matrix_red3[stage_2_3*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .S_values(S_matrix_red3[stage_2_3*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .res(adder_input_stage_1[stage_2_3+12][WIDTH_COEFFICIENT-red_3-1:0])
        );
        genvar gv_ext_red3;
        for (gv_ext_red3 = WIDTH_COEFFICIENT-red_3; gv_ext_red3 < WIDTH_COEFFICIENT; gv_ext_red3++) begin
          assign adder_input_stage_1[stage_2_3+12][gv_ext_red3] = adder_input_stage_1[stage_2_3+12][WIDTH_COEFFICIENT-red_3-1];
        end
      end else begin
        assign adder_input_stage_1[stage_2_3+12] = 0;
      end
    end
    for (stage_2_2 = 0; stage_2_2 < 4; stage_2_2++) begin
      if (K > 2*red_2_lim) begin
        mca_add_sub #(
          .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-red_2),
          .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
        ) mca_adder_stage_2_2 (
          .clk(clk),
          .resetn(resetn),
          .start(start),
          .enable(1'b1),
          .operands(H_matrix_red2[stage_2_2*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .S_values(S_matrix_red2[stage_2_2*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .res(adder_input_stage_1[stage_2_2+8][WIDTH_COEFFICIENT-red_2-1:0])
        );
        genvar gv_ext_red2;
        for (gv_ext_red2 = WIDTH_COEFFICIENT-red_2; gv_ext_red2 < WIDTH_COEFFICIENT; gv_ext_red2++) begin
          assign adder_input_stage_1[stage_2_2+8][gv_ext_red2] = adder_input_stage_1[stage_2_2+8][WIDTH_COEFFICIENT-red_2-1];
        end
      end
    end
    for (stage_2_1 = 0; stage_2_1 < 4; stage_2_1++) begin
      if (K > 2*red_1_lim) begin
        mca_add_sub #(
          .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT-red_1),
          .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
        ) mca_adder_stage_2_1 (
          .clk(clk),
          .resetn(resetn),
          .start(start),
          .enable(1'b1),
          .operands(H_matrix_red1[stage_2_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .S_values(S_matrix_red1[stage_2_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .res(adder_input_stage_1[stage_2_1+4][WIDTH_COEFFICIENT-red_1-1:0])
        );
        genvar gv_ext_red1;
        for (gv_ext_red1 = WIDTH_COEFFICIENT-red_1; gv_ext_red1 < WIDTH_COEFFICIENT; gv_ext_red1++) begin
          assign adder_input_stage_1[stage_2_1+4][gv_ext_red1] = adder_input_stage_1[stage_2_1+4][WIDTH_COEFFICIENT-red_1-1];
        end
      end else begin
        assign adder_input_stage_1[stage_2_1+4] = 0;
      end
    end
    for (stage_2_0 = 0; stage_2_0 < 4; stage_2_0++) begin
      if (K > 0) begin
        mca_add_sub #(
          .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
          .NUM_ADDITIONS(MCA_NUM_ADDITIONS)
        ) mca_adder_stage_2_0 (
          .clk(clk),
          .resetn(resetn),
          .start(start),
          .enable(1'b1),
          .operands(H_matrix_red0[stage_2_0*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .S_values(S_matrix_red0[stage_2_0*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
          .res(adder_input_stage_1[stage_2_0][WIDTH_COEFFICIENT-1:0])
        );
      end
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
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .operands(adder_input_stage_1[stage_1*MCA_NUM_ADDITIONS+:MCA_NUM_ADDITIONS]),
        .enable(1'b1),
        .res(final_adder_input[stage_1])
      );
    end
    for (stage_1 = 2; stage_1 < MCA_NUM_ADDITIONS; stage_1++) begin
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

