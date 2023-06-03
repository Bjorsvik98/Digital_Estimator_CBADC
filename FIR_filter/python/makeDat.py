"""
Simulating a Control-Bounded ADC
================================

This example shows how to simulate the interactions between an analog system
and a digital control while the former is excited by an analog signal.
"""
import matplotlib.pyplot as plt
import cbadc
import numpy as np
from functions.parsInput import parsFunc

N, beta, rho, kappa, amplitude, OSR, offset, size, eta2, K1, K2, DSR, bits_used, fraction_bits, outputFormat, LUT_size, coreName, freq, lut_state, ibex_state, pipeline_delay, ENOB, BW, N_MAX, K_MAX = parsFunc()
N = int(N)
OSR = int(OSR)
# OSR = 512

# In this example, each nodes amplification and local feedback will be set
# identically.

print("Info: Making dat file for FIR filter")

betaVec = beta * np.ones(N)
rhoVec = betaVec * rho
kappaVec = kappa * beta * np.eye(N)

analog_system = cbadc.analog_system.ChainOfIntegrators(betaVec, rhoVec, kappaVec) # Instantiate a chain-of-integrators analog system.

###############################################################################
# The Digital Control
T = 1.0 / (2 * beta) # Set the time period which determines how often the digital control updates.
clock = cbadc.analog_signal.Clock(T) # Instantiate a corresponding clock.
M = N # Set the number of digital controls to be same as analog states.
digital_control = cbadc.digital_control.DigitalControl(clock, M) # Initialize the digital control.



###############################################################################
# The Analog Signal
# -----------------
frequency = 1.0 / (T * OSR) # Choose the sinusoidal frequency via an oversampling ratio (OSR).
phase = np.pi / 3 # We also specify a phase an offset these are hovewer optional.
analog_signal = cbadc.analog_signal.Sinusoidal(amplitude, frequency, phase, offset) # Instantiate the analog signal


###############################################################################
# Simulating
# -------------
end_time = T * size
index = 0

# Instantiate a new simulator and control.
simulator = cbadc.simulator.get_simulator(
    analog_system,
    digital_control,
    [analog_signal],
    t_stop=end_time,
)

byte_stream = cbadc.utilities.control_signal_2_byte_stream(simulator, M) # Construct byte stream.

def print_next_10_bytes(stream):
    global index
    for byte in cbadc.utilities.show_status(stream, size):
        if index < 40:
            #print(f"{index} -> {byte}")
            index += 1
        yield byte


cbadc.utilities.write_byte_stream_to_file(
    "sinusoidal_simulation.dat", print_next_10_bytes(byte_stream)
)

