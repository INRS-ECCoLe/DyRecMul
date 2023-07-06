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

#Generate LUT and save them as .h and .csv
import numpy as np

from save_lut_c import Save_LUT_C
from save_lut_csv import Save_LUT_CSV
from save_lut_c_quantize import Save_LUT_C_QUANTIZE

def Generate_LUT():

  Save_LUT_CSV()
  Save_LUT_C()
  for ii in range(5,9):
    Save_LUT_C_QUANTIZE(ii)

Generate_LUT()
