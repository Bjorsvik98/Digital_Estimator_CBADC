





def extract_output(start, num_res, file):
  fd = open(file, "r").readlines()
  out_mem = ""
  for i in range (int(num_res)):
    out_mem += str(fd[start + i][4:8]) + "\n"
    # out_mem += str(fd[start + i][0:4],) + "\n"    
  f_out = open("./result.hex", "w")
  f_out.write(out_mem)
  
extract_output(4096,98, "results/out.hex")