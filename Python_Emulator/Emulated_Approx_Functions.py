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

def Approx_Multiply(multOp1, multOp2):
    '''
    The first operand (multOp1) is first converted to (2,5,1) float, Mantissa is multiplied by multOp2.
    The result is then converted back to fixed point.
    '''
    multOp1Abs = np.abs(multOp1)
    # Encoding to floating point
    exponent = np.floor(np.log2(multOp1Abs)) - 4
    if exponent < 0: 
        exponent = 0
    if multOp1 >= 0:
        mantissa = np.floor(multOp1Abs / pow(2,exponent))  # 5-bit mantissa
    else:
        mantissa = np.floor(multOp1Abs / pow(2,exponent))  # 5-bit mantissa
    # Multiplying the Mantissa
    resMantissa = round (mantissa * np.abs(multOp2) / 128)
    # Decoder: back to fixed point
    result = resMantissa * pow(2, exponent)  
    # Fixing sign of the result
    if multOp1 * multOp2 < 0:
        result = -result   

    print(f'\nOperand1: {multOp1}   exponent: {exponent},   mantissa: {mantissa},    resMantissa = {resMantissa}    Operand2: {multOp2},    result: {result}\n')

    return result 