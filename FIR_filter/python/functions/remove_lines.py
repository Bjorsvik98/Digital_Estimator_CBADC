import os
    
def remove_lines_with_pattern(file_path, pattern):
    # Read the file contents
    with open(file_path, 'r') as file:
        lines = file.readlines()

    # Remove lines containing the pattern
    lines_filtered = []
    first_line_encountered = False

    for line in lines:
        if pattern in line:
            if not first_line_encountered:
                first_line_encountered = True
                lines_filtered.append(line)
        else:
            lines_filtered.append(line)
            first_line_encountered = False

    # Write the updated contents back to the file
    with open(file_path, 'w') as file:
        file.writelines(lines_filtered)




def remove_lines_with_pattern_folder(folder_path, pattern):
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file.endswith('.log'):
                file_path = os.path.join(root, file)
                remove_lines_with_pattern(file_path, pattern)



file_path = '/home/sp22/Masteroppgave/FIR/powerResults/pico/acc_mc_paramKN_downsample_new_K_MAX512_N_MAX8_N_5_K_320/pwr_est-DC.log'
pattern = 'Last event time = '

# remove_lines_with_pattern(file_path, pattern)
remove_lines_with_pattern_folder('/home/sp22/Masteroppgave/FIR/python/sim_scripts', pattern)