import matplotlib.pyplot as plt
import numpy as np
import math
import cbadc
from functions.parsInput import parsFunc
from functions.saveEstimator import *



N, beta, rho, kappa, amplitude, OSR, offset, size, eta2, K1, K2, DSR, bits_used, fraction_bits, outputFormat, LUT_size, coreName, freq, lut_state, ibex_state, pipeline_delay, ENOB, BW, N_MAX, K_MAX = parsFunc()
N = int(N)
M = N
freq = float(freq)
OSR = int(OSR)



# CT = np.eye(N) # Set the amplification factor.

# Gamma = []
# for x in range(N):
#     innerlist = []
#     for y in range(N):
#         if x == y:
#             innerlist.append(kappa * beta)
#         else:
#             innerlist.append(0)
        
#     Gamma.append(innerlist)

# A = []
# for x in range(N):
#     innerlist = []
#     for y in range(N):
#         if x == y:
#             innerlist.append(beta * rho)
#         elif x == y+1:
#             innerlist.append(beta)
#         else:
#             innerlist.append(0)
        
#     A.append(innerlist)
    
# B = []
# for x in range(N):
#     innerlist = []
#     if x == 0:
#         innerlist.append(beta)
#     else:
#         innerlist.append(0)
#     B.append(innerlist)

ENOB = 20
# N = 6
BW = 1e6

# Gamma_tildeT = CT
T = 1.0 / (2 * beta)
# phase = np.pi / 3 # We also specify a phase an offset these are hovewer optional.
# bits_used = 64
# fraction_bits = 60
max_floating_point_value = 1 << (bits_used-fraction_bits)


amplitude = 1e0
phase = 0.0
offset = 0.0
u_hat = np.zeros(size)


analog_system, digital_control = cbadc.specification.get_leap_frog(ENOB=ENOB, N=N, BW=BW)
OSR=1/(2 * digital_control.clock.T * BW)
frequency = (freq) / (T * OSR) # Choose the sinusoidal frequency via an oversampling ratio (OSR).
print("frequency: ", frequency)


analog_signal = cbadc.analog_signal.Sinusoidal(amplitude, frequency, phase, offset)
# analog_system = cbadc.analog_system.AnalogSystem(A, B, CT, Gamma, Gamma_tildeT)
# digital_control = cbadc.digital_control.DigitalControl(cbadc.analog_signal.Clock(T), M)
fixed_point = cbadc.utilities.FixedPoint(bits_used, max_floating_point_value)
###############################################################################
end_time = T * size
index = 0

simulator = cbadc.simulator.get_simulator(
    analog_system,
    digital_control,
    [analog_signal],
    t_stop=end_time,
)

byte_stream = cbadc.utilities.control_signal_2_byte_stream(simulator, M) # Construct byte stream.

# def print_next_10_bytes(stream):
#     global index
#     for byte in cbadc.utilities.show_status(stream, size):
#         if index < 40:
#             # print(f"{index} -> {byte}")
#             index += 1
#         yield byte

# cbadc.utilities.write_byte_stream_to_file(
#     "sinusoidal_simulation.dat", print_next_10_bytes(byte_stream)
# )
###############################################################################
# read and write controll signal
# byte_stream = cbadc.utilities.read_byte_stream_from_file("sinusoidal_simulation.dat", M)
control_signal_sequences = cbadc.utilities.byte_stream_2_control_signal(byte_stream, M)

if outputFormat == 1:
    digital_estimator = cbadc.digital_estimator.FIRFilter(
        analog_system, digital_control, eta2, K1, K2, fixed_point=fixed_point
    )
    print("fixed point")
elif outputFormat == 2:
    digital_estimator = cbadc.digital_estimator.FIRFilter(
        analog_system, digital_control, eta2, K1, K2, #fixed_point=fixed_point
    )
    print("floating point")


digital_estimator(control_signal_sequences)
# print(digital_estimator)
# print(size)
u_hat = np.zeros(size)
# u_hat = [0 for x in range(size)]
# u_hat = [0]*size
for index in range(size-1):
    u_hat[index] = next(digital_estimator)


u_hat_fixed = np.zeros(size)

for i in range(len(u_hat)):
    u_hat_fixed[i] = fixed_point.float_to_fixed(u_hat[i])

t = np.arange(-K1 + 1, size - K1 + 1)
t_down = np.arange(-(K1) // DSR, (size - K1) // DSR) * DSR + 1

t_ref = np.arange(0, size +  K1)

stf_at_omega = digital_estimator.signal_transfer_function(
    np.array([2 * np.pi * frequency])
)[0]
u = np.zeros_like(u_hat)
for index, tt in enumerate(t_ref[0:len(u)]):
    u[index] = analog_signal.evaluate(tt * T - (T*0.004))


#### SNR ####
offset = size-K1-K1-1
noise = np.zeros(offset)
for i in range(offset):
    noise[i] = u[i+K1] - u_hat[i+K1-2+K1]
    # print("u = ",u[i+K1], "u_hat = ", u_hat[i+K1-2+K1])

# get avarage of noise
noiseAvarage = 0
for i in range(offset):
    noiseAvarage += noise[i]
noiseAvarage = noiseAvarage / offset
print("noiseAvarage: ", noiseAvarage)

#get RMS of noise
noiseRMS = 0
for i in range(offset):
    noiseRMS += noise[i]**2
noiseRMS = noiseRMS / offset
noiseRMS = math.sqrt(noiseRMS)
print("noiseRMS: ", noiseRMS)


# get RMS of signal
signalRMS = 0
for i in range(offset):
    signalRMS += u_hat[i+K1-2]**2
signalRMS = signalRMS / offset
signalRMS = math.sqrt(signalRMS)
print("signalRMS: ", signalRMS)

# get SNR
SNR = 0
SNR = 20 * math.log10(signalRMS / noiseRMS)
print("SNR: ", SNR)




t2 = list(range(len(u)))
# t2 = [i + K2 for i in t2]
# t2 = [x * DSR+1 for x in t2]

# # plt.plot(t_down, u_hat[0:len(t_down)], label="$\hat{u}(t)$ Reference")
plt.plot(t, u_hat, label="$\hat{u}(t)$ Reference")
plt.plot(t2, u, label="original sine")
# plt.plot(t2, A, label="Calculated ")
# # plt.plot(test, A)


# plt.plot(t_ref[0:(len(u))], stf_at_omega * u, label="$\mathrm{STF}(2 \pi f_u) * u(t)$")




plt.xlabel("$t / T$")
plt.legend()
plt.title("Estimated input signal")
plt.grid(which="both")
# plt.xlim((K1, size - K1-1))
plt.tight_layout()
plt.savefig("plot.png")
plt.savefig("plot.svg")
plt.show()

t = np.arange(len(noise))
plt.figure()
plt.plot(t, noise, label="$\hat{u}(t)$ Reference")
plt.savefig("noise.png")

