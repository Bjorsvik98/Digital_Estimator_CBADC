
import sys
import math

K = int(sys.argv[1])
N = int(sys.argv[2])
MCA_NUM_ADDITIONS = int(sys.argv[3])


NUM_INPUTS_S3 = math.ceil((N*K)/MCA_NUM_ADDITIONS)*MCA_NUM_ADDITIONS
NUM_INPUTS_S2 = math.ceil(math.ceil((N*K)/MCA_NUM_ADDITIONS)/MCA_NUM_ADDITIONS)*MCA_NUM_ADDITIONS
NUM_INPUTS_S1 = math.ceil(math.ceil(math.ceil((N*K)/MCA_NUM_ADDITIONS)/MCA_NUM_ADDITIONS)/MCA_NUM_ADDITIONS)*MCA_NUM_ADDITIONS

NUM_S3_ADDERS = math.ceil((N*K)/MCA_NUM_ADDITIONS)
NUM_S2_ADDERS = math.ceil(math.ceil((N*K)/MCA_NUM_ADDITIONS)/MCA_NUM_ADDITIONS)
NUM_S1_ADDERS = math.ceil(math.ceil(math.ceil((N*K)/MCA_NUM_ADDITIONS)/MCA_NUM_ADDITIONS)/MCA_NUM_ADDITIONS)

# Append the lines to file variables.txt
myfile = open("varibles.txt", "a")
myfile.write(str(NUM_INPUTS_S3)+"\n")
myfile.write(str(NUM_INPUTS_S2)+"\n")
myfile.write(str(NUM_INPUTS_S1)+"\n")
myfile.write(str(NUM_S3_ADDERS)+"\n")
myfile.write(str(NUM_S2_ADDERS)+"\n")
myfile.write(str(NUM_S1_ADDERS)+"\n")
myfile.close()




