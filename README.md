# YODA

#### YODA PRNG Project Verilog Code and Final Report 
YODA (Your Own Digital Accelerator) 
This project is run each year in the high performance embedded systems final year course. 
It sees students put into groups to develop a digital accelerator on the parallel Field Programmable Gate Array (FPGA).

Our group's goal was to develop a parallel random number generator on the FPGA and compare it to a golden measure C++ version. 
Both measures implemeneted the same algorithm to produce the random numbers and thus made for a fair comparision.

Further details on the algorithm and investigations of the project can be found in the project report file.

Just to explain the difference in files:

BRAM2 (Project files):
- This is a stress tested version of the project.
- It ONLY writes to BRAM and there is no read or reset implementation.
- However, this was the project used to conduct the test in the result section.
- It is therefore well tested and the main features are present.


PRNG Wr Re and Reset Project (Project files):
- This version has all luxurious features such as write, read and reset.
- The code works, however there was not sufficient time to stress it
	and ensure it works for most cases.


PRNG Wr Re and Reset Modules Only 
- contains only the .v files for the luxurious version

PRNG Wr to BRAM Module Only
- contains only the .v files for the stress tested version

YODA_RNG cpp file
- contains the .cpp file for the Golden Measure. 
© 2021 GitHub, Inc.
