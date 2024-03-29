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
#  Edge Computing, Communication and Learning Lab
#
#  Author: Shervin Vakili, INRS University
#
#  Project: Reconfigurable MAC
#  
#  Creation Date: 2023-06-08
#---------------------------------------------------------------------------

import numpy as np

# ---------------------------------------
def Approx_Multiply_Signed(multOp1, multOp2):
    '''
    The first operand (multOp1) is first converted to (2,5,1) float, Mantissa is multiplied by multOp2.
    The result is then converted back to fixed point. This version handles -128 by saturation (converts it to -127)
    '''
    multOp1Abs = np.abs(multOp1)

    if multOp1Abs == 0:
        exponent = 0
    else:
        exponent = np.floor(np.log2(multOp1Abs)) - 4
        if exponent < 0:
            exponent = 0
    if multOp1 == -128: # Corner case
        mantissa = 31
        exponent = 2
    else: 
        mantissa = np.floor(multOp1Abs / pow(2,exponent))  # 5-bit mantissa
    
    # Multiplying the Mantissa
    resMantissa = round (mantissa * np.abs(multOp2) / 128)
    # Decoder: back to fixed point
    result = round(resMantissa * pow(2, exponent))
    # Fixing sign of the result
    if multOp1 * multOp2 < 0:
        result = -result

    #print(f'\nOperand1: {multOp1}   exponent: {exponent},   mantissa: {mantissa},    resMantissa = {resMantissa}    Operand2: {multOp2},    result: {result}\n')
    return result 

def Approx_Multiply_Unsigned(multOp1, multOp2):
    '''
    The first operand (multOp1) is first converted to (2,5,1) float, Mantissa is multiplied by multOp2.
    The result is then converted back to fixed point. This version handles -128 by saturation (converts it to -127)
    '''
    multOp1Abs = np.abs(multOp1)

    if multOp1Abs == 0:
        exponent = 0
    else:
        exponent = np.floor(np.log2(multOp1Abs)) - 4
        if exponent < 0:
            exponent = 0

    mantissa = np.floor(multOp1Abs / pow(2,exponent))  # 5-bit mantissa
    
    # Multiplying the Mantissa
    resMantissa = round (mantissa * np.abs(multOp2) / 128)
    # Decoder: back to fixed point
    result = round(resMantissa * pow(2, exponent))

    #print(f'\nOperand1: {multOp1}   exponent: {exponent},   mantissa: {mantissa},    resMantissa = {resMantissa}    Operand2: {multOp2},    result: {result}\n')
    return result 

# ----------------------------------------------
def Quantized_Multiply(multOp1, multOp2, qBits):
    '''
    Emulating simply quantized operands.
    '''
    if multOp1 < 0:
        multOp1Q = np.ceil(multOp1/pow(2,qBits))
    else:
        multOp1Q = np.floor(multOp1/pow(2,qBits))

    if multOp2 < 0:
        multOp2Q = np.ceil(multOp2/pow(2,qBits))
    else:
        multOp2Q = np.floor(multOp2/pow(2,qBits))
    
    result = multOp2Q * multOp1Q

    return result 