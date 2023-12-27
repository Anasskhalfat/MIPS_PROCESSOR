-- This is the main file of the pipelined MIPS processor project.

-- The processor is capable of handling various simple instructions from the MIPS Instruction Set Architecture (ISA),
-- such as ADD, SUB, AND, ADDI, BRANCH, LOAD, STORE, and JUMP.

-- Each instruction goes through five stages: IF (Instruction Fetch), ID (Instruction Decode), EX (Execution), DM (Data Memory Access), and WB (Write Back).
-- The instructions are excuted ideally in 5 cycles.
-- If there are dependacies the instruction could possibly trigger a stall or flash of the pipeline.

-- This file performs the following:
-- 1. Declare signals used in the processor, they are divided into five stages as per the MIPS architecture.
-- 2. Instantiate all the components of the processor and connect them to the signals previously declared.
-- 3. Simple data path instructions required in the processor: branch selecting logic, jump address composition.

-- Naming Convention : 
-- Signals : (Stage ID)_(Data Name)
-- Files Names : Full Name with _ between two words and first word letter is Maj

library IEEE; use IEEE.STD_LOGIC_1164.ALL; use IEEE.NUMERIC_STD.ALL;

entity MIPS_PROCESSOR is
	Port(
		Reset : in STD_LOGIC ;
		Clk   : in STD_LOGIC
	);
end entity;

architecture arch of MIPS_PROCESSOR is
	
--###################################  Constants  ######################################
signal One             : STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000001";

--################################  IF Stage Signals  ##################################
-- Program Counter
signal PC_In           : STD_LOGIC_VECTOR(31 downto 0);   -- Output of address selectors, Input of PC
signal PC_Out          : STD_LOGIC_VECTOR(31 downto 0);   -- Output of PC, Input of IM and BTB

-- Adder, calculates the next address
signal IF_Next_Address : STD_LOGIC_VECTOR(31 downto 0);   -- Output of adder: PC+4
signal ID_Next_Address : STD_LOGIC_VECTOR(31 downto 0);

-- Instruction Memory
signal IF_Instruction  : STD_LOGIC_VECTOR(31 downto 0);   -- Output of Instruction Memory
signal ID_Instruction  : STD_LOGIC_VECTOR(31 downto 0);   
signal EX_Instruction  : STD_LOGIC_VECTOR(31 downto 0);
signal DM_Instruction  : STD_LOGIC_VECTOR(31 downto 0);


-- BTB
signal Target_Address  : std_logic_vector(31 downto 0);   -- Output of BTB
signal IF_Hit          : std_logic;                       -- Hit signal to indicate if the branch address does exist in the BTB
signal ID_Hit          : std_logic;

-- Multiplexer for Flashing
signal Flush_MUX_Out   : STD_LOGIC_VECTOR(31 downto 0);   -- Output of the multiplexer: instruction or x"00000000"

-- Selector for the next address of the instruction
signal PC_Source_Select: STD_LOGIC_VECTOR(1 DOWNTO 0);

--################################  ID Stage Signals  ##################################
-- Register File
signal ID_Read_Data_1  : STD_LOGIC_VECTOR(31 downto 0);   -- First  output data of register file (Rs)
signal EX_Read_Data_1  : STD_LOGIC_VECTOR(31 downto 0);
signal ID_Read_Data_2  : STD_LOGIC_VECTOR(31 downto 0);   -- Second output data of register file (Rt)
signal EX_Read_Data_2  : STD_LOGIC_VECTOR(31 downto 0);
signal RF_Write_Data   : STD_LOGIC_VECTOR(31 downto 0);   -- The data to be written in the register file

--Sign Extend
signal ID_Immediate    : STD_LOGIC_VECTOR(31 downto 0);   -- Output of sign extend unit
signal EX_Immediate    : STD_LOGIC_VECTOR(31 downto 0); 

--Hazard unit
signal StallIF         : std_logic;                       -- Enable of Program Counter: stalls the IF stage
signal StallID         : std_logic;                       -- Enable of IF/ID flip flops: stalls the whole ID stage
signal CTRL_EN         : std_logic;                       -- Selector of control signals or 0 signals: to insert a bubble into the pipeline

-- Control Unit : goes throught a multiplexer, the multiplexer is used to insert a bubble in the pipeline
-- Generates the control signals for the processor: 0:NO, 1:YES (inputs of the multiplexers)
signal To_Mux_RegDst   : STD_LOGIC;
signal To_Mux_MemWrite : STD_LOGIC;
signal To_Mux_MemRead  : STD_LOGIC;
signal To_Mux_MemtoReg : STD_LOGIC;
signal To_Mux_ALUSrc   : STD_LOGIC;
signal To_Mux_ALUOp    : STD_LOGIC_VECTOR(1 downto 0);
signal To_Mux_Branch   : std_logic;
signal To_Mux_RegWrite : STD_LOGIC;
signal To_Mux_Jump     : std_logic;
signal IF_Flush        : STD_LOGIC;                        -- To flash the instruction from IF to ID stages

 -- Control Unit (outputs of the multiplexers)
signal MemWrite        : STD_LOGIC;                        -- Data Memory Write Operation
signal MemRead         : STD_LOGIC;                        -- Data Memory Read  Operation
signal MemtoReg        : STD_LOGIC;                        -- Data Memory/alu result selection
signal RegDst          : STD_LOGIC;                        -- Destination Address Selection
signal RegWrite        : STD_LOGIC;                        -- Register File write operation 
signal ALUSrc          : STD_LOGIC;                        -- ALU 2' input selection : Rt or immediate
signal ALUOp           : STD_LOGIC_VECTOR(1 downto 0);     -- ALU operation select
signal Branch          : std_logic;                        -- The current instruction is a branch
signal Jump            : std_logic;                        -- The current instruction is a jump

signal EX_MemWrite     : STD_LOGIC;
signal EX_MemRead      : STD_LOGIC;
signal EX_MemToReg     : STD_LOGIC;
signal EX_ALUSrc       : STD_LOGIC;
signal EX_ALUOp        : STD_LOGIC_VECTOR(1 downto 0);
signal EX_RegWrite     : STD_LOGIC; 
signal EX_RegDst       : STD_LOGIC;

signal DM_MemWrite     : STD_LOGIC;
signal DM_MemRead      : STD_LOGIC;
signal DM_MemToReg     : STD_LOGIC;
signal DM_RegWrite     : STD_LOGIC;

signal WB_MemToReg     : STD_LOGIC;
signal WB_RegWrite     : STD_LOGIC;

-- Jump
signal jump_address    : std_logic_vector(31 downto 0);   -- Jump address: "ID_Next_Address[31:28],00,Instr[25:0]"

-- Branch
signal Branch_Addr     : STD_LOGIC_VECTOR(31 downto 0);   -- Branch address: result of (ID_Next_Address + immediate value)
signal Bcond           : STD_LOGIC;                       -- A signal to indicate if Rs=Rt in case of branch
signal PCSrc           : std_logic;                       -- Address selecting signal: output of Control Unit

--Forward unit 1
signal FWD_U1_Sel1     : STD_LOGIC;
signal FWD_U1_Sel2     : STD_LOGIC;
signal FWD_U1_MUX1_Out : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal FWD_U1_MUX2_Out : STD_LOGIC_VECTOR(31 DOWNTO 0);

--################################  EXE Stage Signals  ##################################
-- Multiplexer, Chooses the write address between Rt and Rd
signal EX_Write_Addr   : STD_LOGIC_VECTOR( 4 downto 0);   -- The address to write data to in the register file
signal DM_Write_Addr   : STD_LOGIC_VECTOR( 4 downto 0);
signal WB_Write_Addr   : STD_LOGIC_VECTOR( 4 downto 0);

--ALU signals
signal ALUControl      : STD_LOGIC_VECTOR( 2 downto 0);    -- Input of ALU coming from ALUcontrol
signal ALU_In_1        : STD_LOGIC_VECTOR(31 downto 0);   -- First operand of ALU
signal ALU_In_2        : STD_LOGIC_VECTOR(31 downto 0);   -- Second operand of ALU
signal EX_ALU_Result   : STD_LOGIC_VECTOR(31 downto 0);   -- The result of the ALU
signal DM_ALU_Result   : STD_LOGIC_VECTOR(31 downto 0);
signal WB_ALU_Result   : STD_LOGIC_VECTOR(31 downto 0);

--Forward unit
signal EX_FWD_MUX2_Out : STD_LOGIC_VECTOR(31 downto 0);
signal DM_FWD_MUX2_Out : STD_LOGIC_VECTOR(31 downto 0);
signal FWD_U_Sel1      : STD_LOGIC_VECTOR( 1 downto 0);
signal FWD_U_Sel2      : STD_LOGIC_VECTOR( 1 downto 0);

--################################  DM Stage Signals  ##################################
-- Data Memory
signal DM_Read_Data    : STD_LOGIC_VECTOR(31 downto 0);    -- Output of Data Memory
signal WB_Read_Data    : STD_LOGIC_VECTOR(31 downto 0);

--################################  WB Stage Signals  ##################################
-- all the signals have been decalred in the previous stages for better readability



BEGIN 
--////////////////////////////Instantation of components////////////////////////////////////

--  ##########################  Instruction Fetch Stage  ############################
-- Components:
--    1. Multiplexer: to choose the input of program counter from 4 choices: next address, target address, branch address, jump address.
--    2. Program Counter: who holds the value of the current address during 1 cycle (or more in case of an instruction fetch' stall).
--    3. Adder: who calculates the next address based on the current address.
--    4. BTB: holds the values of branch addresses and provides them in case of a hit. Implemented logic: once taken, always taken.
--    5. IM: holds the intructions.
--    6. Multiplexer: if a flash is required it sends x"00000000" to ID instead of the instruction.

-- Program_Counter
PC :entity work.Program_Counter port map (
	PC_In => PC_In,
	Clk => Clk,
	Reset => Reset,
	PC_Out =>PC_Out,
	StallIF => StallIF);
	
-- Branch Prediction Buffer
BTB:entity work.Branch_Prediction_Buffer port map (
	PC_Out=>PC_Out,
	Clk => Clk,
	Reset => Reset,
	b_instr =>PCSrc,
	Branch_Addr=>Branch_Addr,
	Hit=>IF_Hit,
	Target_Address=>Target_Address);

-- Instruction Memory
IM :entity work.Instruction_Memory port map (
	Read_Addr => PC_Out,
	Instr => IF_Instruction);

-- Next Address
NPC:entity work.Adder_32_Bits port map( 
	A=> PC_Out,
	B=> One,
	Sum => IF_Next_Address);

-- Address Multiplixer
PCS:entity work.Multiplexer_32_Bits_4_Inputs port map(
	Mux_In_0 => IF_Next_Address,
	Mux_In_1 => Target_Address,
	Mux_In_2 => jump_address,
	Mux_In_3 => Branch_Addr,
	Sel      => PC_Source_Select,
	Mux_Out  => PC_In);
						  
-- Flush Multipilxer
Flh:entity work.Multiplexer_32_Bits_2_Inputs port map(
	Mux_In_0 => IF_Instruction,
	Mux_In_1 => x"00000000", 
	Sel      => IF_Flush, 
	Mux_Out  => Flush_MUX_Out );

--##########################  Instruction Decode Stage  ############################
-- Components:
--   1. Register File: holds the values of the registers and provides them to the ALU.
--	 2. Sign Extend: extends the immediate value to 32 bits.
--	 3. Control Unit: generates the control signals for the processor.
--	 4. Hazard Unit: detects the hazards and generates the signals to stall the pipeline.
--	 5. Multiplexer: to choose the control signals or 0 signals in case of a bubble.
--	 6. Forwarding Unit: to forward the data from the previous stages to the current stage.

-- Register File
RF :entity work.Register_File port map (
	Clk => Clk,
	Reset => Reset,
	RegWrite => WB_RegWrite,
	Read_Addr_1 => ID_Instruction (25 downto 21),
	Read_Addr_2 => ID_Instruction (20 downto 16),
	Write_Addr => WB_Write_Addr,		
	Write_Data => RF_Write_Data,
	Read_Data_1 => ID_Read_Data_1 ,																																			
	Read_Data_2 => ID_Read_Data_2 );

-- Control Unit
CLU:entity work.Control_Unit port map ( 
	Operation => ID_Instruction(31 downto 26), 
	funct => ID_Instruction (5 downto 0),
	MemWrite => To_Mux_MemWrite, 
	MemtoReg => To_Mux_MemtoReg , 
	MemRead => To_Mux_MemRead,
	RegWrite => To_Mux_RegWrite , 
	Branch => To_Mux_Branch,
	RegDst => To_Mux_RegDst,
	ALUSrc => To_Mux_ALUSrc,
	Jump => To_Mux_Jump,
	ALUOp => To_Mux_ALUOp);
							
-- Sign Extend
SEU:entity work.Sign_Extend_Unit port map (
	Data_In => ID_Instruction(15 downto 0) , Data_Out => ID_Immediate);

-- Branch Address
BRA:entity work.Adder_32_Bits port map(
	A => ID_Immediate, B => ID_Next_Address, Sum => Branch_Addr);
									
-- Hazard detector Unit
HZD:entity work.Hazard_Unit port map (
	Operation => ID_Instruction(31 downto 26),
	PCSrc   => PCSrc,
	Jump => Jump,
	Hit_ET2 => ID_Hit,
	IF_ID_Rs => ID_Instruction (25 downto 21),
	IF_ID_Rt => ID_Instruction (20 downto 16),
	ID_EX_Rt => EX_Instruction (20 downto 16),
	ID_EX_Rd => DM_Write_Addr,
	MEM_WB_Rd => WB_Write_Addr,

	Branch_ID => PCSrc,
	MemRead_EX => EX_MemRead,
	RegWrite_EX => EX_RegWrite,
	MemtoReg_DM => DM_MemToReg,

	Stall_IF => StallIF,
	Stall_ID => StallID,
	CTRL_EN => CTRL_EN,
	Flush_E => IF_Flush);
							
-- Control Signals Muxliplexer (Stalling in case of Load : Inserting NOP)
CS0:entity work.Multiplexer_1_Bit_2_Inputs port map (
	Mux_In_0 => To_Mux_MemWrite,
	Mux_In_1 => '0',
	Sel => CTRL_EN,
	Mux_Out => MemWrite);
CS1:entity work.Multiplexer_1_Bit_2_Inputs port map (
	Mux_In_0 => To_Mux_MemtoReg,
	Mux_In_1 => '0',
	Sel => CTRL_EN,
	Mux_Out => MemtoReg);
CS2:entity work.Multiplexer_1_Bit_2_Inputs port map (
	Mux_In_0 => To_Mux_MemRead,
	Mux_In_1 => '0',
	Sel => CTRL_EN,
	Mux_Out => MemRead);
CS3:entity work.Multiplexer_1_Bit_2_Inputs port map (
	Mux_In_0 => To_Mux_RegWrite,
	Mux_In_1 => '0',
	Sel => CTRL_EN,
	Mux_Out => RegWrite);
CS4:entity work.Multiplexer_1_Bit_2_Inputs port map (
	Mux_In_0 => To_Mux_Branch,
	Mux_In_1 => '0',
	Sel => CTRL_EN,
	Mux_Out => Branch);
CS5:entity work.Multiplexer_1_Bit_2_Inputs port map (
	Mux_In_0 => To_Mux_RegDst,
	Mux_In_1 => '0',
	Sel => CTRL_EN,
	Mux_Out => RegDst);
CS6:entity work.Multiplexer_1_Bit_2_Inputs port map (
	Mux_In_0 => To_Mux_ALUSrc,
	Mux_In_1 => '0',
	Sel => CTRL_EN,
	Mux_Out => ALUSrc);
CS7:entity work.Multiplexer_1_Bit_2_Inputs port map (
	Mux_In_0 => To_Mux_Jump,
	Mux_In_1 => '0',
	Sel => CTRL_EN,
	Mux_Out => Jump);
CS8:entity work.Multiplexer_1_Bit_2_Inputs port map (
	Mux_In_0 => To_Mux_ALUOp(1),
	Mux_In_1 => '0',
	Sel => CTRL_EN,
	Mux_Out => ALUOp(1));
CS9:entity work.Multiplexer_1_Bit_2_Inputs port map (
	Mux_In_0 => To_Mux_ALUOp(0),
	Mux_In_1 => '0',
	Sel => CTRL_EN,
	Mux_Out => ALUOp(0));

--Forwrd Unit1 Multiplixers

FB1:entity work.Multiplexer_32_Bits_2_Inputs port map (
	Mux_In_0 => ID_Read_Data_1 ,
	Mux_In_1 => DM_ALU_Result ,
	Sel => FWD_U1_Sel1,
	Mux_Out => FWD_U1_MUX1_Out );

FB2:entity work.Multiplexer_32_Bits_2_Inputs port map (
	Mux_In_0 => ID_Read_Data_2 ,
	Mux_In_1 => DM_ALU_Result ,
	Sel => FWD_U1_Sel2,
	Mux_Out => FWD_U1_MUX2_Out );

CMP:entity work.Comparator_32_Bits port map( 
	OP1 => FWD_U1_MUX1_Out,
	OP2 =>FWD_U1_MUX2_Out,
	RES =>Bcond);

BFW:entity work.Branch_Forwarding_Unit port map (
	IF_ID_Rs => ID_Instruction (25 downto 21),
	IF_ID_Rt => ID_Instruction (20 downto 16),
	EX_MEM_Rd => DM_Write_Addr,
	EX_MEM_RegWrite => DM_RegWrite,
	FORWARD_Out_1 => FWD_U1_Sel1,
	FORWARD_Out_2 => FWD_U1_Sel2);

--##########################  Instruction Excute Stage  ############################
-- Components:
--   1. ALU: performs the operation on the two operands.
--	 2. ALU Control: generates the control signals for the ALU.
--	 3. Multiplexer: to choose the second operand of the ALU between the second operand of the instruction and the sign extended immediate value.
--	 4. Multiplexer: to choose the write address of the register file between the destination register and the target register.
--	 5. Forwarding Unit: to forward the data from the next stages to the current stage.
--	 6. Forwarding MUX1: to choose the first operand of the ALU between the output of the RF or the forwarded data from the next stages.
--	 7. Forwarding MUX2: to choose the second operand of the ALU between the output of the MUX(3) or the forwarded data from the next stages. 

-- Arithmetic_Logic_Unit
ALU:entity work.Arithmetic_Logic_Unit port map (
	ALUControl => ALUControl ,
	OP1 => ALU_In_1 ,
	OP2 => ALU_in_2 ,
	ALU_Result => EX_ALU_Result);
							
--MUX RegisterFile & SignExtend to ALU
ALS:entity work.Multiplexer_32_Bits_2_Inputs port map (
	Mux_In_0 => EX_FWD_MUX2_Out,
	Mux_In_1 => EX_Immediate,
	Sel => EX_ALUSrc,
	Mux_Out => ALU_In_2);

-- ALU Control
ALC:entity work.ALU_Control port map (
	Fct => EX_Instruction(5 downto 0),
	ALUOp => EX_ALUOp,
	ALUControl => ALUControl);

-- Forwarding Unit
FW :entity work.Forwarding_Unit port map (
	ID_EX_Rs => EX_Instruction (25 downto 21),
	ID_EX_Rt => EX_Instruction (20 downto 16),
	EX_MEM_Rd => DM_Write_Addr,    --DM_Instruction (15 downto 11), 
	EX_MEM_RegWrite => DM_RegWrite,
	MEM_WB_Rd => WB_Write_Addr,
	MEM_WB_RegWrite => WB_RegWrite,
	FORWARD_Out_1 => FWD_U_Sel1,
	FORWARD_Out_2 => FWD_U_Sel2
	);

-- MUX Write address of RegisterFile
RFT:entity work.Multiplexer_5_Bits_2_Inputs  port map (
	Mux_In_0 => EX_Instruction (20 downto 16),
	Mux_In_1 => EX_Instruction (15 downto 11),
	Sel => EX_RegDst,
	Mux_Out => EX_Write_Addr);
				
-- ALU input1 Multiplxer
FM1:entity work.Multiplexer_32_Bits_4_Inputs port map (
	Mux_In_0 => EX_Read_Data_1,
	Mux_In_1 => RF_Write_Data,
	Mux_In_2 => DM_ALU_Result,
	Mux_In_3 => x"00000000",
	Sel => FWD_U_Sel1,
	Mux_Out => ALU_In_1 );

-- ALU input2 Multiplxer
FM2:entity work.Multiplexer_32_Bits_4_Inputs port map (
	Mux_In_0 => EX_Read_Data_2,
	Mux_In_1 => RF_Write_Data,
	Mux_In_2 => DM_ALU_Result,
	Mux_In_3 => x"00000000",
	Sel => FWD_U_Sel2,
	Mux_Out => EX_FWD_MUX2_Out);

--#############################  Data Memory  Stage  ###############################
-- Components:
--   1. Data Memory: holds the data and provides them to the WB stage.

-- Data Memory
DM :entity work.Data_Memory port map (
	Reset => '0',
	Address=> DM_ALU_Result ,
	Write_Data => DM_FWD_MUX2_Out,
	Read_Data => DM_Read_Data,
	MemWrite => DM_MemWrite ,
	MemRead => DM_MemRead, 
	Clk => Clk );
									
--#############################   Write Back  Stage  ###############################
-- Components:
--	 1. Multiplexer: to choose the data to be written in the register file between the output of the ALU and the output of the data memory.

--DataMermory to RegisterFile
RFD:entity work.Multiplexer_32_Bits_2_Inputs port map (
	Mux_In_0 => WB_ALU_Result,
	Mux_In_1 => WB_Read_Data,
	Sel => WB_MemToReg,
	Mux_Out => RF_Write_Data );





--//////////////////////////// Instantation of Stages : DATA////////////////////////////////////

--#############################   IF to ID  Stage      ###############################
DE1:entity work.Flip_Flop_32_Bits_With_Enable port map(Clk=>Clk,aReset=>Reset,Enable=>StallID,Data_In=>Flush_MUX_Out,Data_Out=>ID_Instruction);
DE2:entity work.Flip_Flop_32_Bits_With_Enable port map(Clk=>Clk,aReset=>Reset,Enable=>StallID,Data_In=>IF_Next_Address,Data_Out=>ID_Next_Address);

--#############################   ID to Excute  Stage  ###############################
D1 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>ID_Instruction,Data_Out=>EX_Instruction);
D2 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>ID_Read_Data_1,Data_Out=>EX_Read_Data_1);
D3 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>ID_Read_Data_2,Data_Out=>EX_Read_Data_2);
D4 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>ID_Immediate,Data_Out=>EX_Immediate);

--#############################   Excute to DM  Stage  ###############################
D5 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>EX_Instruction,Data_Out=>DM_Instruction);
D6 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>EX_ALU_Result,Data_Out=>DM_ALU_Result);
D7 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>EX_FWD_MUX2_Out,Data_Out=>DM_FWD_MUX2_Out);
D8 :entity work.Flip_Flop_5_Bits_Without_Enable port map (Clk=>Clk,aReset=>Reset,Data_In=> EX_Write_Addr ,Data_Out=>DM_Write_Addr );

--#############################   DM to WB  Stage      ###############################
D10:entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>DM_Read_Data,Data_Out=>WB_Read_Data);
D11:entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>DM_ALU_Result,Data_Out=>WB_ALU_Result);
D12:entity work.Flip_Flop_5_Bits_Without_Enable port map (Clk=>Clk,aReset=>Reset,Data_In=> DM_Write_Addr ,Data_Out=>WB_Write_Addr );



--//////////////////////////// Instantation of Stages : Control ////////////////////////////////////

--#############################	 IF to ID 		stage  ###############################
DE3:entity work.Flip_Flop_1_Bit_With_Enable port map(Clk=>Clk,aReset=>Reset, Enable=>StallID, Data_In=>IF_Hit,Data_Out=>ID_Hit);

--#############################   ID to Excute  Stage  ###############################
D13:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>MemWrite ,Data_Out=>EX_MemWrite);
D14:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>MemtoReg ,Data_Out=>EX_MemToReg);
D15:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>MemRead,Data_Out=>EX_MemRead);
D16:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>RegWrite,Data_Out=>EX_RegWrite);
D17:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>RegDst,Data_Out=>EX_RegDst);
D18:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>ALUSrc,Data_Out=>EX_ALUSrc);
D19:entity work.Flip_Flop_2_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>ALUOp,Data_Out=>EX_ALUOp);

--#############################   Excute to DM  Stage  ###############################
D20:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>EX_MemWrite ,Data_Out=>DM_MemWrite);
D21:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>EX_MemToReg ,Data_Out=>DM_MemToReg);
D22:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>EX_MemRead,Data_Out=>DM_MemRead);
D23:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>EX_RegWrite,Data_Out=>DM_RegWrite);


--#############################   DM to WB  Stage      ###############################
D24:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>DM_MemToReg ,Data_Out=>WB_MemToReg);
D25:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>DM_RegWrite,Data_Out=>WB_RegWrite);


--////////////////////////////      Assignments    /////////////////////////////////////
-- Generation of the select signal for the multiplexer who gives the next address of the instruction
	PCSrc <= (Branch and Bcond);
	PC_Source_Select <= ((not(IF_Hit) and Jump and not(PCSrc) and not(ID_Hit)) or 
						 (not(IF_Hit) and not(Jump) and PCSrc and not(ID_Hit))) 
						 &
						 ((not(IF_Hit) and not(Jump) and PCSrc and not(ID_Hit)) or 
						 (IF_Hit and not(Jump) and not(PCSrc) and not(ID_Hit)));

-- Composition of the jump address
	jump_address <= ID_Next_Address(31 downto 28) & "00" &ID_Instruction(25 downto 0);

end arch;
