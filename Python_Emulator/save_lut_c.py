# This code is a revised version of LUT Conversion Tool of AdaPT TEAM. The link of their code is https://github.com/dimdano/adapt/blob/main/tools/LUT_convert.ipynb
#
#  Revised By: Amirhossein Zarei
#
#  Project: DyRecMac
#
#  Creation Date: 2023-06-14
#
#  Description: generates lut.h file to be used for accuracy evaluation in AdaPT
#---------------------------------------------------------------------------

import numpy as np
from Emulated_Approx_Functions import Approx_Multiply_Signed
from Emulated_Approx_Functions import Approx_Multiply_Unsigned

#Make a .h file containg Approximate Multiplier LUT
def Save_LUT_C():
  nbits = 8
  # -- Signed
  with open('Output_Files\LUT_RECONF'+'.h', 'w') as myfile:
    bits = int(pow(2,nbits))
    lut_size_str = str(bits)

    myfile.write('#include <stdint.h>\n\n')
    myfile.write('const int' + str(2*nbits) + '_t lut [' + lut_size_str + '][' + lut_size_str +'] = {')

    for i in range (0,bits//2):
      myfile.write('{')
      for j in range (0,bits//2):
        x = int(Approx_Multiply_Signed(i,j) * 128)
        myfile.write('%s' % x)
        myfile.write(', ')
      for j in range (bits//2,bits):
        x = int(Approx_Multiply_Signed(i,(bits-j)*-1) * 128)
        myfile.write('%s' % x)
        if j!=bits-1:
          myfile.write(', ')
      myfile.write('},')
      myfile.write('\n')

    for i in range (bits//2,bits):
        myfile.write('{')
        for j in range (0,bits//2):
            x = int(Approx_Multiply_Signed((bits-i)*-1,j) * 128)
            myfile.write('%s' % x)
            myfile.write(', ')
        for j in range (bits//2,bits):
            x = int(Approx_Multiply_Signed((bits-i)*-1,(bits-j)*-1) * 128)
            myfile.write('%s' % x)
            if j!=bits-1:
                myfile.write(', ')
        if(i!=bits-1):
            myfile.write('},')
            myfile.write('\n')
    myfile.write('}};\n')

    # -- Unsigned
    with open('Output_Files\LUT_RECONF_UNSIGNED'+'.h', 'w') as myfile:
      bits = int(pow(2,nbits))
      lut_size_str = str(bits)

      myfile.write('#include <stdint.h>\n\n')
      myfile.write('const int' + str(2*nbits) + '_t lut [' + lut_size_str + '][' + lut_size_str +'] = {')

      for i in range (0,bits):
        myfile.write('{')
        for j in range (0,bits):
          x = int(Approx_Multiply_Signed(i,j) * 128)
          myfile.write('%s' % x)
          if j!=bits-1:
            myfile.write(', ')
        if(i!=bits-1):
          myfile.write('},')
          myfile.write('\n')
      myfile.write('}};\n')
  return