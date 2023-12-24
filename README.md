# Project Description

Design of 32bits MIPS Pipelined processor using VHDL and verification using UVM in System Verilog.
The Design phase is divided into two sub projects:

## Design of a One Cycle MIPS Processor
The goal of this project was to design a 32-bit processor using the MIPS architecture. In this design, each instruction goes through five stages – IF, ID, EX, DM, and WB – and is completed in one cycle.

The processor is capable of handling various simple instructions from the MIPS Instruction Set Architecture (ISA), such as ADD, SUB, AND, ADDI, BRANCH, LOAD, STORE, and JUMP.

To build this processor, we used structural modeling in VHDL, using different components (that we designed) like the Program Counter, Instruction Memory (IM), Register File (RF), Control Unit, ALU Control, Arithmetic Logic Unit (ALU), Data Memory (DM), Multiplexers, Sign Extend Unit, and Adders.

## Design of a Pipelined MIPS Processor
This is the continuation of the one cycle MIPS processor project, We’re using pipelining to improve the performance of the processor by increasing its throughput and decreasing the execution time of programs in our processor. 

**Pipelining Approach**
We divided the instruction process into stages using D flip flops. This made each instruction take 5 cycles, but it also significantly reduced the time it takes for each cycle. In the end, our processor can now execute one instruction in each cycle, making it about 5 times faster than before. 

## overview of the processor

**one cycle processor**

![Alt text](statics/singlecycle.png)

**pipelined processor**
![Alt text](statics/pipelined.png)


## testing and verification

1. **R type without dependencies:**
    the following instructions were executed on the processor: 

		"00000001101101010100000000100000"  --add $t0,$t5,$s5
		"00000001101101010100000000100010",  --sub $t0,$t5,$s5
		"00000001101101010100000000100100",  --and $t0,$t5,$

    simulating on modelsim, we obtained the following waveforms:
    ![Alt text](./statics/Waveforms/Rtype-%20no%20dependencies.png)

## Difficulties Encountered:

1. **Data Memory**: The data memory component was defined as a synchronous RAM, presenting limitations in manipulating it and getting the read data after writing it to the memory. To address this, we introduced a Reset signal, enabling its synthesis as registers. While this solution may not be the most optimal for memory management, it allowed us to progress.

2. **Forwarding Unit**: A specific challenge arose when handling sw instructions with dependencies between the last and the next instructions. We observed incorrect forwarding behavior in such cases. Solution: we introduced an additional condition that checks if the destination register (RD) is the same in the EX/MEM and MEM/WB stages, but with different regwrite values (0 in EX/MEM and 1 in MEM/WB).

3. **Register File**: The Register File faced a constraint where it couldn't read and write simultaneously. To overcome this challenge, we adapted the design from registers to latches by modifying the clock condition from `rising_edge(Clock)` to `(Clock = '0')`.

4. **multiplexer**: refused to work with a process statement, they give undefined outputs when implimented using a behavioral implimentation, however after changing the MUXs to a datapath implimentation everything worked as expected, we have yet to figure out what caused this. specially since it worked fine during the testing phase in Quartus university waveform functional simulation. 






[Rtype-without-dependecies]: ./statics/Waveforms/R%20type%20instructions%20without%20dependencies.pdf
