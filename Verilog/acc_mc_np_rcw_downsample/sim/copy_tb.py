import sys

input_file = sys.argv[1]
output_file = sys.argv[2]
design_name_file = sys.argv[3]
vcd_file_name = sys.argv[4]
fast_mode = sys.argv[5]

with open(design_name_file, 'r') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if '# design' in line:
        content = line.split('# design ')[1].strip()
        print("Changing the module name to " + content)
        break




# open input file and read all lines
with open(input_file, 'r') as f:
    lines = f.readlines()

new_lines = []
remove = False

for line in lines:
    if 'picorv32_top' in line:
        new_lines.append(content +'\n')
        remove = True
    if 'chip' in line:
        remove = False
    if not remove:
        new_lines.append(line)

    # if fast_mode != 'fast':
    #     if "initial begin" in line:
    #         # Add $dumpfile() command after initial begin
    #         # new_lines.append(line)
    #         new_lines.append("\t\t$dumpfile(\"%s\");\n" % vcd_file_name)
    #         new_lines.append("\t\t$dumpvars(0, chip);\n")
    #         new_lines.append("\t\t$dumpoff;\n")
    #     elif "$dumpon;" in line:
    #         new_lines.append("\t\t\t$dumpon;\n")
    #     elif "$dumpoff;" in line:
    #         new_lines.append("\t\t\t$dumpoff;\n")



with open(output_file, 'w') as f:
    f.writelines(new_lines)
    



