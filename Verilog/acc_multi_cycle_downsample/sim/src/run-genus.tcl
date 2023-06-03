database -open -shm -into ncsim.shm waves -default
probe -create -shm clk_n reset adr dat sel we cyc rdt cyclecounter ack_n mem[103] mem[4097] mem[4150] mem[4190] -waveform

database -open coreTest_vcd -vcd -into /sim/anbjors/coreTest-genus.vcd

probe -create -database coreTest_vcd [scope -tops] -depth all -all
run

exit