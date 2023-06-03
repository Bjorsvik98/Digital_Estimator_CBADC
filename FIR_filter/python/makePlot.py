import matplotlib.pyplot as plt
import numpy as np
import math
import cbadc
from scipy import signal
import sys

from functions.parsInput import parsFunc
# from functions.saveEstimator import *
import functions.calculateSNR as SNR
import functions.checkIfEqual as checkIfEqual
from datetime import datetime

import tikzplotlib

print("Info: Making plotting figures and calculation SNR")

N, beta, rho, kappa, amplitude, OSR, offset, size, eta2, K1, K2, DSR, bits_used, fraction_bits, outputFormat, LUT_size, coreName, freq, lut_state, ibex_state, pipeline_delay, ENOB, BW, N_MAX, K_MAX = parsFunc()
N = int(N)
M = N
OSR = float(OSR)
eta2 = int(eta2)

if DSR == 1:
    n_cycles = 8
else:
    n_cycles = (size/4)/(DSR*16)

toggle_simulated = 1

if ENOB == 0:
    toggle_simulated = 0




analog_frontend = cbadc.synthesis.get_leap_frog(OSR = OSR, N = N, BW = BW)
digital_control = analog_frontend.digital_control
analog_system = analog_frontend.analog_system 
if eta2 == 0:
    eta2 = (np.linalg.norm(analog_system.transfer_function_matrix(np.array([2 * np.pi * BW]))) ** 2)

# eta2 = 1
T = digital_control.clock.T
fs = 1.0 / T
fs_down = 1.0 / (T*DSR)
samples_per_period = size/n_cycles
fi = fs / samples_per_period
samples_per_period_down = (size/DSR)/n_cycles
# fi_down = fs_down / samples_per_period_down

t = T * np.arange(0, size) # time vector
end_time = T * size
# fraction_bits = bits_used
max_floating_point_value = 1 << (bits_used-fraction_bits)
print("Info: max_floating_point_value = ", max_floating_point_value)

# valid_samples = (size-K1-K2)//DSR
valid_samples = (size-(K1)-K2)
phase=0

analog_signal = cbadc.analog_signal.Sinusoidal(amplitude, fi, phase=phase, offset=offset)
simulator = cbadc.simulator.get_simulator(analog_system, digital_control, [analog_signal], t_stop=end_time)
fixed_point = cbadc.utilities.FixedPoint(bits_used, max_floating_point_value)
digital_estimator = cbadc.digital_estimator.FIRFilter(analog_system, digital_control, eta2, K1, K2)
#, fixed_point=fixed_point
digital_estimator(simulator)
print(fixed_point)
np.set_printoptions(threshold=np.inf)

# print(digital_estimator.h[0])


u_hat = np.zeros(size)
for index in range(size-1):
    u_hat[index] = next(digital_estimator)

# u_hat_fixed = np.zeros_like(u_hat)
# for i in range(len(u_hat)):
#     u_hat_fixed[i] = fixed_point.float_to_fixed(u_hat[i])

u = np.zeros_like(u_hat)
for index, tt in enumerate(t):
    u[index] = analog_signal.evaluate(tt)



with open('../c_files/result.txt') as file:
    result = file.readlines()
    result = [line.rstrip() for line in result]
Calculated = [int(x) for x in result]


# get the index of the max value
for i in range(len(Calculated)):
    Calculated[i] = fixed_point.fixed_to_float(Calculated[i])



if toggle_simulated == 1:
    with open('../hex_files/resultDecimal.txt') as file:
        result = file.readlines()
        result = [line.rstrip() for line in result]
    Simulated = [int(x) for x in result]
    Simulated = Simulated[:size]

    for i in range(len(Simulated)):
        Simulated[i] = fixed_point.fixed_to_float(Simulated[i])


    samples_simulated = Simulated
    # remove the elements that are zero
    samples_simulated = [x for x in samples_simulated if x != 0]
    print("Info: len(samples_simulated) =", len(samples_simulated))


    print("Info: valid_samples =", len(samples_simulated))
print("valid_samples = ", valid_samples//DSR)

firstValue = 0
Calculated_start_index = 0
for i in range(len(Calculated)):
    if Calculated[i] != 0:
        firstValue = Calculated[i]
        Calculated_start_index = i
        break
Simulated_start_index = 3
if toggle_simulated == 1:
    for i in range(len(Simulated)):
        if Simulated[i] == firstValue:
            Simulated_start_index = i
            break
u_hat_start_index = K1

# for i in range(len(u_hat)):
#     if u_hat[i] == firstValue:
#         u_hat_start_index = i
#         break
if toggle_simulated == 1:
    if Simulated_start_index == 0:
        print("Warning: The simulated values is not the same as the calculated values and therefor te plot is not perfect")
        # exit()
if u_hat_start_index == 0:
    print("Warning: The u_hat values is not the same as the calculated values")
    # exit()
Reference_start_index = K1


# print every DSR value of u_hat
# for i in range(len(u_hat)):
#     if i % DSR == 0:
#         print("u_hat: ", u_hat[i], "Calculated: ", Calculated[i], "i: ", i)



# for i in range(len(u_hat)):
#     print("u_hat: ", u_hat[i], "Calculated: ", Calculated[i], "i: ", i)
if toggle_simulated == 1:
    print("len(Simulated): ", len(Simulated))
print("len(u_hat): ", len(u_hat))
print("u_hat_start_index: ", u_hat_start_index, "simulated_start_index: ", Simulated_start_index, "Calculated_start_index: ", Calculated_start_index, "Reference_start_index: ", Reference_start_index,"\n\n")
u_hat = u_hat[K1+u_hat_start_index:u_hat_start_index+valid_samples]
u = u[K1+Reference_start_index:Reference_start_index+valid_samples]
Calculated = Calculated[Calculated_start_index:Calculated_start_index+(valid_samples//DSR)]
if toggle_simulated == 1:
    Simulated = Simulated[Simulated_start_index:Simulated_start_index+len(samples_simulated)-1]
# for i in range(len(Calculated)):
#     print("u_hat: ", u_hat[i], "Calculated: ", Calculated[i])

    print("len(Simulated): ", len(Simulated))
print("len(u_hat): ", len(u_hat))


n_full_cyc = int(len(u_hat) / samples_per_period)
n_full_cyc_calc = int(len(Calculated) / samples_per_period_down)
if toggle_simulated == 1:
    n_full_cyc_sim = int(len(Simulated) / samples_per_period_down)
# print("n_full_cyc: ", n_full_cyc, "samples_per_period: ", samples_per_period, "len(u_hat): ", len(u_hat))
# print("n_full_cyc_calc: ", n_full_cyc_calc, "samples_per_period_down: ", samples_per_period_down, "len(Calculated): ", len(Calculated))
u_hat = u_hat[:int(n_full_cyc*samples_per_period)]
Calculated = Calculated[:int(n_full_cyc_calc*samples_per_period_down)]
if toggle_simulated == 1:
    Simulated = Simulated[:int(n_full_cyc_sim*samples_per_period_down)]

    print("len(Simulated): ", len(Simulated))
print("len(u_hat): ", len(u_hat))
u = u[:int(n_full_cyc*samples_per_period)]

t_ref = np.arange(0, len(u_hat), dtype=float)
t_calc = np.arange(0, len(Calculated), dtype=float)
t_calc = [x*DSR for x in range(len(t_calc))]
if toggle_simulated == 1:
    # for i in range(len(Simulated)):
    #     print("Simulated: ", Simulated[i], "i: ", i)
    t_sim = np.arange(0, len(Simulated), dtype=float)
    t_sim = [x*DSR for x in range(len(t_sim))]

print("n_full_cyc: ", n_full_cyc, "samples_per_period: ", samples_per_period, "len(u_hat): ", len(u_hat))
print("n_full_cyc_calc: ", n_full_cyc_calc, "samples_per_period_down: ", samples_per_period_down, "len(Calculated): ", len(Calculated))
if toggle_simulated == 1:
    print("n_full_cyc_sim: ", n_full_cyc_sim, "samples_per_period_down: ", samples_per_period_down, "len(Simulated): ", len(Simulated))



plt.figure()

# plt.plot(t_ref, u, label="u Reference")
plt.plot(t_ref, u_hat, label="u_hat")
plt.plot(t_ref, u_hat, label="u_hat")
plt.plot(t_calc, Calculated, label="Calculated Local")
if toggle_simulated == 1:
    plt.plot(t_sim, Simulated, label="Simulated %s" % coreName)


plt.xlabel("$t / T$")
# plt.legend()
plt.title("Estimated input signal")
plt.grid(which="both")
# plt.xlim((K1-10, (size - K1)/DSR))
# plt.xlim((0, (size - K1)/DSR + K1+K1))
plt.tight_layout()
plt.savefig("plot.png")
plt.savefig("plot.svg")
tikzplotlib.save("plot.tex")


plt.show()


f, uhat_psd = signal.welch(u_hat, fs, window='boxcar', nperseg=len(u_hat), noverlap=0, axis=0)
_, u_psd = signal.welch(u, fs, window='boxcar', nperseg=len(u), noverlap=0, axis=0)
f_calc, calc_psd = signal.welch(Calculated, fs_down, window='boxcar', nperseg=len(Calculated), noverlap=0, axis=0)
if toggle_simulated == 1:
    f_sim, sim_psd = signal.welch(Simulated, fs_down, window='boxcar', nperseg=len(Simulated), noverlap=0, axis=0)

###### To use eta2 = 1
if eta2 == 1:
    f = f[f < 1e7]
    print("Warning: SNR is calculated only for frequencies below 2e7 Hz. Jeg har fjernet de of vet ikke hva jeg driver med.")
    f_calc = f_calc[f_calc < 1e7]
    uhat_psd = uhat_psd[:len(f)]
    # u_psd = u_psd[:len(f)]
    calc_psd = calc_psd[:len(f_calc)]

    if toggle_simulated == 1:
        f_sim = f_calc[:len(f)]
        sim_psd = sim_psd[:len(f_sim)]




print("SNR u_hat: ", SNR.calculate_SNR(uhat_psd, f), "dB")
print("SNR calc: ", SNR.calculate_SNR(calc_psd, f_calc), "dB")
if toggle_simulated == 1:
    print("SNR sim: ", SNR.calculate_SNR(sim_psd, f_sim), "dB")

# print("u_psd: ", u_psd)
# if np.any(u_psd == 0):
#     u_psd[u_psd == 0] = 1e-9

plt.figure()
# plt.semilogx(f, 20*np.log10(u_psd/np.max(u_psd)), label=f"u ref SNR: {SNR.calculate_SNR(u_psd, f):.2f} dB")
plt.semilogx(f, 20*np.log10(uhat_psd/np.max(u_psd)))
plt.semilogx(f, 20*np.log10(uhat_psd/np.max(u_psd)), label=f"u_hat SNR: {SNR.calculate_SNR(uhat_psd, f):.2f} dB")
plt.semilogx(f_calc, 20*np.log10(calc_psd/np.max(u_psd)), label=f"Calculated SNR: {SNR.calculate_SNR(calc_psd, f_calc):.2f} dB")
if toggle_simulated == 1:
    plt.semilogx(f_sim, 20*np.log10(sim_psd/np.max(u_psd)), label=f"Simulated SNR: {SNR.calculate_SNR(sim_psd, f_sim):.2f} dB")
plt.ylabel('PSD [dB] (Normalized to reference max)')
plt.xlabel('Frequency [Hz]')
# dont plot the first 1 Hz

plt.legend()
plt.grid()
plt.savefig("plotSignal_PSD.svg")
plt.savefig("plotSignal_PSD.png")
# tikzplotlib.save("/home/sp22/Masteroppgave/FIR/tex_plot/plotSignal_PSD.tex")

# plt.figure(figsize=(6, 3))
plt.figure()
# plt.semilogx(f, 20*np.log10(u_psd/np.max(u_psd)), label=f"u ref SNR: {SNR.calculate_SNR(u_psd, f):.2f} dB")
plt.semilogx(f, 20*np.log10(uhat_psd/np.max(u_psd)), label="Whith LP filtering")
plt.semilogx(f_calc, 20*np.log10(calc_psd/np.max(u_psd)), label="Whithout LP filtering")
plt.ylabel('PSD [dB]')
plt.xlabel('Frequency [Hz]')
# dont plot the first 1 Hz
plt.ylim(-400, 10)

plt.legend()
plt.grid()
plt.savefig("PSD_LP_filtering.png")
plt.savefig("PSD_LP_filtering.svg")
tikzplotlib.save("/home/sp22/Masteroppgave/FIR/tex_plot/PSD_LP_filtering.tex")



valid_samples = len(Calculated)


print("Finishing")










# Calculated_correct, Calculated_wrong = checkIfEqual.check(Calculated, u_hat, len(Calculated))
# if Calculated_correct == valid_samples:
#     # print("Calculated: The calculated values it the same as the reference values and therefor the plot is perfect")
#     print("*** CALCULATED IS CORRECT ***")
# else:
#     print("Simulation: Nr of correct values is", Calculated_correct, "of", (valid_samples), "checked \n            and numbers of different values is",Calculated_wrong, "of total", size, "\n            K =", (K1+K2), "and therefor are the first", K1, "and last", K2, "values not checked\n")
#     print("*** CALCULATED IS NOT CORRECT ***")


# Simulation_correct, Simulation_wrong = checkIfEqual.check(Simulated, Calculated, len(Simulated))
# if Simulation_correct == valid_samples:
#     print("*** SIMULATED IS CORRECT ***")
#     # print("Simulation: The simulated values it the same as the calculated values and therefor the plot is perfect")
# else:
#     print("*** SIMULATED IS NOT CORRECT ***")
#     print("Simulation: Nr of correct values is", Simulation_correct, "of", (valid_samples), "checked \n            and numbers of different values is",Simulation_wrong, "of total", size, "\n            K =", (K1+K2), "and therefor are the first", K1, "and last", K2, "values not checked\n")








h_index = np.arange(-K1, K2)

h_matrix = np.abs(np.array(digital_estimator.h[0, :, :])) 
h_matrix_dB = 10 * np.log10(h_matrix)

plt.figure()
for index in range(N):
    plt.plot(h_index, h_matrix_dB[:, index], label=f"$h_{index + 1}[k]$")
plt.xlabel("k")
plt.ylabel("$| h_\ell [k]|$ [dB]")
plt.legend()
plt.xlim((-K1, K1))
plt.grid(which="both")

plt.savefig("h_matrix.png")
plt.savefig("h_matrix.svg")
tikzplotlib.save("/home/sp22/Masteroppgave/FIR/tex_plot/h_matrix.tex")



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