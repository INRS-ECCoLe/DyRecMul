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
#  Author: Mobin Vaziri
#
#  Project: Reconfigurable MAC
#  
#  Creation Date: 2023-06-18
#
#  Description: Statistical tests for the approximate multiplier. 
#---------------------------------------------------------------------------



import numpy as np
import re
import csv


'''
Extract the numbers from the .h file and append them to a 2D Numpy array.

'''

def extract_array_elements(header_file_path, bitWidth: int):
    
    
    with open(header_file_path, "r") as file:
        
        content = file.read()

    
    start_index = content.find('{')

    
    elements = re.findall(r"-?\d+", content[start_index:])
    
    
    lut_data = np.array(elements, dtype = np.int64)
        
    
    lut_data = lut_data.reshape((2**bitWidth, 2**bitWidth))

    return lut_data


'''
Calculate statistical tests.

'''

def stat_tests (ExactMul, ApproxMul, bitWidth: int, signed: bool):
    
    ExactMul = ExactMul.flatten()
    ApproxMul = ApproxMul.flatten()
    
    
    if (signed == True):
        
        coeff = ((1) / (2 ** (2 * (bitWidth - 1))))
        
    else:
        
        coeff = ((1) / (2 ** (2 * (bitWidth))))
        
    
    # Error Distance
    ED = ExactMul - ApproxMul

    # Error Probability
    EP = np.sum(ED != 0) / ED.shape[0]
    
    # Mean Absolute Error
    MAE = coeff * np.sum(np.abs(ED))
    
    # Mean Relative Error Distance
    MRED = coeff * sum(ed / exactmul for ed, exactmul in zip(ED, ExactMul) if exactmul != 0)

    # Mean Squared Error
    MSE = coeff * np.sum(np.power(ED, 2))
    
    # Normalised Error Distance
    NED = coeff * np.sum(np.divide(ED, max(ED)))
    
   
    
    return (EP, MAE, MRED, MSE, NED)



'''
Write the results to a csv file.

'''

def write_stat_values_to_csv(ExactMul, ApproxMul, bitWidth: int, signed: bool, approx_name, file_path):
    results = stat_tests(ExactMul, ApproxMul, bitWidth, signed)
    

    with open(file_path, 'a', newline='') as csvfile:
        
        writer = csv.writer(csvfile)

        
        writer.writerow([])

        
        results_exist = False
        with open(file_path, 'r', newline='') as csvfile:
            reader = csv.reader(csvfile)
            for row in reader:
                
                if len(row) == 2:
                    if row[0] == 'Error Probability' and row[1] == str(results[0]):
                        results_exist = True
                        break
    
        
        if results_exist:
            return
    
        
        writer.writerow(['ApproxMul:', approx_name])

        
        writer.writerow([])

        
        writer.writerow(['Error Probability', results[0]])
        writer.writerow(['Mean Absolute Error', results[1]])
        writer.writerow(['Mean Relative Error Distance', results[2]])
        writer.writerow(['Mean Squared Error', results[3]])
        writer.writerow(['Normalised Error Distance', results[4]])








