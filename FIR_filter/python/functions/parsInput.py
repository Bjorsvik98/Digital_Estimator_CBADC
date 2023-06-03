from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

def parsFunc():
    parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
    parser.add_argument("-N", "--Nvec", default=6, help="the size of N")
    parser.add_argument("-b", "--beta", default=6250.0, help="the size of beta")
    parser.add_argument("-r", "--rho", default=-1e-2, help="the size of rho")
    parser.add_argument("-k", "--kappa", default=-1.0, help="the size of kappa")
    parser.add_argument("-a", "--amplitude", default=0.8, help="the amplitude of the input signal") ## anaog signal
    parser.add_argument("--OSR", default=1<<9, help="Choose the oversampling ratio (OSR)") ## anaog signal
    parser.add_argument("--offset", default=0, help="Choose the offset of the input sinusodial signal") ## anaog signal
    parser.add_argument("-s", "--sizeBits", default=16, help="Choose number of bits in the size of the signal")
    parser.add_argument("--eta2", default=1e6)
    parser.add_argument("-K1", "--K1", default=20)
    parser.add_argument("-K2", "--K2", default=20)
    parser.add_argument("--DSR", default=1)
    parser.add_argument("--bits", "--bitsUsed", default=16, help="Number of float bits to use")
    parser.add_argument("-o", "--outputFormat", default="1", help="1 = space as delimiter, 2 = comma as delimiter")
    parser.add_argument("--fraction", "--fractionBits", default=14, help="Number of fraction bits to use")
    parser.add_argument("--LUT", "--LUT_size", default=1, help="Number of elements merged together in a LUT")
    parser.add_argument("--coreName", "--coreName", default="Ibex", help="Name of the core")
    parser.add_argument("--freq", "--frequency", default=1, help="Frequence multiplier for the input signal")
    parser.add_argument("--lut_state", "--lut_state", default=0, help="0 = LUT off, 1 = LUT on")
    parser.add_argument("--ibex_state", default=0, help="0 = Ibex off, 1 = Ibex on")
    parser.add_argument("--pipeline_delay", default=0, help="determen how much the pipeline delay is")
    parser.add_argument("--ENOB", default=20, help="Set the ENOB")
    parser.add_argument("--BW", default=1e6, help="Set the Bandwidth")
    parser.add_argument("--N_MAX", default=0, help="Set max N for parametrizable accelerator, default is 0")
    parser.add_argument("--K_MAX", default=0, help="Set max K for parametrizable accelerator, default is 0")


    args = vars(parser.parse_args())
    # Set up parameters
    N = args["Nvec"]
    beta = args["beta"]
    rho = args["rho"]
    kappa = args["kappa"]
    amplitude = args["amplitude"]
    OSR = args["OSR"]
    offset = args["offset"]
    sizeBits = args["sizeBits"]
    size = 1 << int(sizeBits)
    eta2 = args["eta2"]
    K1 = int(args["K1"])
    K2 = int(args["K2"])
    DSR = int(args["DSR"])
    bits_used = int(args["bits"])
    outputFormat = int(args["outputFormat"])
    fraction_bits = int(args["fraction"])
    LUT_size = int(args["LUT"])
    coreName = args["coreName"]
    freq = args["freq"]
    lut_state = args["lut_state"]
    ibex_state = args["ibex_state"]
    pipeline_delay = args["pipeline_delay"]
    ENOB = float(args["ENOB"])
    BW = int(args["BW"])
    N_MAX = int(args["N_MAX"])
    K_MAX = int(args["K_MAX"])

    return N, beta, rho, kappa, amplitude, OSR, offset, size, eta2, K1, K2, DSR, bits_used, fraction_bits, outputFormat, LUT_size, coreName, freq, lut_state, ibex_state, pipeline_delay, ENOB, BW, N_MAX, K_MAX


 


