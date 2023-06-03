from multiprocessing.dummy import Array
# import matplotlib.pyplot as plt
# import cbadc
import numpy as np
import math

def initCoefficients(path):
    file = open(path, "w")
    file.write("#ifndef COEFFICIENTS_H\n")
    file.write("#define COEFFICIENTS_H\n")
    file.write("#ifdef USE_MYSTDLIB\n  #include \"stdlib.h\"\n #else\n  #include <stdlib.h>\n #endif\n\n")
    # file.write("// #include \"stdlib.h\"\n#include <stdint.h>\n#include <stdlib.h>\n\n")
    file.close()

def saveConstCoefficients(path, value, name):
    file = open(path, "a")
    line = "#define {} {}\n".format(name, value)
    file.write(line)
    file.close()

def saveMatrixCoefficientsLUT(path, matrix, name, LUT_size): 
    # Used to save matrix coefficients to file when using LUT

    print("Info: Writing matrix coefficients to file")

    file = open(path, "a")
    hRow, hCol = matrix.shape
    line = "\n"
    file.write(line)
    saveConstCoefficients(path , math.ceil(hRow*hCol/LUT_size), "{}_HEIGHT".format(name))
    saveConstCoefficients(path , int(math.pow(2, LUT_size)), "{}_WIDTH".format(name))


    line = "int32_t {}[{}_HEIGHT][{}_WIDTH] = {{\n{{".format(name, name, name)
    file.write(line)

    # Constructing Look-up table of matrix
    LUT_matrix = np.zeros((math.ceil(hRow*hCol/LUT_size), int(math.pow(2, LUT_size))))
    for LUT in range (math.floor((hRow*hCol)/LUT_size)):
    # for LUT in range (1):
        for i in range(int(math.pow(2,LUT_size))):
            # print(i)
            for iii in range (LUT_size):
                # print(bin(i >> iii))
                if bin(i >> iii)[-1] == "0":
                    LUT_matrix[LUT][i] -= matrix[math.floor(((LUT+1)*LUT_size-iii-1)/hCol)][((LUT+1)*LUT_size-iii-1)%hCol]
                    # print("minus")
                    # print(matrix[math.floor(((LUT+1)*LUT_size-iii-1)/hCol)][((LUT+1)*LUT_size-iii-1)%hCol])
                else:
                    LUT_matrix[LUT][i] += matrix[math.floor(((LUT+1)*LUT_size-iii-1)/hCol)][((LUT+1)*LUT_size-iii-1)%hCol]
                    # print("plus")
                    # print(matrix[math.floor(((LUT+1)*LUT_size-iii-1)/hCol)][((LUT+1)*LUT_size-iii-1)%hCol])
            # print('\n')

    np.savetxt(file, LUT_matrix, delimiter=', ',fmt="%d", newline="},\n{")
    print("Info: Matrix coefficients written to file")


    #Remove last line of file
    file.seek(0, 2)
    size = file.tell()
    file.truncate(size-2)

    line = "};\n\n"
    file.write(line)


    file.close()

def saveMatrixCoefficients(path, matrix, name):
    # Used to save matrix coefficients to file when not using LUT
    file = open(path, "a")
    hRow, hCol = matrix.shape
    line = "\n"
    file.write(line)
    saveConstCoefficients(path , hRow, "{}_HEIGHT".format(name))
    saveConstCoefficients(path , hCol, "{}_WIDTH".format(name))


    line = "int32_t {}[{}_HEIGHT][{}_WIDTH] = {{\n{{".format(name, name, name)
    file.write(line)
    np.savetxt(file, matrix, delimiter=', ',fmt="%d", newline="},\n{")

    #Remove last line of file
    file.seek(0, 2)
    size = file.tell()
    file.truncate(size-2)

    line = "};\n\n"
    file.write(line)


    file.close()

def saveMatrixCoefficientsAcceleratedLUT(path, matrix, name, LUT_size):

    if (not(LUT_size == 2 or LUT_size==3 or LUT_size == 4 or LUT_size == 5)):
        print("WARNING: Accelerated LUT only supports LUT size of 2, 4 and 5, and %s will not be generated" % name)
    elif (LUT_size == 2):
        print("Info: Accelerated LUT size of 2 will be generated for %s" % name)
        file = open(path, "a")
        hRow, hCol = matrix.shape
        line = "\n"
        file.write(line)
        saveConstCoefficients(path , math.ceil(hRow/2), "{}_HEIGHT".format(name))
        saveConstCoefficients(path , hCol, "{}_WIDTH".format(name))
        file.close()
        # Used to save matrix coefficients to file when using accelerated LUT
        LUT_values = ['00', '01', '10', '11']
        for combination in LUT_values:
            file = open(path, "a")
            line = "\n"
            file.write(line)

            line = "int32_t {}_{}[{}_HEIGHT][{}_WIDTH] = {{\n{{".format(name, combination, name, name)
            file.write(line)
            # np.savetxt(file, matrix, delimiter=', ',fmt="%d", newline="},\n{")
            for row in range(0, hRow, 2):
                if (row != 0):
                    file.write("{")
                for col in range(hCol):
                    if combination == '00':
                        file.write(str(-matrix[row][col] - matrix[row+1][col]))
                    elif combination == '01':
                        file.write(str(-matrix[row][col] + matrix[row+1][col]))
                    elif combination == '10':
                        file.write(str(+matrix[row][col] - matrix[row+1][col]))
                    elif combination == '11':
                        file.write(str(matrix[row][col] + matrix[row+1][col]))
                    if col != hCol-1:
                        file.write(", ")
                file.write("},\n")
            file.write("};\n\n")
            file.write("\n")

    elif (LUT_size == 3):
        print("Info: Accelerated LUT size of 3 will be generated for %s" % name)
        file = open(path, "a")
        hRow, hCol = matrix.shape
        line = "\n"
        file.write(line)
        saveConstCoefficients(path , math.ceil(hRow/3), "{}_HEIGHT".format(name))
        saveConstCoefficients(path , hCol, "{}_WIDTH".format(name))
        file.close()
        # Used to save matrix coefficients to file when using accelerated LUT
        # Make Lut_values a list of strings
        LUT_values = ['000', '001', '010', '011', '100', '101', '110', '111']
        for combination in LUT_values:
            file = open(path, "a")
            line = "\n"
            file.write(line)

            line = "int32_t {}_{}[{}_HEIGHT][{}_WIDTH] = {{\n{{".format(name, combination, name, name)
            file.write(line)
            # np.savetxt(file, matrix, delimiter=', ',fmt="%d", newline="},\n{")
            for row in range(0, hRow, 3):
                if (row != 0):
                    file.write("{")
                for col in range(hCol):
                    sum = 0
                    for i, char in enumerate(combination):
                        if char == '0':
                            if int(row+i) < hRow:
                                sum += matrix[row+i][col]
                        else:
                            if row+i < hRow:
                                sum -= matrix[row+i][col]
                    file.write(str(sum))
                    if col != hCol-1:
                        file.write(", ")
                if (row != hRow-3):
                    file.write("},\n")
                else:
                    file.write("}")
            file.write("};\n\n")
            file.write("\n")

        #Remove last line of file
        file.seek(0, 2)
        size = file.tell()
        file.truncate(size-2)
        file.write("\n")
        file.close()

    elif (LUT_size == 4):
        print("Info: Accelerated LUT size of 4 will be generated for %s" % name)
        file = open(path, "a")
        hRow, hCol = matrix.shape
        line = "\n"
        file.write(line)
        saveConstCoefficients(path , math.ceil(hRow/4), "{}_HEIGHT".format(name))
        saveConstCoefficients(path , hCol, "{}_WIDTH".format(name))
        file.close()
        # Used to save matrix coefficients to file when using accelerated LUT
        LUT_values = ['0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111']
        for combination in LUT_values:
            file = open(path, "a")
            line = "\n"
            file.write(line)

            line = "int32_t {}_{}[{}_HEIGHT][{}_WIDTH] = {{\n{{".format(name, combination, name, name)
            file.write(line)
            # np.savetxt(file, matrix, delimiter=', ',fmt="%d", newline="},\n{")
            for row in range(0, hRow, 4):
                if (row != 0):
                    file.write("{")
                for col in range(hCol):
                    if combination == '0000':
                        file.write(str(-matrix[row][col] - matrix[row+1][col] - matrix[row+2][col] - matrix[row+3][col]))
                    elif combination == '0001':
                        file.write(str(-matrix[row][col] - matrix[row+1][col] - matrix[row+2][col] + matrix[row+3][col]))
                    elif combination == '0010':
                        file.write(str(-matrix[row][col] - matrix[row+1][col] + matrix[row+2][col] - matrix[row+3][col]))
                    elif combination == '0011':
                        file.write(str(-matrix[row][col] - matrix[row+1][col] + matrix[row+2][col] + matrix[row+3][col]))
                    elif combination == '0100':
                        file.write(str(-matrix[row][col] + matrix[row+1][col] - matrix[row+2][col] - matrix[row+3][col]))
                    elif combination == '0101':
                        file.write(str(-matrix[row][col] + matrix[row+1][col] - matrix[row+2][col] + matrix[row+3][col]))
                    elif combination == '0110':
                        file.write(str(-matrix[row][col] + matrix[row+1][col] + matrix[row+2][col] - matrix[row+3][col]))
                    elif combination == '0111':
                        file.write(str(-matrix[row][col] + matrix[row+1][col] + matrix[row+2][col] + matrix[row+3][col]))
                    elif combination == '1000':
                        file.write(str(matrix[row][col] - matrix[row+1][col] - matrix[row+2][col] - matrix[row+3][col]))
                    elif combination == '1001':
                        file.write(str(matrix[row][col] - matrix[row+1][col] - matrix[row+2][col] + matrix[row+3][col]))
                    elif combination == '1010':
                        file.write(str(matrix[row][col] - matrix[row+1][col] + matrix[row+2][col] - matrix[row+3][col]))
                    elif combination == '1011':
                        file.write(str(matrix[row][col] - matrix[row+1][col] + matrix[row+2][col] + matrix[row+3][col]))
                    elif combination == '1100':
                        file.write(str(matrix[row][col] + matrix[row+1][col] - matrix[row+2][col] - matrix[row+3][col]))
                    elif combination == '1101':
                        file.write(str(matrix[row][col] + matrix[row+1][col] - matrix[row+2][col] + matrix[row+3][col]))
                    elif combination == '1110':
                        file.write(str(matrix[row][col] + matrix[row+1][col] + matrix[row+2][col] - matrix[row+3][col]))
                    elif combination == '1111':
                        file.write(str(matrix[row][col] + matrix[row+1][col] + matrix[row+2][col] + matrix[row+3][col]))
                    if col != hCol-1:
                        file.write(", ")
                file.write("},\n")
            file.write("};\n\n")
            file.write("\n")

    elif (LUT_size == 5):
        print("Info: Accelerated LUT size of 5 will be generated for %s" % name)
        file = open(path, "a")
        hRow, hCol = matrix.shape
        line = "\n"
        file.write(line)
        saveConstCoefficients(path , math.ceil(hRow/5), "{}_HEIGHT".format(name))
        saveConstCoefficients(path , hCol, "{}_WIDTH".format(name))
        file.close()
        # Used to save matrix coefficients to file when using accelerated LUT
        # Make Lut_values a list of strings
        LUT_values = ['00000', '00001', '00010', '00011', '00100', '00101', '00110', '00111', '01000', '01001', '01010', '01011', '01100', '01101', '01110', '01111', '10000', '10001', '10010', '10011', '10100', '10101', '10110', '10111', '11000', '11001', '11010', '11011', '11100', '11101', '11110', '11111']
        for combination in LUT_values:
            file = open(path, "a")
            line = "\n"
            file.write(line)

            line = "int32_t {}_{}[{}_HEIGHT][{}_WIDTH] = {{\n{{".format(name, combination, name, name)
            file.write(line)
            # np.savetxt(file, matrix, delimiter=', ',fmt="%d", newline="},\n{")
            for row in range(0, hRow, 5):
                if (row != 0):
                    file.write("{")
                for col in range(hCol):
                    sum = 0
                    for i, char in enumerate(combination):
                        if char == '0':
                            if int(row+i) < hRow:
                                sum += matrix[row+i][col]
                        else:
                            if row+i < hRow:
                                sum -= matrix[row+i][col]
                    file.write(str(sum))
                    if col != hCol-1:
                        file.write(", ")
                if (row != hRow-5):
                    file.write("},\n")
                else:
                    file.write("}")
            file.write("};\n\n")
            file.write("\n")

        #Remove last line of file
        file.seek(0, 2)
        size = file.tell()
        file.truncate(size-2)
        file.write("\n")
        file.close()

def saveControllSequenceLUT(path, controlSequencePath, name, LUT_size):
    # Used to save control sequence to file when using LUT
    print("Info: Saving control sequence")
    sequenceFile = open(controlSequencePath, "r")
    sequence = sequenceFile.readlines()
    sequenceFile.close()
    HEIGHT = sequence[0].split(" ")[0]
    WIDTH = sequence[0].split(" ")[1]

    file = open(path, "a")
    
    saveConstCoefficients(path, math.ceil(int(HEIGHT)*int(WIDTH)/LUT_size), "{}_HEIGHT".format(name))                  
    # saveConstCoefficients(path, WIDTH, "{}_WIDTH".format(name))
    # line = "const int32_t {}[{}_HEIGHT][{}_WIDTH] = {{\n".format(name, name, name) 
    line = "const int32_t {}[{}_HEIGHT] = {{\n".format(name, name, name) 
    file.write(line)
    LUT_seq = ""        # LUT_size bits sequence
    firstline = True    # skip the first line
    # read the file line by line and extract every number
    for line in sequence:
        if firstline:                               # skip the first line
            firstline = False                       # and set the flag to false
            continue                                # skip the rest of the loop
        for char in line:                                   # for every char in the line
            if char == "0" or char == "1":                  # if it is a 0 or 1
                LUT_seq = LUT_seq + char                    # add it to the sequence
                if len(LUT_seq) == LUT_size:                # if the sequence is LUT_size long
                    # file.write("{" + LUT_seq + "},\n")    # write it to the file
                    file.write(str(int(LUT_seq,2))  + ",\n")             # write it to the file
                    LUT_seq = ""                            # and reset the sequence
    if LUT_seq != "":                               # if the sequence is not empty
        # file.write("{" + LUT_seq + "}")             # write it to the file
        file.write(str(int(LUT_seq,2)) )             # write it to the file
    file.write("};\n")                              # close the array
    file.write("\n\n#endif")                        # end the file
    file.close()                                    # close the file
    print("Info: control sequence saved")

def saveControllSequenceAccelerated(path, controlSequencePath, name, N):
    # Used to save control sequence to file when using accelerator
    # OPS, it is bad variable name, but I am too lazy to change it

    print("Info: Saving control sequence")
    sequenceFile = open(controlSequencePath, "r")
    sequence = sequenceFile.readlines()
    sequenceFile.close()
    HEIGHT = sequence[0].split(" ")[0]
    WIDTH = sequence[0].split(" ")[1]

    file = open(path, "a")
    
    saveConstCoefficients(path, math.ceil(int(HEIGHT)*int(WIDTH)/N), "{}_HEIGHT".format(name))                  
    # saveConstCoefficients(path, WIDTH, "{}_WIDTH".format(name))
    # line = "const int32_t {}[{}_HEIGHT][{}_WIDTH] = {{\n".format(name, name, name) 
    line = "const int32_t {}[{}_HEIGHT] = {{\n".format(name, name, name) 
    file.write(line)
    LUT_seq = ""        # N bits sequence
    firstline = True    # skip the first line
    # read the file line by line and extract every number
    for line in sequence:
        if firstline:                               # skip the first line
            firstline = False                       # and set the flag to false
            continue                                # skip the rest of the loop
        for char in line:                                   # for every char in the line
            if char == "0" or char == "1":                  # if it is a 0 or 1
                LUT_seq = LUT_seq + char                    # add it to the sequence
                if len(LUT_seq) == N:                # if the sequence is N long
                    # file.write("{" + LUT_seq + "},\n")    # write it to the file
                    file.write(str(int(LUT_seq,2))  + ",\n")             # write it to the file
                    LUT_seq = ""                            # and reset the sequence
    if LUT_seq != "":                               # if the sequence is not empty
        # file.write("{" + LUT_seq + "}")             # write it to the file
        file.write(str(int(LUT_seq,2)) )             # write it to the file
    file.write("};\n\n")                              # close the array
    # file.write("\n\n#endif")                        # end the file
    file.close()                                    # close the file
    print("Info: control sequence saved")

def saveControllSequenceAcceleratedDownsampled(path, controlSequencePath, name, N, DSR):
    # Used to save control sequence to file when using accelerator
    # OBS, it is bad variable name, but I am too lazy to change it

    print("Info: Saving control sequence")
    sequenceFile = open(controlSequencePath, "r")
    sequence = sequenceFile.readlines()
    sequenceFile.close()
    HEIGHT = sequence[0].split(" ")[0]
    WIDTH = sequence[0].split(" ")[1]

    file = open(path, "a")
    if DSR == 1:
        saveConstCoefficients(path, math.ceil(int(HEIGHT)*int(WIDTH)/N), "{}_HEIGHT".format(name))                  
    elif DSR == 2:
        saveConstCoefficients(path, math.ceil((int(HEIGHT)*int(WIDTH)/N)/DSR), "{}_HEIGHT".format(name))
    elif DSR == 4:
        saveConstCoefficients(path, math.ceil((int(HEIGHT)*int(WIDTH)/N)/DSR), "{}_HEIGHT".format(name))
    elif DSR == 8:
        saveConstCoefficients(path, math.ceil((int(HEIGHT)*int(WIDTH)/N)/(DSR/2)), "{}_HEIGHT".format(name))                      
    # saveConstCoefficients(path, WIDTH, "{}_WIDTH".format(name))
    # line = "const int32_t {}[{}_HEIGHT][{}_WIDTH] = {{\n".format(name, name, name) 
    line = "const int32_t {}[{}_HEIGHT] = {{\n".format(name, name, name) 
    file.write(line)
    bit_seq = ""        # N bits sequence
    bit_seq_last = ""        # N bits sequence
    const_seq = ""      # 16-N bits sequence

    # for i in range(0, int(32/(DSR/2))-N):
    #     const_seq = const_seq + "0"
    if DSR == 1:
        const_seq = ""
    elif DSR == 2:
        for i in range(0, 16-N):
            const_seq = const_seq + "0"
    elif DSR == 4 or DSR == 8:
        for i in range(0, 8-N):
            const_seq = const_seq + "0"

    firstline = True    # skip the first line
    # read the file line by line and extract every number
    i = 0
    n = 0
    bit_seq = ""
    bit_seq_comb = ""
    for line in sequence:
        i = i+1
        if firstline:                               # skip the first line
            firstline = False                       # and set the flag to false
            continue                                # skip this iteration of the loop
        for char in line:                                   # for every char in the line
            if char == "0" or char == "1":                  # if it is a 0 or 1
                bit_seq = char + bit_seq                    # add it to the sequence
                if len(bit_seq) == N:                # if the sequence is N long
                    bit_seq_comb = const_seq + bit_seq + bit_seq_comb
                    bit_seq = ""
                    n = n+1
                    if DSR == 1:
                        # print(str(int(bit_seq_comb,2)))
                        file.write(str(int(bit_seq_comb,2))  + ",\n")
                        bit_seq_comb = ""
                        n = 0
                    elif DSR == 2:
                        if n == 2:
                            file.write(str(int(bit_seq_comb,2))  + ",\n")
                            bit_seq_comb = ""
                            n = 0
                    elif DSR == 4 or DSR == 8:
                        if n == 4:
                            file.write(str(int(bit_seq_comb,2))  + ",\n")
                            bit_seq_comb = ""
                            n = 0

    if bit_seq_comb != "":                               # if the sequence is not empty
        # file.write("{" + bit_seq + "}")             # write it to the file
        file.write(str(int(bit_seq_comb,2)) )             # write it to the file
    file.write("};\n\n")                              # close the array
    # file.write("\n\n#endif")                        # end the file
    file.close()                                    # close the file
    print("Info: control sequence saved")           


def saveControllSequenceAcceleratedDownsampled_8(path, controlSequencePath, name, N, DSR):
    # Used to save control sequence to file when using accelerator
    print("Info: Saving control sequence")
    sequenceFile = open(controlSequencePath, "r")
    sequence = sequenceFile.readlines()
    sequenceFile.close()
    HEIGHT = sequence[0].split(" ")[0]
    WIDTH = sequence[0].split(" ")[1]

    file = open(path, "a")
    if DSR == 1:
        saveConstCoefficients(path, math.ceil(int(HEIGHT)*int(WIDTH)/N), "{}_HEIGHT".format(name))                  
    elif DSR == 8:
        saveConstCoefficients(path, math.ceil((int(HEIGHT)*int(WIDTH)/N)/(DSR/2)), "{}_HEIGHT".format(name))                      
    line = "const int32_t {}[{}_HEIGHT] = {{\n".format(name, name, name) 
    file.write(line)
    bit_seq = ""        # N bits sequence
    bit_seq_last = ""        # N bits sequence
    const_seq = ""      # 16-N bits sequence

    if DSR == 1:
        const_seq = ""
    elif DSR == 2:
        for i in range(0, 16-N):
            const_seq = const_seq + "0"
    elif DSR == 4 or DSR == 8:
        for i in range(0, 8-N):
            const_seq = const_seq + "0"

    firstline = True    # skip the first line
    # read the file line by line and extract every number
    tempArray = []
    tempArray2 = []
    i = 0
    n = 0
    bit_seq = ""
    bit_seq_comb = ""
    for line in sequence:
        i = i+1
        if firstline:                               # skip the first line
            firstline = False                       # and set the flag to false
            continue                                # skip this iteration of the loop
        for char in line:                                   # for every char in the line
            if char == "0" or char == "1":                  # if it is a 0 or 1
                bit_seq = char + bit_seq                    # add it to the sequence
                if len(bit_seq) == N:                # if the sequence is N long
                    bit_seq_comb = const_seq + bit_seq + bit_seq_comb
                    bit_seq = ""
                    n = n+1
                    if DSR == 4 or DSR == 8:
                        if n == 4:
                            # file.write(str(int(bit_seq_comb,2))  + ",\n")
                            if ((i-1)/4) % 2 == 0:
                                tempArray2.append(int(bit_seq_comb,2))
                            else:
                                tempArray.append(int(bit_seq_comb,2))
                            # tempArray.append(int(bit_seq_comb,2))
                            bit_seq_comb = ""
                            n = 0

    # print("temp1 = ", tempArray)
    # print("temp2 = ", tempArray2)

    for line in tempArray:
        file.write(str(line)  + ",\n")
    for line in tempArray2:
        file.write(str(line)  + ",\n")


    if bit_seq_comb != "":                               # if the sequence is not empty
        # file.write("{" + bit_seq + "}")             # write it to the file
        file.write(str(int(bit_seq_comb,2)) )             # write it to the file
    file.write("};\n\n")                              # close the array
    # file.write("\n\n#endif")                        # end the file
    file.close()                                    # close the file
    print("Info: control sequence saved")      


def saveControllSequenceAcceleratedDSREqualOSR(path, controlSequencePath, name, N, DSR, N_MAX, K_MAX):
    numSamplesInReg = [[10,10],[8,7],[6,6],[5,4],[4,4],[4,3]]

    # Used to save control sequence to file when using accelerator
    print("Info: Saving control sequence")

    sequenceFile = open(controlSequencePath, "r")
    sequence = sequenceFile.readlines()
    sequenceFile.close()
    HEIGHT = sequence[0].split(" ")[0]
    WIDTH = sequence[0].split(" ")[1]

    if (N_MAX == 0):   # if N_MAX is not set
        print("WARNING: N_MAX is not set. Check that version is not parametrizable.")

        file = open(path, "a")
        saveConstCoefficients(path, math.ceil(2*((int(HEIGHT)/(numSamplesInReg[N-3][0]+numSamplesInReg[N-3][1])))), "{}_HEIGHT".format(name))                      
        line = "const int32_t {}[{}_HEIGHT] = {{\n".format(name, name, name) 
        file.write(line)
        # bit_seq = ""        # N bits sequence
        # bit_seq_last = ""        # N bits sequence
        # const_seq = ""      # 16-N bits sequence

        firstline = True    # skip the first line
        # read the file line by line and extract every number
        tempArray = []
        tempArray2 = []
        i = 0
        n = 0
        bit_seq = ""
        bit_seq_comb = ""
        # for i in range(int(HEIGHT)%(numSamplesInReg[N-3][0]+numSamplesInReg[N-3][1])):
        #     bit_seq_comb = bit_seq_comb + "0"*N
        #     if len(bit_seq_comb)/N >= numSamplesInReg[N-3][0]:
        #         tempArray2.append(int(bit_seq_comb,2))
        #         bit_seq_comb = ""
        #         i=i+1
        for line in sequence:
            if firstline:                               # skip the first line
                firstline = False                       # and set the flag to false
                continue                                # skip this iteration of the loop
            for char in line:                                   # for every char in the line
                if char == "0" or char == "1":                  # if it is a 0 or 1
                    bit_seq = char + bit_seq                    # add it to the sequence
                    if len(bit_seq) == N:                # if the sequence is N long
                        bit_seq_comb = bit_seq + bit_seq_comb
                        # bit_seq_comb = const_seq + bit_seq + bit_seq_comb
                        bit_seq = ""
                        # n = n+1
                        if ((i+1) % 2 == 0):
                            if len(bit_seq_comb)/N >= numSamplesInReg[N-3][0]:
                                tempArray2.append(int(bit_seq_comb,2))
                                bit_seq_comb = ""
                                i=i+1
                        else:
                            if len(bit_seq_comb)/N >= numSamplesInReg[N-3][1]:
                                tempArray.append(int(bit_seq_comb,2))
                                bit_seq_comb = ""
                                i=i+1
                            # n = 0
                            # print("temp1 = ", tempArray)
                            # print("temp2 = ", tempArray2)
    if (N_MAX != 0):   # if N_MAX is set
        print("WARNING: N_MAX is set. Check that version is parametrizable.")

        file = open(path, "a")
        saveConstCoefficients(path, math.ceil(2*((int(HEIGHT)/(numSamplesInReg[N_MAX-3][0]+numSamplesInReg[N_MAX-3][1])))), "{}_HEIGHT".format(name))                      
        line = "const int32_t {}[{}_HEIGHT] = {{\n".format(name, name, name) 
        file.write(line)
        # bit_seq = ""        # N bits sequence
        # bit_seq_last = ""        # N bits sequence
        # const_seq = ""      # 16-N bits sequence

        firstline = True    # skip the first line
        # read the file line by line and extract every number
        tempArray = []
        tempArray2 = []
        i = 0
        n = 0
        bit_seq = ""
        bit_seq_comb = ""
        const_bit_seq = "0"*(N_MAX-N)

        for line in sequence:
            if firstline:                               # skip the first line
                firstline = False                       # and set the flag to false
                continue                                # skip this iteration of the loop
            for char in line:                                   # for every char in the line
                if char == "0" or char == "1":                  # if it is a 0 or 1
                    bit_seq = char + bit_seq                    # add it to the sequence
                    if len(bit_seq) == N:                # if the sequence is N long
                        bit_seq_comb = const_bit_seq + bit_seq + bit_seq_comb
                        # bit_seq_comb = const_seq + bit_seq + bit_seq_comb
                        bit_seq = ""
                        # n = n+1
                        if ((i+1) % 2 == 0):
                            if len(bit_seq_comb)/N_MAX >= numSamplesInReg[N_MAX-3][0]:
                                tempArray2.append(int(bit_seq_comb,2))
                                bit_seq_comb = ""
                                i=i+1
                        else:
                            if len(bit_seq_comb)/N_MAX >= numSamplesInReg[N_MAX-3][1]:
                                tempArray.append(int(bit_seq_comb,2))
                                bit_seq_comb = ""
                                i=i+1
                            # n = 0
                            # print("temp1 = ", tempArray)
                            # print("temp2 = ", tempArray2)

    for line in tempArray:
        file.write(str(line)  + ",\n")
    for line in tempArray2:
        file.write(str(line)  + ",\n")


    if bit_seq_comb != "":                               # if the sequence is not empty
        file.write(str(int(bit_seq_comb,2)) )             # write it to the file
    file.write("};\n\n")                              # close the array
    file.close()                                    # close the file
    print("Info: control sequence saved") 



def saveControllSequence(path, controlSequencePath, name):
    # Used to save control sequence to file when not using LUT

    sequenceFile = open(controlSequencePath, "r")
    sequence = sequenceFile.readlines()
    sequenceFile.close()
    heighth = sequence[0].split(" ")[0]
    width = sequence[0].split(" ")[1]

    file = open(path, "a")
    
    saveConstCoefficients(path, heighth, "{}_HEIGHT".format(name))
    saveConstCoefficients(path, width, "{}_WIDTH".format(name))
    line = "const int32_t {}[{}_HEIGHT][{}_WIDTH] = {{\n".format(name, name, name)
    file.write(line)
    for index, line in enumerate(sequence):
        # line = line.replace("0", "-1")
        if index > 0 and index < len(sequence)-1:
            line = line.replace("\n", "},\n")
            line = "{"+line
            file.write(line)  
        if index == len(sequence)-1:
            line = line.replace("\n", "}};")
            line = "{"+line
            file.write(line)
    file.write("\n\n#endif")
    file.close()  





# Write h matrix values to file
def writeHMatrixToFile(path, matrix):
    print("Info: Writing H matrix to file")
    file = open(path, "w+")
    hRow, hCol = matrix.shape
    for i in range(hRow):
        for j in range(hCol):
            line = "{:08x}\n".format((int(matrix[i][j]) & 0xFFFFFFFF), '08x')
            file.write(line)
    # np.savetxt(file, matrix, delimiter='\n',fmt="%d")
    file.close()

def writeSMatrixToFile(path, sequencePath):
    print("Info: Writing S matrix to file")
    sequenceFile = open(sequencePath, "r")
    sequence = sequenceFile.readlines()
    sequenceFile.close()
    heighth = sequence[0].split(" ")[0]
    width = sequence[0].split(" ")[1]

    file = open(path, "w+")
    for index, line in enumerate(sequence):
        if index > 0 and index:
            line = line.replace(",", "")
            line = line.replace(" ", "")
            file.write(line)
    file.close()