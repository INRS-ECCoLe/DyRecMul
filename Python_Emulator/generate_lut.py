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
def Generate_LUT(bitwidth_Op1, bitwidth_Op2):

  NPV1 = pow(2, bitwidth_Op1)        #Number of possible values for Op1
  NPV2 = pow(2, bitwidth_Op2)        #Number of possible values for Op2
  LUT = np.zeros((NPV1, NPV2))

  for i in range(NPV1):
    for j in range(NPV2):
      LUT[i, j] = Approx_Multiply(i- pow(2, bitwidth_Op1- 1), j- pow(2, bitwidth_Op2- 1))
      #LUT[i, j] = Approx_Multiply(quantize(i- pow(2, bitwidth_Op1- 1), pow(2, bitwidth_Op1- 1)-1, bitwidth_Op1), quantize(j- pow(2, bitwidth_Op2- 1), pow(2, bitwidth_Op2- 1)-1, bitwidth_Op2))      #if you want to quantize Ops before Multiplying

  Save_LUT_CSV(LUT)
  Save_LUT_C()
  return LUT
