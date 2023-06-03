import sys

starting_line = int(sys.argv[1]) # starting line number (inclusive)
ending_line = int(sys.argv[2]) # ending line number (inclusive)
input_file = sys.argv[3] # input file name


with open(input_file, "r") as f:
    lines = f.readlines()

with open(input_file, "w") as f:
    for i in range(len(lines)):
        if i >= starting_line-1 and i <= ending_line-1:  # check if line number is within range
            line = lines[i].strip()  # remove whitespace characters from line
            if line != "00000000":  # check if line contains anything other than zeros
                f.write(line + "\n")  # write line to new file
        else:
            f.write(lines[i])  # write line to new file (no modifications)

print("Info: lines containing zeros removed from line %s to line %s in file %s" % (starting_line, ending_line, input_file))