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
def Save_LUT_CSV(LUT):
  np.savetxt('LUT.csv', LUT, delimiter=',')
  return
