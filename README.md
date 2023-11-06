# Project Description

Design of 32bits Pipelined processor using VHDL and verification using UVM in System Verilog 

## Report of Advancement:

- 09-14: creating of individual components for one cycle processor
- 16-21: piecing together the individual components to complete the one cycle processor
- 23-28: creating the pipeline processor, creating stages for data and control signals
- 30-40: adding forwardi unit, hazard unit and starting branch prediction logic

## Difficulties Encountered:
- Data Memory: defined as a synchronous RAM, and cannot read in the same cycle and cannot read what we write.
Soluction: Add Reset signal so it can be syntheiszed as registers (not optimal solution for a memory).
- Forwarding Unit: not forwarding correctly in case of a sw instruction with dependance between the last and the next instructions.
Solution: Add another condition when the RD is the same in the EX/MEM and MEM/WB stages but regwrite is 0 in EX/MEM and 1 in MEM/WB.
- Register File: can't read and write at the same time. Can pose problems in case of reading the same regiseter we are writing into.
Solution: Change the desing from Register into latches by changing the clock condition from rising_edge(Clock) to (Clock = '0').
