"""
Simulating a Control-Bounded ADC
================================

This example shows how to simulate the interactions between an analog system
and a digital control while the former is excited by an analog signal.
"""


import matplotlib.pyplot as plt
import cbadc
import numpy as np
import datetime
import tikzplotlib
from functions.saveEstimator import *

from functions.parsInput import parsFunc


print("Info: Making coefficients for FIR filter")

N, beta, rho, kappa, amplitude, OSR, offset, size, eta2, K1, K2, DSR, bits_used, fraction_bits, outputFormat, LUT_size, coreName, freq, lut_state, ibex_state, pipeline_delay, ENOB, BW, N_MAX, K_MAX = parsFunc()
N = int(N)
M = N
OSR = float(OSR)
eta2 = int(eta2)

if DSR == 1:
    n_cycles = 8
else:
    n_cycles = (size/4)/(DSR*16)


if (N<3 or N>8):
    print("ERROR: N must be between 3 and 8")
    exit(1)
# if ( N > LUT_size and N%LUT_size != 0):
#     print("ERROR: N must be a multiple of LUT_size")
#     exit(1)
# if (LUT_size > N and LUT_size%N != 0):
#     print("ERROR: LUT_size must be a multiple of N")
#     exit(1)
# if (N < LUT_size and (DSR%(LUT_size/N) != 0)):
#     print("ERROR: DSR must be a multiple of LUT_size/N")
#     exit(1)

analog_frontend = cbadc.synthesis.get_leap_frog(OSR = OSR, N = N, BW = BW)
digital_control = analog_frontend.digital_control
analog_system = analog_frontend.analog_system 
if eta2 == 0:
    eta2 = (np.linalg.norm(analog_system.transfer_function_matrix(np.array([2 * np.pi * BW]))) ** 2)
# eta2 = 1
print("eta2: ", eta2)
T = digital_control.clock.T
fs = 1.0 / T
samples_per_period = size/n_cycles
fi = fs / samples_per_period
t = T * np.arange(0, size) # time vector
end_time = T * size
max_floating_point_value = 1 << (bits_used-fraction_bits)
phase=0


analog_signal = cbadc.analog_signal.Sinusoidal(amplitude, fi, phase=phase, offset=offset)
simulator = cbadc.simulator.get_simulator(analog_system, digital_control, [analog_signal], t_stop=end_time)
fixed_point = cbadc.utilities.FixedPoint(bits_used, max_floating_point_value)
digital_estimator = cbadc.digital_estimator.FIRFilter(analog_system, digital_control, eta2, K1, K2, fixed_point=fixed_point)
digital_estimator(simulator)
np.set_printoptions(threshold=np.inf)
# print(digital_estimator.h[0])

###############################################################################
byte_stream = cbadc.utilities.control_signal_2_byte_stream(simulator, M) # Construct byte stream.
control_signal_sequences = cbadc.utilities.byte_stream_2_control_signal(byte_stream, M)

file = open("control_signal_sequences.txt", "w+")
line = "{} {}\n".format(size, M)
file.write(line)
for x in range(size-1):
    line = list(next(control_signal_sequences))
    if outputFormat == 1:
        outLine = ' '.join(map(str, line)) + '\n'
    if outputFormat == 2:
        outLine = ', '.join(map(str, line)) + '\n'
    file.write(outLine)

file.close()
#####################################################################################
# Writing the coefficients and matrix to coefficient.h file

file = open("../c_files/include/add_to_define.txt", "r")
lines = file.readlines()
file.close()
for x in range(len(lines)):
    lines[x] = lines[x].split()
    lines[x][1] = int(lines[x][1])

coefficientPath = "../c_files/include/coefficients.h"
initCoefficients(coefficientPath)

for x in range(len(lines)):
    saveConstCoefficients(coefficientPath, lines[x][1], lines[x][0])

saveConstCoefficients(coefficientPath, DSR, "DSR")
saveConstCoefficients(coefficientPath, int(OSR), "OSR")
saveConstCoefficients(coefficientPath, digital_estimator.K1, "K1")
saveConstCoefficients(coefficientPath, digital_estimator.K2, "K2")
saveConstCoefficients(coefficientPath, digital_estimator.K1 + digital_estimator.K2, "K")
saveConstCoefficients(coefficientPath, size, "SAMPLES")
saveConstCoefficients(coefficientPath, int(math.pow(2,LUT_size)), "ADDR_SHIFT")
saveConstCoefficients(coefficientPath, int(LUT_size), "LUT_SIZE")
saveConstCoefficients(coefficientPath, int(ibex_state), "IBEX_STATE")
saveConstCoefficients(coefficientPath, int(pipeline_delay), "PIPELINE_DELAY")
saveConstCoefficients(coefficientPath, N, "N")

N_BIN = 2**N - 1
K_BIN = 2**(2*digital_estimator.K1/16) - 1

# print(N_BIN)
# print(K_BIN)

saveConstCoefficients(coefficientPath, int(K_BIN), "K_BIN")
saveConstCoefficients(coefficientPath, int(N_BIN), "N_BIN")


if (LUT_size == 2):
    saveMatrixCoefficientsAcceleratedLUT(coefficientPath, digital_estimator.h[0], "H_ACC_LUT", LUT_size)
if (LUT_size == 3):
    print("Making LUT3 coefficients")
    saveMatrixCoefficientsAcceleratedLUT(coefficientPath, digital_estimator.h[0], "H_ACC_LUT3", LUT_size)
if (LUT_size == 4):
    print("Making LUT4 coefficients")
    saveMatrixCoefficientsAcceleratedLUT(coefficientPath, digital_estimator.h[0], "H_ACC_LUT4", LUT_size)
if (LUT_size == 5):
    print("Making LUT5 coefficients")
    saveMatrixCoefficientsAcceleratedLUT(coefficientPath, digital_estimator.h[0], "H_ACC_LUT5", LUT_size)


# if (lut_state == '1'):
#     saveMatrixCoefficientsLUT(coefficientPath, digital_estimator.h[0], "H", LUT_size)
#     saveControllSequenceLUT(coefficientPath, "control_signal_sequences.txt", "S", LUT_size) #must be last
# elif (lut_state == '0'):
saveMatrixCoefficients(coefficientPath, digital_estimator.h[0], "H")
saveControllSequenceAccelerated(coefficientPath, "control_signal_sequences.txt", "S_ACC", N)
# if (downsampling is used)
if (DSR == 1 or DSR == 2 or DSR == 4 or DSR == 8):
    saveControllSequenceAcceleratedDownsampled(coefficientPath, "control_signal_sequences.txt", "S_ACC_DOWN", N, DSR)
if DSR == 8:
    saveControllSequenceAcceleratedDownsampled_8(coefficientPath, "control_signal_sequences.txt", "S_ACC_DSR_8", N, DSR)

saveControllSequenceAcceleratedDSREqualOSR(coefficientPath, "control_signal_sequences.txt", "S_ACC_DOWN_EQUAL_OSR", N, DSR, N_MAX, K_MAX)


saveControllSequence(coefficientPath, "control_signal_sequences.txt", "S") #must be last

# print(fixed_point)

# sv_sim_file_H = "sv_sim_files/h_matrix.txt"
# writeHMatrixToFile(sv_sim_file_H, digital_estimator.h[0])
# sv_sim_file_S = "sv_sim_files/s_matrix.txt"
# writeSMatrixToFile(sv_sim_file_S, "control_signal_sequences.txt")






run_old = False

if N == 3 and K1 == 128:
    AS_arr = np.array([0, 4, 5])
    red_arr = np.array([0, 2, 4, 6])
elif N == 4 and K1 == 160:
    AS_arr = np.array([0, 4, 6, 8])
    red_arr = np.array([0, 2, 3, 5, 7])
elif N == 5 and K1 == 160:
    AS_arr = np.array([0, 3, 5, 7, 9])
    red_arr = np.array([0, 2, 3, 5, 6])
elif N == 6 and K1 == 224:
    AS_arr = np.array([0, 3, 4, 7, 8, 10])
    red_arr = np.array([0, 1, 2, 3, 5, 6, 7])
elif N == 7 and K1 == 224:
    AS_arr = np.array([0, 2, 3, 5, 6, 8, 9])
    red_arr = np.array([0, 1, 2, 3, 5, 6, 7])
elif N == 8 and K1 == 256:
    AS_arr = np.array([0, 2, 3, 4, 5, 6, 8, 9])
    red_arr = np.array([0, 1, 2, 3, 4, 5, 7, 8])
else: 
    run_old = True

 
h_index = np.arange(-K1, K1)
max_bits_used = np.zeros(len(digital_estimator.h[0][0]))
h_bits_needed = np.zeros((len(digital_estimator.h[0]), len(digital_estimator.h[0][0])))

for i in range(len(digital_estimator.h[0])):
    for j in range(len(digital_estimator.h[0][i])):
        bits_used_H = np.ceil(np.log2(np.abs(digital_estimator.h[0][i][j])))+1
        h_bits_needed[i][j] = bits_used_H

        if bits_used_H > max_bits_used[j]:
            max_bits_used[j] = bits_used_H
print("max_bits_used =", max_bits_used)
bits_diff = bits_used - max_bits_used[0]
print("bits_diff =", bits_diff)
bits_removed = bits_used - max_bits_used 
print("bits_removed =", bits_removed)

plt.figure()
fig, ax = plt.subplots(1)
for index in range(N):
    ax.plot(h_index, h_bits_needed[:, index], label=f"$h_{index + 1}[k]$")
ax.legend(loc='upper right')

steps = 32

y_values = np.zeros((len(h_index), N))
increment_outwards = np.zeros((int(K1*2/steps), N))
increment_outwards_new = np.zeros((int(K1*2/steps), N))
increment_downwars = 2
max_value = np.zeros((int(K1*2/steps), N))

if run_old == False:
    red_arr_double = np.concatenate((red_arr[::-1], red_arr))



for index in range(N):
    for i in range(0, K1*2, steps):
        max_value[int(i/steps),index] = np.max(h_bits_needed[i:i + steps, index])
        if run_old == True:
            increment_outwards[int(i/steps),index] = bits_used - max_value[int(i/steps),index]
        else:
            increment_outwards[int(i/steps),index] = AS_arr[index] + red_arr_double[int(i/steps)]
        # print("bits_used - AS_arr[index] - red_arr[int(i/steps) = ", bits_used, "-", AS_arr[index], "-", red_arr_double[int(i/steps)])
        # print("increment_outwards[",int(i/steps),",",index,"] =", increment_outwards[int(i/steps),index])
    # print("increment_outwards    : ", increment_outwards, "N = ", N)
    # print("increment_outwards_new: ", increment_outwards_new, "N = ", N)
    if index == 0:
        if run_old == True:
            const_diff = bits_used - max_value[int(K1/steps),index]
        else:
            const_diff = 0
    for j in range(0, K1*2, steps):
        y_values[j:j + steps, index] = bits_used - (increment_outwards[int(j/steps), index]) + const_diff
    # plot = ax.plot(h_index, y_values[:, index], label=f"$h_{index + 1}[k]$", linestyle='dotted', color=ax.lines[index].get_color()) 
    
    
    # plot = ax.plot(h_index, np.ones(len(h_index))*max_bits_used[index], label=f"$h_{index + 1}[k]$", linestyle='dotted', color=ax.lines[index].get_color())
    # print("y_values[:, ",index,"] =", y_values[:, index])
    # print every steps value of y_values
        # arr = arr.append(y_values[i, index])
    # add y_values to array
    if index == 0:
        arr = np.array([])
        for i in range(0, K1*2, steps):
            arr = np.append(arr, y_values[i, index])
        print("y_values for AS ",index," =", arr)
        arr = bits_used - arr
        print("y_values =", arr[0:int(K1/32)])



plt.xlabel("k")

plt.grid()
plt.ylabel("Bits needed")
plt.yticks(np.arange(0, bits_used+1, 2))
if eta2 == 1:
    tikzplotlib.save("/home/sp22/Masteroppgave/FIR/tex_plot/h_bits_needed_eta2_N%d.tex" % N)
    plt.savefig("/home/sp22/Masteroppgave/FIR/tests/svg/h_bits_needed_eta2_N%d.svg" % N)
    plt.savefig("h_bits_needed_eta2_N%d.svg" % N)
plt.savefig("/home/sp22/Masteroppgave/FIR/tests/png/h_bits_needed_eta2_N%d.png" % N)
plt.savefig("/home/sp22/Masteroppgave/FIR/tests/svg/h_bits_needed_N%d.svg" % N)
plt.savefig("h_bits_needed.png")
plt.savefig("h_bits_needed.svg")
tikzplotlib.save("/home/sp22/Masteroppgave/FIR/tex_plot/h_bits_needed.tex")




if run_old == False:
    print("Bits used without optimization =", N * K1 * bits_used)
    N_bits = np.zeros(N)
    for i in range(N):
        N_bits[i] = ((bits_used - AS_arr[i]))
    print("Bits used with optimized per analog state =", int(sum(N_bits)*K1))

    K_bits = np.zeros(K1)
    for j in range(0, K1):
        K_bits[j] = ((bits_used - red_arr[int(j/steps)]))

    total_bits = np.zeros((N, K1))
    for i in range(N):
        for j in range(K1):
            total_bits[i][j] = bits_used - (bits_used - N_bits[i]) - (bits_used - K_bits[j])

    print("Bits used with optimization both ways =", int(sum(sum(total_bits))))


# # extract impulse response
# impulse_response = np.abs(np.array(digital_estimator.h[0, :, :]))

# # Visualize the impulse response
# h_index = np.arange(-K1, K2)
# fig, ax = plt.subplots(2)
# for index in range(N):
#     ax[0].plot(h_index, impulse_response[:, index], label=f"$h_{index + 1}[k]$")
#     ax[1].semilogy(h_index, impulse_response[:, index], label=f"$h_{index + 1}[k]$")
# ax[0].legend()
# fig.suptitle(f"For $\eta^2 = {10 * np.log10(eta2)}$ [dB]")
# ax[1].set_xlabel("filter tap k")
# ax[0].set_ylabel("$| h_\ell [k]|$")
# ax[1].set_ylabel("$| h_\ell [k]|$")
# ax[0].set_xlim((-50, 50))
# ax[0].grid(which="both")
# ax[1].set_xlim((-K1, K2))
# ax[1].grid(which="both")

# print(f"Total number of filter coefficients = {digital_estimator.number_of_filter_coefficients()}")



# plt.savefig("h_matrix.png")
# plt.savefig("h_matrix.svg")