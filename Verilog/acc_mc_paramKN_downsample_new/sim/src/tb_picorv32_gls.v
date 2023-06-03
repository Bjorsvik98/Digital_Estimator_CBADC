`timescale 1 ns / 1 ps

`define RESET_PERIOD 100

`define MATCH_CALCULATE 32'h2027
`define MASK_CALCULATE 32'hfe00707f

module tb_picorv32 #(
   parameter K = `K,
   parameter N = `N,
   parameter WIDTH_COEFFICIENT = `WIDTH_COEFFICIENT,
   parameter CLOCK_PERIOD_HALF=`CLOCK_PERIOD_HALF,

   parameter NUM_INPUTS_S3=`NUM_INPUTS_S3,
   parameter NUM_INPUTS_S2=`NUM_INPUTS_S2,
   parameter NUM_INPUTS_S1=`NUM_INPUTS_S1,
   parameter NUM_S3_ADDERS=`NUM_S3_ADDERS,
   parameter NUM_S2_ADDERS=`NUM_S2_ADDERS,
   parameter NUM_S1_ADDERS=`NUM_S1_ADDERS,

   parameter N_MAX=`N_MAX,
   parameter K_MAX=`K_MAX

);

   reg clk;
   wire clk_n;
   reg resetn;
   wire reset;

   wire [31:2] adr;
   wire [31:0] dat;
   wire [3:0]  sel;
   wire        we;
   wire        cyc;
   reg [31:0]  rdt;
   wire [31:0] rdt_n;
   reg         ack;
   wire        ack_n;

   wire        pcpi_valid; // valid instruction
   wire [31:0] pcpi_insn; // instruction
   wire [31:0] pcpi_rs1; // rs1
   wire [31:0] pcpi_rs2; // rs2
   wire        pcpi_wr; // write
   wire [31:0] pcpi_rd; // rd
   wire        pcpi_wait; // wait
   wire        pcpi_ready; // ready

   // wire opcode_e, pcpi_insn_decoded;
   wire [5:0] pcpi_insn_decoded;

	reg [31:0]  mem [0:100000];


   integer     i;
   integer     cyclecounter;
   integer     calculation_start_time;
   
   initial begin
      $readmemh("../src/memimage.hex", mem);
      cyclecounter = 0;
      clk = 0;
      resetn = 0;
      #`RESET_PERIOD resetn = 1;
      $display("Test program starts at time %0t", $time);
      $display("The parameters is K = %0d, N = %0d, LUT_SIZE = %0d, WIDTH_COEFFICIENT = %0d, NUM_ADD_CLK = %0d, NUM_ADDER_STAGES = %0d", `K, `N, `LUT_SIZE, `WIDTH_COEFFICIENT, `NUM_ADD_CLK, `NUM_ADDER_STAGES);
   end

   always #CLOCK_PERIOD_HALF clk=~clk;

   // stop if timeout
   always @(posedge clk) begin
      cyclecounter = cyclecounter + 1;
      if(cyclecounter >= 2000000) begin
         $display("Error, timeout");

         $writememh("../results/out.hex", mem);

         // DO NOT CHANGE THE NEXT LINE IT IS NEEDED FOR GLS
         // $dumpoff;


         $finish(3);
      end
   end

   wire [3:0] mem_we = {4{we & cyc}} & sel;

   always @(negedge clk)
    if (!resetn)
      ack <= 1'b0;
    else begin
      if (cyc & !ack) #(CLOCK_PERIOD_HALF*2) ack <= 1'b1;
      else #(CLOCK_PERIOD_HALF*2) ack <= 1'b0;
    end

   always @(negedge clk) begin
      if (mem_we[0]) mem[adr][7:0]   <= dat[7:0];
      if (mem_we[1]) mem[adr][15:8]  <= dat[15:8];
      if (mem_we[2]) mem[adr][23:16] <= dat[23:16];
      if (mem_we[3]) mem[adr][31:24] <= dat[31:24];
      #(CLOCK_PERIOD_HALF*2) rdt <= mem[adr];
   end

   // exit when firmware exits
   always @(*) begin
      if(cyc && (adr == 30'h0400_0001) && we && (dat == 32'h0000_00ad)) begin
         $display("\nTest program ended correctly at time %0t", $time);
         $display("Time of execution: %0t", ($time-`RESET_PERIOD));
         $display("Clock period is: %0t", CLOCK_PERIOD_HALF*2);
         $display("Total number of cycles: %0d", cyclecounter);
         $display("Time of calculating output samples: %0t\n", ($time-calculation_start_time));


         $writememh("../results/out.hex", mem);
         // #10000;

         // DO NOT CHANGE THE NEXT LINE IT IS NEEDED FOR GLS
         // $dumpoff;
         
         // $display("Simulation ended at time %0t", $time);
         $stop;
         $finish;
      end
   end

   integer flag_new = 0;
   always @ (posedge clk) begin
      if (((pcpi_insn & `MASK_CALCULATE) == `MATCH_CALCULATE) && flag_new == 0) begin
         $display("The first calculation start at time %0t", $time);
         calculation_start_time = $time;
         flag_new = 1;
         $stop;

         // DO NOT CHANGE THE NEXT LINE IT IS NEEDED FOR GLS
         // $dumpon;
      end
   end

   // integer first_time = 1;
   // time last_time = 0;
   // time time_diff=0;
   // always @ (posedge clk) begin
   // if (((pcpi_insn & `MASK_CALCULATE) == `MATCH_CALCULATE) && pcpi_valid == 1) begin
   //    // Calculate the time since the last execution
   //    if (first_time) begin
   //       time_diff = 0;
   //       first_time = 0;
   //    end else begin
   //       time_diff = $time - last_time;
   //    end
      
   //    // Display the time since the last execution and update the last execution time
   //    if (time_diff != 1 && time_diff != 0) begin 
   //       $display("cyclecounter = %0d, time_diff = %0t, time = %0t", cyclecounter, time_diff, $time);
   //    end
   //    last_time = $time;
   //    end
   // end



   initial $timeformat(-9, 2, " ns", 20);


picorv32_top_K448_N6_WIDTH_COEFFICIENT22_N_MAX6_K_MAX448_NUM_INPUTS_S32688_NUM_INPUTS_S2176_NUM_INPUTS_S116_NUM_S3_ADDERS168_NUM_S2_ADDERS11_NUM_S1_ADDERS1_NUM_ADD_CLK4_NUM_ADDER_STAGES6_LUT_SIZE1
   chip (
                       .clk_n (clk_n), 
                       .reset (reset),
                       .adr (adr),
                       .dat (dat),
                       .sel (sel),
                       .we (we),
                       .cyc (cyc),
                       .rdt_n (rdt_n),
                       .ack_n (ack_n),

                       .pcpi_valid_tb (pcpi_valid),
                       .pcpi_insn_tb (pcpi_insn),
                       .pcpi_rs1_tb (pcpi_rs1),   
                       .pcpi_rs2_tb (pcpi_rs2),
                       .pcpi_insn_decoded (pcpi_insn_decoded)
                     //   .pcpi_wr (pcpi_wr),  
                     //   .pcpi_rd (pcpi_rd),  
                     //   .pcpi_wait (pcpi_wait), 
                     //   .pcpi_ready (pcpi_ready)     

                       );

   assign clk_n = ~clk;
   assign reset = ~resetn;
   assign rdt_n = ~rdt;
   assign ack_n = ~ack;

endmodule

