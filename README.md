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
```
To be completed ...
```

### Error Analysis
```
To be completed ...
```