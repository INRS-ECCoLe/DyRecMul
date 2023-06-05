
#---------------------------------------------------------------------------
#                ___________
#    ______     /   ____    ____      _          ______
#   |  ____|   /   /    INRS    \    | |        |  ____|
#   | |       /   /     Edge     \   | |        | |
#   | |____  /   /    Computing   \  | |        | |____
#   |  ____| \   \  Communication /  | |        |  ____|   
#   | |       \   \   Learning   /   | |        | |
#   | |____    \   \_____LAB____/    | |_____   | |____
#   |______|    \ ___________        |_______|  |______|
#
#  Edge Computing, Communication and Learning Lab - INRS University
#
#  Author: Shervin Vakili
#
#  Project: Reconfigurable MAC
#  
#  Creation Date: 2022-03-14
#
#  Description: reconfig_mac emulates approximate MAC calculation in our 
#               new FPGA-based reconfigurable MAC architecture. 
#---------------------------------------------------------------------------

import numpy as np


def reconfig_mac( multOp1, multop2, accOp, rangeMax):
    def quantize(inOp, rangeMax, bitWidth):
        ampBitWidth = bitWidth - 1 # bitwidth without sign
        if rangeMax == 0:
            return -1
        elif rangeMax < pow(2,ampBitWidth):
            shiftSize = ampBitWidth - np.floor(np.log2(rangeMax) + 1)
            aa = round(inOp* pow(2,shiftSize))
        
        print('--', shiftSize, aa)

    quantize(multOp1, rangeMax, 8)

reconfig_mac( 2, 2, 3, 3.99)
