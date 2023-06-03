set script_path [pwd]
set script_dir [file dirname $script_path]
set vcd_name [string map {"/home/anbjors/pro/" "" "/sim" ""} $script_dir]
puts "vcd_name: $vcd_name"


database -open -shm -into ncsim.shm waves -default
probe -create -shm clk_n reset adr dat sel we cyc rdt cyclecounter ack_n pcpi_insn pcpi_valid pcpi_rs1 pcpi_rs2 pcpi_insn_decoded -waveform
probe -create -shm chip.accelerator.sample_out chip.accelerator.start -waveform
# probe -create -shm chip.accelerator.pcpi_wr chip.accelerator.pcpi_ready chip.accelerator.clk chip.accelerator.H_matrix chip.accelerator.S_matrix resetn chip.accelerator.sample_out  -waveform
# probe -create -shm chip.accelerator.adder0.O_imm_M0_ff chip.accelerator.adder0.O_imm_M1_ff chip.accelerator.adder0.O_imm_M2_ff chip.accelerator.adder0.O_imm_M3_ff chip.accelerator.adder0.O_imm_M4_ff chip.accelerator.adder0.O_imm_M5_ff chip.accelerator.adder0.O_imm_M6_ff chip.accelerator.adder0.opcode -waveform
# probe -create -shm  -depth all -all -waveform

run 

database -open coreTest_vcd -vcd -timescale ps -into /sim/anbjors/accelerator/${vcd_name}.vcd
probe -create -database coreTest_vcd [scope -tops] -packed 200000 -depth all -all
# dumpsaif -scope tb_picorv32 -internal -overwrite -output /sim/anbjors/accelerator/${vcd_name}.saif

run

puts "Finished simulation successfully."
exit 
 
 
 