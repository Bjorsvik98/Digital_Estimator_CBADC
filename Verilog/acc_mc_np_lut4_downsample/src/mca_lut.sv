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
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_0000 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_0001 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_0010 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_0011 [NUM_ADDITIONS-1:0],

  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_0100 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_0101 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_0110 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_0111 [NUM_ADDITIONS-1:0],

  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_1000 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_1001 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_1010 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_1011 [NUM_ADDITIONS-1:0],

  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_1100 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_1101 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_1110 [NUM_ADDITIONS-1:0],
  input logic signed  [WIDTH_COEFFICIENT-1:0] operands_1111 [NUM_ADDITIONS-1:0],

  input logic S_values [NUM_ADDITIONS*4-1:0],
  input logic enable,
  output logic signed [WIDTH_COEFFICIENT-1:0] res
);

localparam MAX_NUM_ADDITIONS = 16;

logic signed [WIDTH_COEFFICIENT-1:0] imm_res_reg;
logic signed [WIDTH_COEFFICIENT-1:0] res_reg;

state_mca_e state, next_state;
logic [4:0] counter;
logic [6:0] counter_quad;

logic [NUM_ADDITIONS*4-1:0] S_val_packed;

// --------------------------------------------------------------------------
// -- Assignments
// --------------------------------------------------------------------------
assign res = res_reg;
assign counter_quad = {counter, 2'b00};


// --------------------------------------------------------------------------
// -- state machine
// --------------------------------------------------------------------------

always_comb begin
  for (int i = 0; i < 4*NUM_ADDITIONS; i++) begin
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
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0000)) imm_res_reg <= $signed(imm_res_reg + operands_0000[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0001)) imm_res_reg <= $signed(imm_res_reg + operands_0001[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0010)) imm_res_reg <= $signed(imm_res_reg + operands_0010[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0011)) imm_res_reg <= $signed(imm_res_reg + operands_0011[counter]);

  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0100)) imm_res_reg <= $signed(imm_res_reg + operands_0100[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0101)) imm_res_reg <= $signed(imm_res_reg + operands_0101[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0110)) imm_res_reg <= $signed(imm_res_reg + operands_0110[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0111)) imm_res_reg <= $signed(imm_res_reg + operands_0111[counter]);

  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1000)) imm_res_reg <= $signed(imm_res_reg + operands_1000[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1001)) imm_res_reg <= $signed(imm_res_reg + operands_1001[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1010)) imm_res_reg <= $signed(imm_res_reg + operands_1010[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1011)) imm_res_reg <= $signed(imm_res_reg + operands_1011[counter]);

  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1100)) imm_res_reg <= $signed(imm_res_reg + operands_1100[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1101)) imm_res_reg <= $signed(imm_res_reg + operands_1101[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1110)) imm_res_reg <= $signed(imm_res_reg + operands_1110[counter]);
  else if (enable && (state == MCA_ADDING) && (counter < NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1111)) imm_res_reg <= $signed(imm_res_reg + operands_1111[counter]);
  else if (enable && (counter == (MAX_NUM_ADDITIONS-1))) imm_res_reg <= 0;
end
always_ff @(posedge clk or negedge resetn) begin
  if (!resetn) res_reg <= 0;
  // else if (enable && state == MCA_ADDING && counter == MAX_NUM_ADDITIONS-1 && (MAX_NUM_ADDITIONS == NUM_ADDITIONS)) res_reg <= (S_values[NUM_ADDITIONS-1] == 1'b1) ? imm_res_reg + operands[NUM_ADDITIONS-1] : imm_res_reg - operands[NUM_ADDITIONS-1];
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b0000)) res_reg <= $signed(imm_res_reg + operands_0000[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b0001)) res_reg <= $signed(imm_res_reg + operands_0001[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b0010)) res_reg <= $signed(imm_res_reg + operands_0010[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b0011)) res_reg <= $signed(imm_res_reg + operands_0011[NUM_ADDITIONS-1]);

  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b0100)) res_reg <= $signed(imm_res_reg + operands_0100[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b0101)) res_reg <= $signed(imm_res_reg + operands_0101[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b0110)) res_reg <= $signed(imm_res_reg + operands_0110[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b0111)) res_reg <= $signed(imm_res_reg + operands_0111[NUM_ADDITIONS-1]);

  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b1000)) res_reg <= $signed(imm_res_reg + operands_1000[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b1001)) res_reg <= $signed(imm_res_reg + operands_1001[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b1010)) res_reg <= $signed(imm_res_reg + operands_1010[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b1011)) res_reg <= $signed(imm_res_reg + operands_1011[NUM_ADDITIONS-1]);

  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b1100)) res_reg <= $signed(imm_res_reg + operands_1100[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b1101)) res_reg <= $signed(imm_res_reg + operands_1101[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b1110)) res_reg <= $signed(imm_res_reg + operands_1110[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (MAX_NUM_ADDITIONS == NUM_ADDITIONS) && (S_val_packed[(4*(NUM_ADDITIONS-1))+:4] == 4'b1111)) res_reg <= $signed(imm_res_reg + operands_1111[NUM_ADDITIONS-1]);
  // else if (enable && state == MCA_ADDING && counter == MAX_NUM_ADDITIONS-1) res_reg <= (S_values[NUM_ADDITIONS-1] == 1'b1) ? imm_res_reg + operands[NUM_ADDITIONS-1] : imm_res_reg - operands[NUM_ADDITIONS-1];
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0000)) res_reg <= $signed(imm_res_reg + operands_0000[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0001)) res_reg <= $signed(imm_res_reg + operands_0001[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0010)) res_reg <= $signed(imm_res_reg + operands_0010[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0011)) res_reg <= $signed(imm_res_reg + operands_0011[NUM_ADDITIONS-1]);

  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0100)) res_reg <= $signed(imm_res_reg + operands_0100[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0101)) res_reg <= $signed(imm_res_reg + operands_0101[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0110)) res_reg <= $signed(imm_res_reg + operands_0110[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b0111)) res_reg <= $signed(imm_res_reg + operands_0111[NUM_ADDITIONS-1]);

  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1000)) res_reg <= $signed(imm_res_reg + operands_1000[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1001)) res_reg <= $signed(imm_res_reg + operands_1001[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1010)) res_reg <= $signed(imm_res_reg + operands_1010[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1011)) res_reg <= $signed(imm_res_reg + operands_1011[NUM_ADDITIONS-1]);

  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1100)) res_reg <= $signed(imm_res_reg + operands_1100[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1101)) res_reg <= $signed(imm_res_reg + operands_1101[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1110)) res_reg <= $signed(imm_res_reg + operands_1110[NUM_ADDITIONS-1]);
  else if (enable && (state == MCA_ADDING) && (counter == MAX_NUM_ADDITIONS-1) && (S_val_packed[counter_quad+:4] == 4'b1111)) res_reg <= $signed(imm_res_reg + operands_1111[NUM_ADDITIONS-1]);
end

endmodule