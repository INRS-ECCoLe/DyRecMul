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
#  Author: Amirhossein Zarei
#
#  Project: Reconfigurable MAC
#
#  Creation Date: 2023-06-14
#
#  Description: reconfig_mac emulates approximate MAC calculation in our
#               new FPGA-based reconfigurable MAC architecture.
#---------------------------------------------------------------------------
#Make a .csv file containg Approximate Multiplier LUT
import numpy as np
from Emulated_Approx_Functions import Approx_Multiply

def Save_LUT_CSV():
  nbits = 8
  NPV = pow(2, nbits)        #Number of possible values for Op2
  LUT = np.zeros((NPV, NPV))

  for i in range(NPV):
    for j in range(NPV):
      LUT[i, j] = Approx_Multiply(i- pow(2, nbits- 1), j- pow(2, nbits- 1))

  np.savetxt('Output_Files\LUT.csv', LUT, delimiter=',')
  return
