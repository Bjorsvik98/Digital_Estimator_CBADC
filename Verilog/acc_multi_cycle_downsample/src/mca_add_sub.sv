`timescale 1 ns / 1 ps

// --------------------------------------------------------------------------
// -- Module for completing multiple additions in multiple clock cycles
// --------------------------------------------------------------------------

module mca_add_sub import FIR_pkg::*; #(
  parameter WIDTH_COEFFICIENT = 32,
  parameter NUM_ADDITIONS = 16
)
(
  input clk,
  input resetn,
  input start,
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_n [NUM_ADDITIONS-1:0],
  input logic S_values [NUM_ADDITIONS-1:0],
  input logic enable,
  output logic signed [WIDTH_COEFFICIENT-1:0] res
);

localparam MAX_NUM_ADDITIONS = 16;

logic signed [WIDTH_COEFFICIENT-1:0] imm_res_reg;
logic signed [WIDTH_COEFFICIENT-1:0] res_reg;


// --------------------------------------------------------------------------
// -- Assignments
// --------------------------------------------------------------------------
assign res = res_reg;


// --------------------------------------------------------------------------
// -- state machine
// --------------------------------------------------------------------------
state_mca_e state, next_state;
logic [4:0] counter;

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
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_values[counter] == 1'b1)) imm_res_reg <= $signed(imm_res_reg + operands[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_values[counter] == 1'b0)) imm_res_reg <= $signed(imm_res_reg + operands_n[counter]);
  else if(enable && (counter == MAX_NUM_ADDITIONS-1)) imm_res_reg <= 0;
end
always_ff @(posedge clk or negedge resetn) begin
  if (!resetn) res_reg <= 0;
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_values[counter] == 1'b1)) res_reg <= $signed(imm_res_reg + operands[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_values[counter] == 1'b0)) res_reg <= $signed(imm_res_reg + operands_n[NUM_ADDITIONS-1]);
  
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_values[counter] == 1'b1)) res_reg <= $signed(imm_res_reg + operands[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_values[counter] == 1'b0)) res_reg <= $signed(imm_res_reg + operands_n[NUM_ADDITIONS-1]);
end

endmodule