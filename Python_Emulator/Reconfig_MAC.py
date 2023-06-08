
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
from Emulated_Approx_Functions import Approx_Multiply


def quantize(inOp, rangeMax, bitWidth):
    absBitWidth = bitWidth - 1 # bitwidth without sign
    if np.abs(inOp) > np.abs(rangeMax):
        print('ERROR: inOp cannot be larger than rangeMax!')
        return -1
    if rangeMax == 0:
        print('ERROR: rangeMax cannot be zero!')
        return -1
    elif rangeMax < pow(2,absBitWidth):
        shiftSize = absBitWidth - np.floor(np.log2(np.abs(rangeMax)) + 1)
        quantizedResult = round(inOp * pow(2,shiftSize))  # Scaling and rounding
    else:
        shiftSize = np.floor(np.log2(np.abs(rangeMax)) + 1) - absBitWidth
        quantizedResult = round(inOp / pow(2,shiftSize))
        
    return quantizedResult

    print('--', shiftSize, quantizedResult, np.floor(np.log2(np.abs(rangeMax))))

    

multOp1 = 12
multOp2 = -40
rangeMax = 127
multOp1Q = quantize(multOp1, rangeMax, 8)
multOp2Q = quantize(multOp2, rangeMax, 8)
print(f'--- rangeMax = {rangeMax}   Operand = {multOp1}  Quantized Operand  = {multOp1Q}')
print(f'--- rangeMax = {rangeMax}   Operand = {multOp2}  Quantized Operand = {multOp2Q}')

Approx_Multiply(multOp1Q, multOp2Q)
