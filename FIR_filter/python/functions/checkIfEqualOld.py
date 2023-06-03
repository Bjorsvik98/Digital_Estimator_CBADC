import matplotlib.pyplot as plt
import numpy as np
from functions.parsInput import parsFunc
import collections
import cbadc
from functions.saveEstimator import *




N, beta, rho, kappa, amplitude, OSR, offset, size, eta2, K1, K2, DSR, bits_used, fraction_bits, outputFormat, LUT_size, coreName, freq, lut_state, ibex_state, pipeline_delay, ENOB, BW, N_MAX, K_MAX = parsFunc()
N = int(N)
DSR = int(DSR)
precision = 0.00001

print("Info: Checking results and comparing with the reference")

with open('../c_files/result.txt') as file:
    result = file.readlines()
    result = [line.rstrip() for line in result]
A = [int(x) for x in result]

with open('../hex_files/resultDecimal.txt') as file:
    result = file.readlines()
    result = [line.rstrip() for line in result]
B = [int(x) for x in result]
B = B[:size-1]

# print(A)
# for i in range(len(A)):
#         A[i] = to_float(A[i], FixedPointBits)


with open('u_hat.txt') as file:
    result = file.readlines()
    result = [line.rstrip() for line in result]
u_hat = [int(x) for x in result]

# print(u_hat)
# for i in range(len(u_hat)):
#         u_hat[i] = to_fixed(u_hat[i], FixedPointBits)

correct = 0
fails = 0
correctSimulated = 0
failsSimulated = 0
for i in range(len(A)//DSR-K2-K1):

    if(A[i+K1] == u_hat[((i)*DSR)+(K1+K2-1)]): # u_hat is float with another precision
        correct += 1
    else:
        fails += 1


for i in range(len(A)-K1-K1):
    # print("A[", i+K1-2, "] =", A[i+K1], "B[", i, "] =", B[i])
    if (A[i+K1-2] == B[i]): # u_hat is float with another precision
        correctSimulated += 1
    else:
        failsSimulated += 1



print("\nInfo: Checking of results done")
print("Info: Core used is", coreName)
# print("Info: Number of identical values =", correct, "of", (len(A)//DSR-K1-K2), "\nNumber of different values =",fails, "\nTotal samples =", size)
print("Local run:  Nr of correct values is ", correct, "of", (len(A)//DSR-K1-K2), "checked \n            and numbers of different values is",fails, "of total", size)
print("Simulation: Nr of correct values is", correctSimulated, "of", (len(A)//DSR-K1-K1), "checked \n            and numbers of different values is",failsSimulated, "of total", size, "\n            K =", (K1+K2), "and therefor are the first", K1, "and last", K2, "values not checked\n")
if (correct == correctSimulated):
    print("     ***** All values are correct *****")
else:
    print("  ***** There are some values that are not correct ***** \n")
