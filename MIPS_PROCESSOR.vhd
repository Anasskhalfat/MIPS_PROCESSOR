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
signal One			    : STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000001";

--################################  IF Stage Signals  ##################################
-- Program Counter
signal PC_In            : STD_LOGIC_VECTOR(31 downto 0);   -- Output of address selectors, Input of PC
signal PC_Out 		: STD_LOGIC_VECTOR(31 downto 0);   -- Output of PC, Input of IM and BTB

-- Adder, calculates the next address
signal next_address_ET1 : STD_LOGIC_VECTOR(31 downto 0);   -- Output of adder: PC+4
signal next_address_ET2 : STD_LOGIC_VECTOR(31 downto 0);

-- Instruction Memory
signal Instruction_ET1  : STD_LOGIC_VECTOR(31 downto 0);   -- Output of Instruction Memory
signal Instruction_ET2  : STD_LOGIC_VECTOR(31 downto 0);   
signal Instruction_ET3  : STD_LOGIC_VECTOR(31 downto 0);
signal Instruction_ET4  : STD_LOGIC_VECTOR(31 downto 0);
signal Instruction_ET5  : STD_LOGIC_VECTOR(31 downto 0);

-- BTB
signal Target_Address   : std_logic_vector(31 downto 0);   -- Output of BTB
signal Hit              : std_logic;                       -- Hit signal to indicate if the branch address does exist in the BTB
signal Hit_ET2          : std_logic;

-- Multiplexer for Flashing
signal IF_mux_Out       : STD_LOGIC_VECTOR(31 downto 0);   -- Output of the multiplexer: instruction or x"00000000"

-- Selector for the next address of the instruction
signal PC_Source_Select : STD_LOGIC_VECTOR(1 DOWNTO 0);

--################################  ID Stage Signals  ##################################
-- Register File
signal Read_Data_1_ET2  : STD_LOGIC_VECTOR(31 downto 0);   -- First  output data of register file (Rs)
signal Read_Data_1_ET3  : STD_LOGIC_VECTOR(31 downto 0);
signal Read_Data_2_ET2  : STD_LOGIC_VECTOR(31 downto 0);   -- Second output data of register file (Rt)
signal Read_Data_2_ET3  : STD_LOGIC_VECTOR(31 downto 0);
signal RF_Write_Data    : STD_LOGIC_VECTOR(31 downto 0);   -- The data to be written in the register file

--Sign Extend
signal SignEx_ET2       : STD_LOGIC_VECTOR(31 downto 0);   -- Output of sign extend unit
signal SignEx_ET3       : STD_LOGIC_VECTOR(31 downto 0); 

--Hazard unit
signal StallIF          : std_logic;                       -- Enable of Program Counter: stalls the IF stage
signal StallID          : std_logic;                       -- Enable of IF/ID flip flops: stalls the whole ID stage
signal CTRL_EN          : std_logic;                       -- Selector of control signals or 0 signals: to insert a bubble into the pipeline

-- Control Unit : goes throught a multiplexer, the multiplexer is used to insert a bubble in the pipeline
-- Generates the control signals for the processor: 0:NO, 1:YES (inputs of the multiplexers)
signal To_Mux_RegDst    : STD_LOGIC;
signal To_Mux_MemWrite  : STD_LOGIC;
signal To_Mux_MemRead   : STD_LOGIC;
signal To_Mux_MemtoReg  : STD_LOGIC;
signal To_Mux_ALUSrc    : STD_LOGIC;
signal To_Mux_ALUOp     : STD_LOGIC_VECTOR(1 downto 0);
signal To_Mux_Branch    : std_logic;
signal To_Mux_RegWrite  : STD_LOGIC;
signal To_Mux_Jump      : std_logic;
signal IF_Flush         : STD_LOGIC;                        -- To flash the instruction from IF to ID stages

 -- Control Unit (outputs of the multiplexers)
signal MemWrite         : STD_LOGIC;                        -- Data Memory Write Operation
signal MemRead          : STD_LOGIC;                        -- Data Memory Read  Operation
signal MemtoReg         : STD_LOGIC;                        -- Data Memory/alu result selection
signal RegDst 	        : STD_LOGIC;                        -- Destination Address Selection
signal RegWrite     	: STD_LOGIC;                        -- Register File write operation 
signal ALUSrc           : STD_LOGIC;                        -- ALU 2' input selection : Rt or immediate
signal ALUOp            : STD_LOGIC_VECTOR(1 downto 0);     -- ALU operation select
signal Branch       	: std_logic;                        -- The current instruction is a branch
signal Jump             : std_logic;                        -- The current instruction is a jump

signal MemWrite_EX      : STD_LOGIC;
signal MemRead_EX       : STD_LOGIC;
signal MemtoReg_EX      : STD_LOGIC;
signal ALUSrc_EX        : STD_LOGIC;
signal ALUOp_EX         : STD_LOGIC_VECTOR(1 downto 0);
signal Branch_EX        : std_logic;
signal RegWrite_EX      : STD_LOGIC; 
signal RegDst_EX        : STD_LOGIC;

signal MemWrite_DM      : STD_LOGIC;
signal MemRead_DM       : STD_LOGIC;
signal MemtoReg_DM      : STD_LOGIC;
signal Branch_ID        : std_logic;
signal RegWrite_DM      : STD_LOGIC;

signal MemtoReg_WB      : STD_LOGIC;
signal RegWrite_WB      : STD_LOGIC;

-- Jump
signal jump_address     : std_logic_vector(31 downto 0);   -- Jump address: "next_address_ET2[31:28],00,Instr[25:0]"

-- Branch
signal Branch_Addr      : STD_LOGIC_VECTOR(31 downto 0);   -- Branch address: result of (next_address_ET2 + immediate value)
signal Bcond            : STD_LOGIC;                       -- A signal to indicate if Rs=Rt in case of branch
signal PCSrc            : std_logic;                       -- Address selecting signal: output of Control Unit

--Forward unit 1
signal FWD_U1_Sel1      : STD_LOGIC;
signal FWD_U1_Sel2      : STD_LOGIC;
signal FWD_U1_MUX1_Out  : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal FWD_U1_MUX2_Out  : STD_LOGIC_VECTOR(31 DOWNTO 0);

--################################  EXE Stage Signals  ##################################
-- Multiplexer, Chooses the write address between Rt and Rd
signal Write_Addr_ET3   : STD_LOGIC_VECTOR( 4 downto 0);   -- The address to write data to in the register file
signal Write_Addr_ET4   : STD_LOGIC_VECTOR( 4 downto 0);
signal Write_Addr_ET5   : STD_LOGIC_VECTOR( 4 downto 0);

--ALU signals
signal ALUControl       : STD_LOGIC_VECTOR(2 downto 0);    -- Input of ALU coming from ALUcontrol
signal ALU_In_1         : STD_LOGIC_VECTOR(31 downto 0);   -- First operand of ALU
signal ALU_In_2         : STD_LOGIC_VECTOR(31 downto 0);   -- Second operand of ALU
signal ALU_Result_ET3   : STD_LOGIC_VECTOR(31 downto 0);   -- The result of the ALU
signal ALU_Result_ET4   : STD_LOGIC_VECTOR(31 downto 0);
signal ALU_Result_ET5   : STD_LOGIC_VECTOR(31 downto 0);

--Forward unit
signal FWD_MUX2_Out_ET3 : STD_LOGIC_VECTOR(31 downto 0);
signal FWD_MUX2_Out_ET4 : STD_LOGIC_VECTOR(31 downto 0);
signal FWD_U_Sel1       : STD_LOGIC_VECTOR(1 downto 0);
signal FWD_U_Sel2       : STD_LOGIC_VECTOR(1 downto 0);

--################################  DM Stage Signals  ##################################
-- Data Memory
signal Read_Data_ET4    : STD_LOGIC_VECTOR(31 downto 0);    -- Output of Data Memory
signal Read_Data_ET5    : STD_LOGIC_VECTOR(31 downto 0);

--################################  WB Stage Signals  ##################################
-- all the signals have been decalred in the previous stages for better readability



BEGIN 
--////////////////////////////Instantation of components////////////////////////////////////

--##########################  Instruction Fetch Stage  ############################
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
	Hit=>Hit,
	Target_Address=>Target_Address);

-- Instruction Memory
IM :entity work.Instruction_Memory port map (
	Read_Addr => PC_Out,
	Instr => Instruction_ET1);

-- Next Address
NPC:entity work.Adder_32_Bits port map( 
	A=> PC_Out,
	B=> One,
	Sum => next_address_ET1);

-- Address Multiplixer
PCS:entity work.Multiplexer_32_Bits_4_Inputs port map(
	Mux_In_0 => next_address_ET1,
	Mux_In_1 => Target_Address,
	Mux_In_2 => jump_address,
	Mux_In_3 => Branch_Addr,
	Sel      => PC_Source_Select,
	Mux_Out  => PC_In);
						  
-- Flush Multipilxer
Flh:entity work.Multiplexer_32_Bits_2_Inputs port map(
	Mux_In_0 => Instruction_ET1,
	Mux_In_1 => x"00000000", 
	Sel      => IF_Flush, 
	Mux_Out  => IF_mux_Out );

--##########################  Instruction Decode Stage  ############################
-- Register File
RF :entity work.Register_File port map (
	Clk => Clk,
	Reset => Reset,
	RegWrite => RegWrite_WB,
	Read_Addr_1 => Instruction_ET2 (25 downto 21),
	Read_Addr_2 => Instruction_ET2 (20 downto 16),
	Write_Addr => Write_Addr_ET5,		
	Write_Data => RF_Write_Data,
	Read_Data_1 => Read_Data_1_ET2 ,																																			
	Read_Data_2 => Read_Data_2_ET2 );

-- Control Unit
CLU:entity work.Control_Unit port map ( 
	Operation => Instruction_ET2(31 downto 26), 
	funct => Instruction_ET2 (5 downto 0),
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
	Data_In => Instruction_ET2(15 downto 0) , Data_Out => SignEx_ET2);

-- Branch Address
BRA:entity work.Adder_32_Bits port map(
	A => SignEx_ET2, B => next_address_ET2, Sum => Branch_Addr);
									
-- Hazard detector Unit
HZD:entity work.Hazard_Unit port map (
	Operation => Instruction_ET2(31 downto 26),
	PCSrc   => PCSrc,
	Jump => Jump,
	Hit_ET2 => Hit_ET2,
	IF_ID_Rs => Instruction_ET2 (25 downto 21),
	IF_ID_Rt => Instruction_ET2 (20 downto 16),
	ID_EX_Rt => Instruction_ET3 (20 downto 16),
	ID_EX_Rd => Write_Addr_ET4,
	MEM_WB_Rd => Write_Addr_ET5,

	Branch_ID => PCSrc,
	MemRead_EX => MemRead_EX,
	RegWrite_EX => RegWrite_EX,
	MemtoReg_DM => MemtoReg_DM,

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
	Mux_In_0 => Read_Data_1_ET2 ,
	Mux_In_1 => ALU_Result_ET4 ,
	Sel => FWD_U1_Sel1,
	Mux_Out => FWD_U1_MUX1_Out );

FB2:entity work.Multiplexer_32_Bits_2_Inputs port map (
	Mux_In_0 => Read_Data_2_ET2 ,
	Mux_In_1 => ALU_Result_ET4 ,
	Sel => FWD_U1_Sel2,
	Mux_Out => FWD_U1_MUX2_Out );

CMP:entity work.Comparator_32_Bits port map( 
	OP1 => FWD_U1_MUX1_Out,
	OP2 =>FWD_U1_MUX2_Out,
	RES =>Bcond);

BFW:entity work.Branch_Forwarding_Unit port map (
	IF_ID_Rs => Instruction_ET2 (25 downto 21),
	IF_ID_Rt => Instruction_ET2 (20 downto 16),
	EX_MEM_Rd => Write_Addr_ET4,
	EX_MEM_RegWrite => RegWrite_DM,
	FORWARD_Out_1 => FWD_U1_Sel1,
	FORWARD_Out_2 => FWD_U1_Sel2);

--##########################  Instruction Excute Stage  ############################
-- Arithmetic_Logic_Unit
ALU:entity work.Arithmetic_Logic_Unit port map (
	ALUControl => ALUControl ,
	OP1 => ALU_In_1 ,
	OP2 => ALU_in_2 ,
	ALU_Result => ALU_Result_ET3);
							
--MUX RegisterFile & SignExtend to ALU
ALS:entity work.Multiplexer_32_Bits_2_Inputs port map (
	Mux_In_0 => FWD_MUX2_Out_ET3,
	Mux_In_1 => SignEx_ET3,
	Sel => ALUSrc_EX,
	Mux_Out => ALU_In_2);

-- ALU Control
ALC:entity work.ALU_Control port map (
	Fct => Instruction_ET3(5 downto 0),
	ALUOp => ALUOp_EX,
	ALUControl => ALUControl);

-- Forwarding Unit
FW :entity work.Forwarding_Unit port map (
	ID_EX_Rs => Instruction_ET3 (25 downto 21),
	ID_EX_Rt => Instruction_ET3 (20 downto 16),
	EX_MEM_Rd => Write_Addr_ET4,    --Instruction_ET4 (15 downto 11), 
	EX_MEM_RegWrite => RegWrite_DM,
	MEM_WB_Rd => Write_Addr_ET5,
	MEM_WB_RegWrite => RegWrite_WB,
	FORWARD_Out_1 => FWD_U_Sel1,
	FORWARD_Out_2 => FWD_U_Sel2
	);

-- MUX Write address of RegisterFile
RFT:entity work.Multiplexer_5_Bits_2_Inputs  port map (
	Mux_In_0 => Instruction_ET3 (20 downto 16),
	Mux_In_1 => Instruction_ET3 (15 downto 11),
	Sel => RegDst_EX,
	Mux_Out => Write_Addr_ET3);
				
-- ALU input1 Multiplxer
FM1:entity work.Multiplexer_32_Bits_4_Inputs port map (
	Mux_In_0 => Read_Data_1_ET3,
	Mux_In_1 => RF_Write_Data,
	Mux_In_2 => ALU_Result_ET4,
	Mux_In_3 => x"00000000",
	Sel => FWD_U_Sel1,
	Mux_Out => ALU_In_1 );

-- ALU input2 Multiplxer
FM2:entity work.Multiplexer_32_Bits_4_Inputs port map (
	Mux_In_0 => Read_Data_2_ET3,
	Mux_In_1 => RF_Write_Data,
	Mux_In_2 => ALU_Result_ET4,
	Mux_In_3 => x"00000000",
	Sel => FWD_U_Sel2,
	Mux_Out => FWD_MUX2_Out_ET3);

--#############################  Data Memory  Stage  ###############################
-- Data Memory
DM :entity work.Data_Memory port map (
	Reset => '0',
	Address=> ALU_Result_ET4 ,
	Write_Data => FWD_MUX2_Out_ET4,
	Read_Data => Read_Data_ET4,
	MemWrite => MemWrite_DM ,
	MemRead => MemRead_DM, 
	Clk => Clk );
									
--#############################   Write Back  Stage  ###############################
--DataMermory to RegisterFile
RFD:entity work.Multiplexer_32_Bits_2_Inputs port map (
	Mux_In_0 => ALU_Result_ET5,
	Mux_In_1 => Read_Data_ET5,
	Sel => MemtoReg_WB,
	Mux_Out => RF_Write_Data );





--//////////////////////////// Instantation of Stages : DATA////////////////////////////////////

--#############################   IF to ID  Stage      ###############################
DE1:entity work.Flip_Flop_32_Bits_With_Enable port map(Clk=>Clk,aReset=>Reset,Enable=>StallID,Data_In=>IF_mux_Out,Data_Out=>Instruction_ET2);
DE2:entity work.Flip_Flop_32_Bits_With_Enable port map(Clk=>Clk,aReset=>Reset,Enable=>StallID,Data_In=>next_address_ET1,Data_Out=>next_address_ET2);

--#############################   ID to Excute  Stage  ###############################
D1 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>Instruction_ET2,Data_Out=>Instruction_ET3);
D2 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>Read_Data_1_ET2,Data_Out=>Read_Data_1_ET3);
D3 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>Read_Data_2_ET2,Data_Out=>Read_Data_2_ET3);
D4 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>SignEx_ET2,Data_Out=>SignEx_ET3);

--#############################   Excute to DM  Stage  ###############################
D5 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>Instruction_ET3,Data_Out=>Instruction_ET4);
D6 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>ALU_Result_ET3,Data_Out=>ALU_Result_ET4);
D7 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>FWD_MUX2_Out_ET3,Data_Out=>FWD_MUX2_Out_ET4);
D8 :entity work.Flip_Flop_5_Bits_Without_Enable port map (Clk=>Clk,aReset=>Reset,Data_In=> Write_Addr_ET3 ,Data_Out=>Write_Addr_ET4 );

--#############################   DM to WB  Stage      ###############################
D9 :entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>Instruction_ET4,Data_Out=>Instruction_ET5);
D10:entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>Read_Data_ET4,Data_Out=>Read_Data_ET5);
D11:entity work.Flip_Flop_32_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>ALU_Result_ET4,Data_Out=>ALU_Result_ET5);
D12:entity work.Flip_Flop_5_Bits_Without_Enable port map (Clk=>Clk,aReset=>Reset,Data_In=> Write_Addr_ET4 ,Data_Out=>Write_Addr_ET5 );



--//////////////////////////// Instantation of Stages : Control ////////////////////////////////////

--#############################	 IF to ID 		stage  ###############################
DE3:entity work.Flip_Flop_1_Bit_With_Enable port map(Clk=>Clk,aReset=>Reset, Enable=>StallID, Data_In=>Hit,Data_Out=>Hit_ET2);

--#############################   ID to Excute  Stage  ###############################
D13:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>MemWrite ,Data_Out=>MemWrite_EX);
D14:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>MemtoReg ,Data_Out=>MemtoReg_EX);
D15:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>MemRead,Data_Out=>MemRead_EX);
D16:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>RegWrite,Data_Out=>RegWrite_EX);
D17:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>RegDst,Data_Out=>RegDst_EX);
D18:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>ALUSrc,Data_Out=>ALUSrc_EX);
D19:entity work.Flip_Flop_2_Bits_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>ALUOp,Data_Out=>ALUOp_EX);

--#############################   Excute to DM  Stage  ###############################
D20:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>MemWrite_EX ,Data_Out=>MemWrite_DM);
D21:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>MemtoReg_EX ,Data_Out=>MemtoReg_DM);
D22:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>MemRead_EX,Data_Out=>MemRead_DM);
D23:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>RegWrite_EX,Data_Out=>RegWrite_DM);


--#############################   DM to WB  Stage      ###############################
D24:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>MemtoReg_DM ,Data_Out=>MemtoReg_WB);
D25:entity work.Flip_Flop_1_Bit_Without_Enable port map(Clk=>Clk,aReset=>Reset,Data_In=>RegWrite_DM,Data_Out=>RegWrite_WB);


--////////////////////////////      Assignments    /////////////////////////////////////
	PCSrc <= (Branch and Bcond);
	PC_Source_Select <= ((not(Hit) and Jump and not(PCSrc) and not(Hit_ET2)) or 
						 (not(Hit) and not(Jump) and PCSrc and not(Hit_ET2))) 
						 &
						 ((not(Hit) and not(Jump) and PCSrc and not(Hit_ET2)) or 
						 (Hit and not(Jump) and not(PCSrc) and not(Hit_ET2)));
	jump_address <= next_address_ET2(31 downto 28) & "00" &Instruction_ET2(25 downto 0);

end arch;
