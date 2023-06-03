import matplotlib.pyplot as plt
import numpy as np
import cbadc
from scipy import signal

N = 6
OSR = 9
size = 1<<11
BW = 2e6
K1 = 256
K2 = K1
DSR = 9

# SNR=80

amplitude = 0.8
offset = 0
phase = 0
n_cycles = size/(DSR*32)
print("n_cycles: ", n_cycles)
M = N



analog_frontend = cbadc.synthesis.get_leap_frog(OSR = OSR, N = N, BW = BW)
digital_control = analog_frontend.digital_control
analog_system = analog_frontend.analog_system
eta2 = (np.linalg.norm(analog_system.transfer_function_matrix(np.array([2 * np.pi * BW]))) ** 2)


# Calculate input frequency such that the data set will contain an integer number of cycles
T = digital_control.clock.T
fs = 1.0 / T
fs_down = 1.0 / (T * DSR)

samples_per_period = size/n_cycles
samples_per_period_down = (size/DSR)/n_cycles





fi = fs / samples_per_period

analog_signal = cbadc.analog_signal.Sinusoidal(amplitude, fi, phase=phase, offset=offset)
t = T * np.arange(0, size) # time vector
t_down = np.arange(0, size//DSR) # time vector

end_time = T * size
simulator = cbadc.simulator.get_simulator(analog_system, digital_control, [analog_signal], t_stop=end_time)

digital_estimator = cbadc.digital_estimator.FIRFilter(
    analog_system, digital_control, eta2, K1, K2, downsample=DSR
)
digital_estimator(simulator)
u_hat = np.zeros(size//DSR)
for index in range((size//DSR)-1):
    u_hat[index] = next(digital_estimator)

u = np.zeros(size)
# u = np.zeros_like(u_hat)
for index, tt in enumerate(t):
    u[index] = analog_signal.evaluate(tt)

u_hat_start_index = K1+K2-1
Reference_start_index = K1+1



# Pot PSD and calculate SNR
## Remove invalid parts of u_hat
print("len u_hat: ", len(u_hat), "1")
print("K1: ", K1)
print("K1*2 + K2: ", K1*2 + K2)
u_hat = u_hat[int(K1/DSR)*2:-int(K2/DSR)]
t_down = t_down[int(K1/DSR)*2:-int(K2/DSR)]
u = u[K1*2:-K2]
print("len u_hat: ", len(u_hat), "2")

## Make sure u_hat contains an integer number of cycles to avoid windowing in FFT
## Calculate number of full cycles:
n_full_cyc = int(len(u) / samples_per_period)
n_full_cyc_down = int(len(u_hat) / samples_per_period_down)
u_hat = u_hat[:int(n_full_cyc_down*samples_per_period_down)]
print("len u_hat: ", len(u_hat), "3")
t_down = t_down[:int(n_full_cyc_down*samples_per_period_down)]
u = u[:int(n_full_cyc*samples_per_period)]
print("n_full_cyc: ", n_full_cyc, "samples_per_period: ", samples_per_period, "len(u_hat): ", len(u_hat))
print("n_full_cyc_down: ", n_full_cyc_down, "samples_per_period_down: ", samples_per_period_down, "len(u): ", len(u))
print("len u_hat: ", len(u_hat), "len u: ", len(u))


# Plot time domain
plt.figure()
# plt.plot(t, -u, label="u Reference")
plt.plot(t_down, u_hat, label="u_hat")
plt.legend()

plt.grid()
plt.savefig("plotSignal_F.png")


f, uhat_psd = signal.welch(u_hat, fs_down, window='boxcar', nperseg=len(u_hat), noverlap=0, axis=0)
f_u, u_psd = signal.welch(u, fs, window='boxcar', nperseg=len(u), noverlap=0, axis=0)

# Calculate SNR
def calculate_SNR(sig_psd, f):
    fbin = f[1] - f[0]
    # Find peak signal frequency
    isig = np.argmax(sig_psd)
    # Calculate signal power
    signal_power = sig_psd[isig] * fbin
    # Calculate noise power
    noise_power = 0
    for i in range(len(f)):
        if not i == isig:
            noise_power += sig_psd[i] * fbin

    SNR = signal_power / noise_power
    SNR_dB = 10*np.log10(SNR)
    return SNR_dB

print("SNR: ", calculate_SNR(uhat_psd, f))
plt.figure()
# plt.semilogx(f_u, 20*np.log10(u_psd/np.max(u_psd)), label=f"u ref SNR: {calculate_SNR(u_psd, f_u):.2f} dB")
plt.semilogx(f, 20*np.log10(uhat_psd/np.max(u_psd)), label=f"u_hat SNR: {calculate_SNR(uhat_psd, f):.2f} dB")
plt.ylabel('PSD [dB] (Normalized to reference max)')
plt.xlabel('Frequency [Hz]')
plt.legend()
plt.grid()
# plt.savefig("plotSignal_F_PSD.svg")
plt.savefig("plotSignal_F_PSD.png")

