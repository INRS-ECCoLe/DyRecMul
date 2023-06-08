import numpy as np

def Approx_Multiply(multOp1, multOp2):
    '''
    The first operand (multOp1) is first converted to (2,5,1) float, Mantissa is multiplied by multOp2.
    The result is then converted back to fixed point.
    '''
    multOp1Abs = np.abs(multOp1)
    exponent = np.floor(np.log2(multOp1Abs)) - 4
    if exponent < 0: 
        exponent = 0

    if multOp1 >= 0:
        mantissa = np.floor(multOp1Abs / pow(2,exponent))  # 5-bit mantissa
    else:
        mantissa = np.ceil(multOp1Abs / pow(2,exponent))  # 5-bit mantissa

    resMantissa = round (mantissa * np.abs(multOp2) / 256)

    result = resMantissa * pow(2, exponent)  # back to fixed point

    if multOp1 * multOp2 < 0:
        result = -result   # Fixing sign of the result

    print(f'\nOperand1: {multOp1}   exponent: {exponent},   mantissa: {mantissa},       Operand2: {multOp2},    result: {result}\n')

    return result 