import matplotlib.pyplot as plt
import numpy as np
import math

import cbadc


N = 7
SNR = 50
size = 1024
BW = 2000000
K1 = 128
K2 = K1
DSR = 1
SNR = 160


amplitude = 0.8
offset = 0
phase = 0
bits_used = 25
fraction_bits = bits_used - 1
M = N

valid_samples = (size-K1-K2)//DSR




max_floating_point_value = 1 << (bits_used-fraction_bits)

analog_frontend = cbadc.synthesis.get_leap_frog(SNR = SNR, N = N, BW = BW)
digital_control = analog_frontend.digital_control
analog_system = analog_frontend.analog_system

T = digital_control.clock.T
frequency = 1.0 / digital_control.clock.T

while frequency > BW:
    frequency /= 2
frequency /= 2
frequency /= 2


eta2 = (np.linalg.norm(analog_system.transfer_function_matrix(np.array([2 * np.pi * BW]))) ** 2)



analog_signal = cbadc.analog_signal.Sinusoidal(amplitude, frequency, phase=phase, offset=offset)
# analog_system = cbadc.analog_system.AnalogSystem(A, B, CT, Gamma, Gamma_tildeT)
# digital_control = cbadc.digital_control.DigitalControl(cbadc.analog_signal.Clock(T), M)
# byte_stream = cbadc.utilities.read_byte_stream_from_file("sinusoidal_simulation.dat", M)
end_time = T * size
simulator = cbadc.simulator.get_simulator(analog_system, digital_control, [analog_signal], t_stop=end_time)
byte_stream = cbadc.utilities.control_signal_2_byte_stream(simulator, M) # Construct byte stream.

fixed_point = cbadc.utilities.FixedPoint(bits_used, max_floating_point_value)
control_signal_sequences = cbadc.utilities.byte_stream_2_control_signal(byte_stream, M)

digital_estimator = cbadc.digital_estimator.FIRFilter(
    analog_system, digital_control, eta2, K1, K2, fixed_point=fixed_point
)

digital_estimator(control_signal_sequences)
u_hat = np.zeros(size)
for index in range(size-1):
    u_hat[index] = next(digital_estimator)


u_hat_fixed = np.zeros(size)

# u_hat = float_to_fixed(u_hat, FixedPointBits)
for i in range(len(u_hat)):
    u_hat_fixed[i] = fixed_point.float_to_fixed(u_hat[i])

# print(u_hat)




t_ref = np.arange(0, size +  K1)

stf_at_omega = digital_estimator.signal_transfer_function(
    np.array([2 * np.pi * frequency])
)[0]
u = np.zeros_like(u_hat)
for index, tt in enumerate(t_ref[0:len(u)]):
    u[index] = analog_signal.evaluate(tt * T)



t = np.arange(0, valid_samples, dtype=float)
t_ref = np.arange(0, valid_samples*DSR, dtype=float)

if DSR > 1:
    print("     Info: DSR > 1 and therefor the plot is changed to fit the DSR")
    for i, x in enumerate(t_ref):
        # if i > K1:
        t_ref[i] = x/DSR

        # else:
        #     t_ref[i] = x
    # t_ref = [i/DSR for i in t_ref]
    t_ref = [x for x in t_ref]

u_hat_start_index = K1+K2-1
Reference_start_index = K1+1
plt.figure()

plt.plot(t_ref, u[Reference_start_index:Reference_start_index+(valid_samples*DSR)], label="u Reference")
plt.plot(t, u_hat[u_hat_start_index:u_hat_start_index+(valid_samples*DSR)], label="u_hat")




plt.xlabel("$t / T$")
plt.legend()
plt.title("Estimated input signal")
plt.grid(which="both")
# plt.xlim((K1-10, (size - K1)/DSR))
# plt.xlim((0, (size - K1)/DSR + K1+K1))
plt.tight_layout()
plt.savefig("u_hat.png")
# plt.savefig("plot.svg")
# plt.show()

def calculateSNR(u, Calculated, K1, DSR, size, offset=0, start_value=0):
    #### SNR ####
    number_of_valid_samples = size-K1-K1-1
    noise = np.zeros(number_of_valid_samples//DSR)
    for i in range(number_of_valid_samples//DSR):
        noise[i] = u[(i*DSR)+offset+start_value] - Calculated[i+start_value]

    # get avarage of noise
    noiseAvarage = 0
    for i in range(number_of_valid_samples//DSR):
        noiseAvarage += noise[i]
    noiseAvarage = noiseAvarage / number_of_valid_samples


    #get RMS of noise
    noiseRMS = 0
    for i in range(number_of_valid_samples//DSR):
        noiseRMS += noise[i]**2
    noiseRMS = noiseRMS / number_of_valid_samples
    noiseRMS = math.sqrt(noiseRMS)

    # get RMS of signal
    signalRMS = 0
    for i in range(number_of_valid_samples//DSR):
        signalRMS += Calculated[i+start_value]**2
    signalRMS = signalRMS / number_of_valid_samples
    signalRMS = math.sqrt(signalRMS)

    # get SNR
    SNR = 20 * math.log10(signalRMS / noiseRMS)
    return SNR

SNR_analog = calculateSNR(u, u_hat, K1, DSR, size, offset=Reference_start_index-u_hat_start_index, start_value=u_hat_start_index)
print("     SNR_analog: ", SNR_analog) if SNR_analog != 0 else None





h_index = np.arange(-K1, K2)

max_bits_used = np.zeros(len(digital_estimator.h[0][0]))


h_bits_needed = np.zeros((len(digital_estimator.h[0]), len(digital_estimator.h[0][0])))


for i in range(len(digital_estimator.h[0])):
    for j in range(len(digital_estimator.h[0][i])):
        bits_used = np.ceil(np.log2(np.abs(digital_estimator.h[0][i][j])))+1
        h_bits_needed[i][j] = bits_used

        if bits_used > max_bits_used[j]:
            max_bits_used[j] = bits_used

print("max_bits_used =", max_bits_used)



plt.figure()
fig, ax = plt.subplots(1)
for index in range(N):
    ax.plot(h_index, h_bits_needed[:, index], label=f"$h_{index + 1}[k]$")
ax.legend()
plt.grid()

plt.savefig("h_bits_needed.png")




