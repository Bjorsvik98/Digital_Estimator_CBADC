
`timescale 1 ns / 1 ps

module picorv32_top #(
  parameter K = 128,
  parameter N = 7,
  parameter LUT_SIZE = 1,
  parameter WIDTH_COEFFICIENT = 32,
  parameter N_MAX = 8,
  parameter K_MAX = 512,
  parameter NUM_ADD_CLK = 4,
  parameter NUM_ADDER_STAGES = 5,

  parameter NUM_INPUTS_S3=1545,
  parameter NUM_INPUTS_S2=105,
  parameter NUM_INPUTS_S1=15,
  parameter NUM_S3_ADDERS=103,
  parameter NUM_S2_ADDERS=7,
  parameter NUM_S1_ADDERS=1

)(
  input              clk_n, 
  input              reset,
  output wire [31:2] adr,
  output wire [31:0] dat,
  output wire [3:0]  sel,
  output wire        we,
  output wire        cyc,
  input wire [31:0]  rdt_n,
  input wire         ack_n,

  output wire        pcpi_valid_tb,
  output wire [31:0] pcpi_insn_tb,
  output wire [31:0] pcpi_rs1_tb,
  output wire [31:0] pcpi_rs2_tb,

  output [5:0] pcpi_insn_decoded

  );
  wire [31:2]                      adr_n;
  wire [31:0]                      dat_n;
  wire [3:0]                       sel_n;
  wire                             we_n;
  wire                             cyc_n;

  wire                             clk;
  wire                             resetn;
  wire [31:0]                      rdt;
  wire                             ack;
  wire [ 3:0]                      wstrb;
  wire                             we_i;
  wire [1:0]                       dummy;

  wire         pcpi_valid;
  wire [31:0]  pcpi_insn;
  wire [31:0]  pcpi_rs1;
  wire [31:0]  pcpi_rs2;
  wire         pcpi_wr;
  wire [31:0]  pcpi_rd;
  wire         pcpi_wait;
  wire         pcpi_ready;

  wire         trace_valid;
  wire [35:0]  trace_data;
  wire         trap;
  wire [31:0]  irq;
  wire [31:0]  eoi;

  assign we_i = wstrb[0] | wstrb[1] | wstrb[2] | wstrb[3];
  assign we = we_i;
  assign sel = we_i ? wstrb : 4'hf;

  assign pcpi_valid_tb = pcpi_valid;
  assign pcpi_insn_tb = pcpi_insn;
  assign pcpi_rs1_tb = pcpi_rs1;
  assign pcpi_rs2_tb = pcpi_rs2;

  parameter [31:0] STACKADDR = 32'h 0001_86A0;
  parameter [31:0] PROGADDR_RESET = 32'h 0000_0000;

  picorv32 #(
    // .ENABLE_COUNTERS64(0),
    // .ENABLE_REGS_16_31(1),
    // .ENABLE_REGS_DUALPORT(0),
    // .LATCHED_MEM_RDATA(1),
    // .CATCH_MISALIGN(0),
    // .CATCH_ILLINSN(0),
    // .TWO_STAGE_SHIFT(0),
    // .TWO_CYCLE_COMPARE(1),
    // .TWO_CYCLE_ALU(1),
    .STACKADDR(STACKADDR),
    .PROGADDR_RESET(PROGADDR_RESET),
    .ENABLE_PCPI(1)
  ) cpu (
    .clk       (clk),
    .resetn    (resetn),
    .mem_valid (cyc),
    .mem_instr (),
    .mem_ready (ack),
    .mem_addr  ({adr,dummy}),
    .mem_wdata (dat),
    .mem_wstrb (wstrb),
    .mem_rdata (rdt),
    .mem_la_read (),
		.mem_la_write(),
		.mem_la_addr (),
		.mem_la_wdata(),
		.mem_la_wstrb(),
    .trace_valid (),
    .trace_data  (),
    .trap        (),
    .irq         (),
    .eoi         (),

    .pcpi_valid(pcpi_valid),
    .pcpi_insn (pcpi_insn),
    .pcpi_rs1 (pcpi_rs1),
    .pcpi_rs2 (pcpi_rs2),
    .pcpi_wr (pcpi_wr),
    .pcpi_rd (pcpi_rd),
    .pcpi_wait (pcpi_wait),
    .pcpi_ready (pcpi_ready)

  );

  FIR_accelerator #(
    .WIDTH_COEFFICIENT(WIDTH_COEFFICIENT),
    .K(K),
    .N(N),
    .NUM_S1_ADDERS(NUM_S1_ADDERS),
    .NUM_S2_ADDERS(NUM_S2_ADDERS),
    .NUM_S3_ADDERS(NUM_S3_ADDERS),
    .NUM_INPUTS_S1(NUM_INPUTS_S1),
    .NUM_INPUTS_S2(NUM_INPUTS_S2),
    .NUM_INPUTS_S3(NUM_INPUTS_S3)
  ) accelerator (
    .clk(clk),
    .resetn(resetn),
    .pcpi_valid(pcpi_valid),
    .pcpi_insn (pcpi_insn),
    .pcpi_rs1 (pcpi_rs1),
    .pcpi_rs2 (pcpi_rs2),
    .pcpi_wr (pcpi_wr),
    .pcpi_rd (pcpi_rd),
    .pcpi_wait (pcpi_wait),
    .pcpi_ready (pcpi_ready)
  );
  
  assign clk = ~clk_n;
  assign resetn = ~reset;
  assign adr_n = ~adr;
  assign dat_n = ~dat;
  assign sel_n = ~sel;
  assign we_n = ~we;
  assign cyc_n = ~cyc;
  assign rdt = ~rdt_n;
  assign ack = ~ack_n;

endmodule
