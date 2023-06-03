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
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_00 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_01 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_10 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_11 [NUM_ADDITIONS-1:0],
  input logic S_values [NUM_ADDITIONS*2-1:0],
  input logic enable,
  output logic signed [WIDTH_COEFFICIENT-1:0] res
);

localparam MAX_NUM_ADDITIONS = 16;

logic signed [WIDTH_COEFFICIENT-1:0] imm_res_reg;
logic signed [WIDTH_COEFFICIENT-1:0] res_reg;

state_mca_e state, next_state;
logic [4:0] counter;
logic [5:0] counter_double;

logic [NUM_ADDITIONS*2-1:0] S_val_packed;

// --------------------------------------------------------------------------
// -- Assignments
// --------------------------------------------------------------------------
assign res = res_reg;
assign counter_double = {counter, 1'b0};


// --------------------------------------------------------------------------
// -- state machine
// --------------------------------------------------------------------------

always_comb begin
  for (int i = 0; i < 2*NUM_ADDITIONS; i++) begin
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
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_double+:2] == 2'b00)) imm_res_reg <= $signed(imm_res_reg + operands_00[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_double+:2] == 2'b01)) imm_res_reg <= $signed(imm_res_reg + operands_01[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_double+:2] == 2'b10)) imm_res_reg <= $signed(imm_res_reg + operands_10[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_double+:2] == 2'b11)) imm_res_reg <= $signed(imm_res_reg + operands_11[counter]);
  else if (enable && (counter == (MAX_NUM_ADDITIONS-1))) imm_res_reg <= 0;
end
always_ff @(posedge clk or negedge resetn) begin
  if (!resetn) res_reg <= 0;
  // else if (enable && state == MCA_ADDING && counter == MAX_NUM_ADDITIONS-1 && (MAX_NUM_ADDITIONS == NUM_ADDITIONS)) res_reg <= (S_values[NUM_ADDITIONS-1] == 1'b1) ? imm_res_reg + operands[NUM_ADDITIONS-1] : imm_res_reg - operands[NUM_ADDITIONS-1];
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(2*(NUM_ADDITIONS-1))+:2] == 2'b00)) res_reg <= $signed(imm_res_reg + operands_00[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(2*(NUM_ADDITIONS-1))+:2] == 2'b01)) res_reg <= $signed(imm_res_reg + operands_01[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(2*(NUM_ADDITIONS-1))+:2] == 2'b10)) res_reg <= $signed(imm_res_reg + operands_10[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(2*(NUM_ADDITIONS-1))+:2] == 2'b11)) res_reg <= $signed(imm_res_reg + operands_11[NUM_ADDITIONS-1]);
  // else if (enable && state == MCA_ADDING && counter == MAX_NUM_ADDITIONS-1) res_reg <= (S_values[NUM_ADDITIONS-1] == 1'b1) ? imm_res_reg + operands[NUM_ADDITIONS-1] : imm_res_reg - operands[NUM_ADDITIONS-1];
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_double+:2] == 2'b00)) res_reg <= $signed(imm_res_reg + operands_00[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_double+:2] == 2'b01)) res_reg <= $signed(imm_res_reg + operands_01[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_double+:2] == 2'b10)) res_reg <= $signed(imm_res_reg + operands_10[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_double+:2] == 2'b11)) res_reg <= $signed(imm_res_reg + operands_11[NUM_ADDITIONS-1]);
end

endmodule