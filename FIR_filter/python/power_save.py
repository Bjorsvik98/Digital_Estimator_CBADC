lut_p = 7.436e-03
rcw_p = 9.168e-03
tot_p = 0.0117

lut_save = 1-(lut_p/tot_p)
rcw_save = 1-(rcw_p/tot_p)

save_p = rcw_p * (1-lut_save)
tot_save1 = 1 - (save_p / tot_p)
tot_save2 = 1 - (1 - lut_save )* (1-rcw_save)

print("tot_save1 = ", tot_save1)
print("tot_save2 = ", tot_save2)


