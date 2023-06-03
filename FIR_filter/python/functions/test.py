import numpy as np
import sys


N=3
K1=128
FPB=22
block_width=32


# AS_arr = np.array([0, 0, 0])
AS_arr = np.array([0, 4, 5])
# red_arr = np.array([0, 0, 0, 0])
red_arr = np.array([0, 2, 4, 6])
 



# bits_left = (N * K1 - sum(AS_arr) * FPB) * (block_width - sum(red_arr)) * FPB
print("Bits used without optimization =", N * K1 * FPB)
N_bits = np.zeros(N)
for i in range(N):
    N_bits[i] = ((FPB - AS_arr[i]))
print("Bits used with optimized per analog state =", int(sum(N_bits)*K1))

K_bits = np.zeros(K1)
for j in range(0, K1):
    K_bits[j] = ((FPB - red_arr[int(j/block_width)]))

# init 2d array total_bits
total_bits = np.zeros((N, K1))
for i in range(N):
    for j in range(K1):
        total_bits[i][j] = 22 - (22 - N_bits[i]) - (22 - K_bits[j])

print("Bits used with optimization both ways =", int(sum(sum(total_bits))))


