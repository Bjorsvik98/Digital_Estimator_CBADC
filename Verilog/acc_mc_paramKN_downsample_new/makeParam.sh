N_start=3
N_Step=1
N_End=8
K=(256 320 320 448 448 512)

for N in $(seq $N_start $N_Step $N_End) 
do
    # for K in $(seq $K_start $K_Step $K_End)
    #     do
    echo ../../syn/DC/results_N_MAX${N}_K_MAX${K[N-3]}/picorv32_top.mapped.v > syn/DC/filesXcelium_N_MAX${N}_K_MAX${K[N-3]}.txt
    echo ../../sim/src/tb_picorv32_gls.v >> syn/DC/filesXcelium_N_MAX${N}_K_MAX${K[N-3]}.txt
    # done
done