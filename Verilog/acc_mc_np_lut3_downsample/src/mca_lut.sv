`timescale 1 ns / 1 ps

// --------------------------------------------------------------------------
// -- Module for completing multiple additions in multiple clock cycles
// --------------------------------------------------------------------------

module mca_lut import FIR_pkg::*; #(
  parameter WIDTH_COEFFICIENT = 32,
  parameter NUM_ADDITIONS = 16
)
(
  input clk,
  input resetn,
  input start,
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_000 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_001 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_010 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_011 [NUM_ADDITIONS-1:0],

  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_100 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_101 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_110 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_111 [NUM_ADDITIONS-1:0],

  input logic S_values [NUM_ADDITIONS*3-1:0],
  input logic enable,
  output logic signed [WIDTH_COEFFICIENT-1:0] res
);

localparam MAX_NUM_ADDITIONS = 16;

logic signed [WIDTH_COEFFICIENT-1:0] imm_res_reg;
logic signed [WIDTH_COEFFICIENT-1:0] res_reg;

state_mca_e state, next_state;
logic [3:0] counter;
logic [6:0] counter_three;

logic [NUM_ADDITIONS*3-1:0] S_val_packed;

// --------------------------------------------------------------------------
// -- Assignments
// --------------------------------------------------------------------------
assign res = res_reg;
assign counter_three = {counter, 1'b0} + counter;


// --------------------------------------------------------------------------
// -- state machine
// --------------------------------------------------------------------------

always_comb begin
  for (int i = 0; i < 3*NUM_ADDITIONS; i++) begin
    S_val_packed[i] = S_values[i];
  end
end

always_comb begin
  next_state = state;
  case (state)
    MCA_IDLE: begin
      if (start) next_state = MCA_ADDING;
      else next_state = MCA_IDLE;
    end
    MCA_ADDING: begin
      if (counter == MAX_NUM_ADDITIONS-1) next_state = MCA_IDLE;
      else next_state = MCA_ADDING;
    end
  endcase
end

always_ff @(posedge clk or negedge resetn) begin
  if (!resetn) state <= MCA_IDLE;
  else if(enable) state <= next_state;
end
always_ff @(posedge clk or negedge resetn) begin
  if (!resetn) counter <= 0;
  else if (enable && state == MCA_ADDING && counter == (MAX_NUM_ADDITIONS-1)) counter <= 5'b0;
  else if (enable && state == MCA_ADDING) counter <= counter + 1;
end


// --------------------------------------------------------------------------
// -- adder
// --------------------------------------------------------------------------
always_ff @(posedge clk or negedge resetn) begin
  if (!resetn) imm_res_reg <= 0;
  // else if (enable && state == MCA_ADDING && counter < NUM_ADDITIONS-1) imm_res_reg <= (S_values[counter] == 1'b1) ? imm_res_reg + operands[counter] : imm_res_reg - operands[counter];
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b000)) imm_res_reg <= $signed(imm_res_reg + operands_000[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b001)) imm_res_reg <= $signed(imm_res_reg + operands_001[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b010)) imm_res_reg <= $signed(imm_res_reg + operands_010[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b011)) imm_res_reg <= $signed(imm_res_reg + operands_011[counter]);

  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b100)) imm_res_reg <= $signed(imm_res_reg + operands_100[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b101)) imm_res_reg <= $signed(imm_res_reg + operands_101[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b110)) imm_res_reg <= $signed(imm_res_reg + operands_110[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b111)) imm_res_reg <= $signed(imm_res_reg + operands_111[counter]);

  else if (enable && (counter == (MAX_NUM_ADDITIONS-1))) imm_res_reg <= 0;
end
always_ff @(posedge clk or negedge resetn) begin
  if (!resetn) res_reg <= 0;
  // else if (enable && state == MCA_ADDING && counter == MAX_NUM_ADDITIONS-1 && (MAX_NUM_ADDITIONS == NUM_ADDITIONS)) res_reg <= (S_values[NUM_ADDITIONS-1] == 1'b1) ? imm_res_reg + operands[NUM_ADDITIONS-1] : imm_res_reg - operands[NUM_ADDITIONS-1];
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(3*(NUM_ADDITIONS-1))+:3] == 3'b000)) res_reg <= $signed(imm_res_reg + operands_000[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(3*(NUM_ADDITIONS-1))+:3] == 3'b001)) res_reg <= $signed(imm_res_reg + operands_001[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(3*(NUM_ADDITIONS-1))+:3] == 3'b010)) res_reg <= $signed(imm_res_reg + operands_010[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(3*(NUM_ADDITIONS-1))+:3] == 3'b011)) res_reg <= $signed(imm_res_reg + operands_011[NUM_ADDITIONS-1]);

  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(3*(NUM_ADDITIONS-1))+:3] == 3'b100)) res_reg <= $signed(imm_res_reg + operands_100[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(3*(NUM_ADDITIONS-1))+:3] == 3'b101)) res_reg <= $signed(imm_res_reg + operands_101[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(3*(NUM_ADDITIONS-1))+:3] == 3'b110)) res_reg <= $signed(imm_res_reg + operands_110[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(3*(NUM_ADDITIONS-1))+:3] == 3'b111)) res_reg <= $signed(imm_res_reg + operands_111[NUM_ADDITIONS-1]);

  // else if (enable && state == MCA_ADDING && counter == MAX_NUM_ADDITIONS-1) res_reg <= (S_values[NUM_ADDITIONS-1] == 1'b1) ? imm_res_reg + operands[NUM_ADDITIONS-1] : imm_res_reg - operands[NUM_ADDITIONS-1];
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b000)) res_reg <= $signed(imm_res_reg + operands_000[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b001)) res_reg <= $signed(imm_res_reg + operands_001[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b010)) res_reg <= $signed(imm_res_reg + operands_010[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b011)) res_reg <= $signed(imm_res_reg + operands_011[NUM_ADDITIONS-1]);

  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b100)) res_reg <= $signed(imm_res_reg + operands_100[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b101)) res_reg <= $signed(imm_res_reg + operands_101[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b110)) res_reg <= $signed(imm_res_reg + operands_110[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_three+:3] == 3'b111)) res_reg <= $signed(imm_res_reg + operands_111[NUM_ADDITIONS-1]);
end

endmodule