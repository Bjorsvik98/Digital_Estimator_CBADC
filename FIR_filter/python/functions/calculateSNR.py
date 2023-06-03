import numpy as np
import cbadc
import math


def calculate(u, Calculated, K1, DSR, size, offset=0, start_value=0):
    #### SNR ####
    number_of_valid_samples = size-K1-K1-1
    noise = np.zeros(number_of_valid_samples//DSR)
    for i in range(number_of_valid_samples//DSR):
        noise[i] = u[(i*DSR)+offset+start_value] - Calculated[i+start_value]
        print("Warning calculating SNR on en empty value") if Calculated[i+start_value] == 0  or u[(i*DSR)+offset+start_value] == 0 else None
        # print("u[%d] = %f, Calculated[%d] = %f, noise[%d] = %f" % ((i*DSR)+offset+start_value, u[(i*DSR)+offset+start_value], i+start_value, Calculated[i+start_value], i, noise[i]))
    # print("offset: ", offset)
    # print("start_value: ", start_value)
    
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
        print("Warning calculating SNR on en empty value at signalRMS") if Calculated[i+start_value] == 0 else None
        # print("Calculated[%d] = %f" % (i+K1, Calculated[i+K1]))
    signalRMS = signalRMS / number_of_valid_samples
    signalRMS = math.sqrt(signalRMS)

    # get SNR
    SNR = 0
    if noiseRMS == 0 or signalRMS == 0:
        print("     Warning: SNR is infinite, which means the digital part does not introduce any noise, or it may be an error in SNR calculation")
    else:
        SNR = 20 * math.log10(signalRMS / noiseRMS)
        # print("     SNR:            ", SNR)

        
    # print("\n     noiseAvarage:   ", noiseAvarage )
    # print("     noiseRMS:       ", noiseRMS)
    # print("     signalRMS:      ", signalRMS)
    return SNR

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

# noise = np.sum(spectrum[noise_mask])
# signal = np.sum(spectrum[signal_mask])
# harmonics = np.sum(spectrum[harmonics_mask])

# snr = signal / noise