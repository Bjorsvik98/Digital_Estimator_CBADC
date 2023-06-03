# convert from signed 2's complement hex to decimal 
import sys

convertType = sys.argv[1]
simulator = sys.argv[2]
samples = 2**int(sys.argv[3])
output_hex_file = sys.argv[4]
pipeline_delay = int(sys.argv[5])


def twos_complement(hex_string, bits):
    value = int(hex_string, 16)
    if value & (1 << (bits - 1)):
        value -= 1 << bits
    return value

# print(twos_complement('fff9c43c', 32))


# convert resultHex.txt to decimal

def convert_to_decimal(filename, writeFilename):
    print("Info: Converting hex to decimal")
    f = open(filename, "r+")
    writeFile = open(writeFilename, "w+")

    lines = f.readlines()
    for line in lines:
        # print(twos_complement(line, 32))
        line = "{}\n".format(twos_complement(line, 32))
        writeFile.write(line)

def convert_to_decimal_some_lines(filename, writeFilename, startLine, endLine):
    # print("Info: Converting lines " + startLine + " to " + endLine + " hex to decimal")
    f = open(filename, "r+")
    writeFile = open(writeFilename, "w+")

    lines = f.readlines()
    fist = True
    for i, line in enumerate(lines[0:30000]):
        # print the index of the line

        if startLine <= i <= endLine:
            line = "{}\n".format(twos_complement(line, 32))
            writeFile.write(line)
            
# convert_to_decimal('resultHex.txt', 'resultDecimal.txt')
print("Info:", output_hex_file, "is being converted to decimal and the result can be found in ../hex_files/resultDecimal.txt")
if convertType == "Pico":
    convert_to_decimal_some_lines(output_hex_file, '../hex_files/resultDecimal.txt', 100, samples+100)
elif convertType == "Pico_accelerated":
    convert_to_decimal_some_lines(output_hex_file, '../hex_files/resultDecimal.txt', 100+pipeline_delay-2, samples+100+pipeline_delay)
elif convertType == "Ibex":
    if simulator == "Verilator":
        convert_to_decimal_some_lines(output_hex_file, '../hex_files/resultDecimal.txt', 0, samples)
    elif simulator == "Vcs":
        convert_to_decimal_some_lines(output_hex_file, '../hex_files/resultDecimal.txt', 0, samples)
    else:
        print("Error: Wrong simulator")
else:
    print("Error: Wrong convertType")

# convert_to_decimal('../hex_files/resultHex.txt', '../hex_files/resultDecimal.txt')