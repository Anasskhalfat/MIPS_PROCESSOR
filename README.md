# Project Description

Design of 32bits Pipelined processor using VHDL and verification using UVM in System Verilog 

## Report of Advancement:

- 09-14: creating of individual components for one cycle processor
- 16-21: piecing together the individual components to complete the one cycle processor
- 23-28: creating the pipeline processor, creating stages for data and control signals
- 30-40: adding forwardi unit, hazard unit and starting branch prediction logic

## Difficulties Encountered:

1. **Data Memory**: The data memory component was defined as a synchronous RAM, presenting limitations in manipulating it and getting the read data after writing it to the memory. To address this, we introduced a Reset signal, enabling its synthesis as registers. While this solution may not be the most optimal for memory management, it allowed us to progress.

2. **Forwarding Unit**: A specific challenge arose when handling sw instructions with dependencies between the last and the next instructions. We observed incorrect forwarding behavior in such cases. To rectify this, we introduced an additional condition that checks if the destination register (RD) is the same in the EX/MEM and MEM/WB stages, but with different regwrite values (0 in EX/MEM and 1 in MEM/WB).

3. **Register File**: The Register File faced a constraint where it couldn't read and write simultaneously. To overcome this challenge, we adapted the design from registers to latches by modifying the clock condition from `rising_edge(Clock)` to `(Clock = '0')`.
