# Reconfigurable MAC
 

## Table of contents
* [Description](#Description)
* [Technologies](#Technologies)
* [Requirements](#Requirements)

## Description
DyRecMul is an original FPGA-based approximate multiplier specifically optimized for machine learning computations. It utilizes dynamically reconfigurable lookup table (LUT) primitives in AMD-Xilinx technology to realize the core part of the computations. Implementation results on an AMD-Xilinx Kintex Ultrascale+ FPGA demonstrate remarkable savings of 64% and 67% in LUT utilization for signed multiplication and multiply-and-accumulation configurations, respectively, when compared to the standard Xilinx multiplier core. Accuracy measurements on four popular deep learning (DL) benchmarks indicate a minimal average accuracy decrease of less than 0.29% during post-training deployment, with the maximum reduction staying less than 0.33%.

DyRecMul has been innovated and developed at the Edge Computing, Communication, and Learning Lab at INRS University in close collaboration with Prof. Pierre Langlois' research group at Polytechnique Montréal.
	
## Technologies
* VHDL 1993
* AMD_Xilinx Vivado ML 2022.2
* Python 3.10
	
## Requirements
$ pip install numpy matplotlib

## Components
This repository consists of three components: hardware description at the RT level, error analysis, and accuracy measurement for deep learning inference.

### Hardware Design
DyRecMul_INT8.vhd: INT8 version of DyRecMul  
DyRecMul_UINT8.vhd: UNIT8 version of DyRecMul  
DyRecMul_MAC.vhd: MAC version of DyRecMul  
MAC_Testbench.vhd: Testbench of the MAC version of DyRecMul

### Error Analysis

### Accuracy measurement for deep learning inference
The accuracy of INT8 DyRecMul has been measured using AdaPT tool, available: https://github.com/dimdano/adapt/  
Custom approximate multipliers must be provided as C header files which contain a lookup table of all output values that the approximate multiplier generates for each possible combination of inputs.  
/Python_Emulator/generate_lut.py generates the lookup table files for INT8 DyRecMul as well as INT5 to INT8 exact multipliers in /Python_Emulator/Output_Files folder. 

