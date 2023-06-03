set script_path [pwd]
set script_dir [file dirname $script_path]
set vcd_name [string map {"/home/anbjors/pro/" "" "/sim" ""} $script_dir]
puts "vcd_name: $vcd_name"


# database -open -shm -into ncsim.shm waves -default

# probe -create -shm clk_n reset adr dat sel we cyc rdt cyclecounter ack_n pcpi_insn pcpi_valid pcpi_rs1 pcpi_rs2 pcpi_insn_decoded -waveform

# probe -create -shm  -depth all -all -waveform


run
database -open coreTest_vcd -vcd -timescale ps -into /sim/anbjors/accelerator/${vcd_name}.vcd
probe -create -database coreTest_vcd [scope -tops] -packed 200000 -depth all -all
# dumpsaif -scope tb_picorv32 -internal -overwrite -output /sim/anbjors/accelerator/${vcd_name}.saif
run

puts "Finished simulation successfully."
exit 
 
 
 