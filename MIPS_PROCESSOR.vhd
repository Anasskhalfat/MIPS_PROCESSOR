library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Naming Convention :
--Data_Flow : (Stage ID)_(Data Name)
--Control Signals : (Stage ID)_(Data Name)
--Stage ID : IF, ID, EX, DM, WB
--Processor Outputs : (O_Signal Name)
--Files Name : Full Name with _ between two words and first word letter is Maj

entity MIPS_PROCESSOR is
	Port(
		Reset : in STD_LOGIC ;
		Clk : in STD_LOGIC;
		
		--instructions 
		Instruction_ET1_deb : out STD_LOGIC_VECTOR(31 downto 0);
		Instruction_ET2_deb : out STD_LOGIC_VECTOR(31 downto 0);
		---------------------------------------
		--PC counter & Fetch Address
		PC_In_deb : out STD_LOGIC_VECTOR(31 downto 0);
		PC_Out_deb: out STD_LOGIC_VECTOR(31 downto 0);
		
		next_address_ET1_deb: out STD_LOGIC_VECTOR(31 downto 0);
		Target_Address_deb: out STD_LOGIC_VECTOR(31 downto 0);
		Hit_deb: out STD_LOGIC;
		
		--BTB
		PCSrc_deb : out STD_LOGIC;
		Branch_Addr_deb: out STD_LOGIC_VECTOR(31 downto 0)
	);
end entity;

architecture arch of MIPS_PROCESSOR is
	
-- Signals
-- PC
signal PC_In: STD_LOGIC_VECTOR(31 downto 0);

-- Instruction
signal Instruction_ET1 : STD_LOGIC_VECTOR(31 downto 0);
signal Instruction_ET2 : STD_LOGIC_VECTOR(31 downto 0);
signal Instruction_ET3 : STD_LOGIC_VECTOR(31 downto 0);
signal Instruction_ET4 : STD_LOGIC_VECTOR(31 downto 0);
signal Instruction_ET5 : STD_LOGIC_VECTOR(31 downto 0);

--Register File
signal Read_Data_1_ET2 : STD_LOGIC_VECTOR(31 downto 0);
signal Read_Data_1_ET3 : STD_LOGIC_VECTOR(31 downto 0);
signal Read_Data_2_ET2 : STD_LOGIC_VECTOR(31 downto 0);
signal Read_Data_2_ET3 : STD_LOGIC_VECTOR(31 downto 0);
signal RF_Write_Data   : STD_LOGIC_VECTOR(31 downto 0);
signal Write_Addr_ET3 : STD_LOGIC_VECTOR(4 downto 0);
signal Write_Addr_ET4 : STD_LOGIC_VECTOR(4 downto 0);
signal Write_Addr_ET5: STD_LOGIC_VECTOR(4 downto 0);

--Sign Extend
signal SignEx_ET2 : STD_LOGIC_VECTOR(31 downto 0);
signal SignEx_ET3 : STD_LOGIC_VECTOR(31 downto 0); 

--ALU signals
signal ALUControl : STD_LOGIC_VECTOR(2 downto 0); -----input of ALU coming from ALUcontrol
signal ALU_In_1 : STD_LOGIC_VECTOR(31 downto 0);
signal ALU_In_2 : STD_LOGIC_VECTOR(31 downto 0);  --input2 of ALU
signal ALU_Result_ET3 : STD_LOGIC_VECTOR(31 downto 0);
signal ALU_Result_ET4 : STD_LOGIC_VECTOR(31 downto 0);
signal ALU_Result_ET5 : STD_LOGIC_VECTOR(31 downto 0);

-- Control Unit 
signal To_Mux_RegDst : STD_LOGIC;
signal To_Mux_MemWrite : STD_LOGIC;
signal To_Mux_MemRead : STD_LOGIC;
signal To_Mux_MemtoReg : STD_LOGIC;
signal To_Mux_ALUSrc : STD_LOGIC;
signal To_Mux_ALUOp : STD_LOGIC_VECTOR(1 downto 0);
signal To_Mux_Branch : std_logic;
signal To_Mux_RegWrite : STD_LOGIC;
signal To_Mux_Jump : std_logic;

signal RegDst : STD_LOGIC;
signal MemWrite : STD_LOGIC;
signal MemRead : STD_LOGIC;
signal MemtoReg : STD_LOGIC;
signal ALUSrc : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(1 downto 0);
signal Branch : std_logic;
signal RegWrite : STD_LOGIC;

signal MemWrite_EX : STD_LOGIC;
signal MemRead_EX : STD_LOGIC;
signal MemtoReg_EX : STD_LOGIC;
signal ALUSrc_EX : STD_LOGIC;
signal ALUOp_EX : STD_LOGIC_VECTOR(1 downto 0);
signal Branch_EX : std_logic;
signal RegWrite_EX : STD_LOGIC; ------output of the control unit
signal RegDst_EX: STD_LOGIC;

signal MemWrite_DM : STD_LOGIC;
signal MemRead_DM : STD_LOGIC;
signal MemtoReg_DM: STD_LOGIC;
signal Branch_ID : std_logic;
signal RegWrite_DM : STD_LOGIC; ------output of the control unit

signal MemtoReg_WB: STD_LOGIC;
signal RegWrite_WB : STD_LOGIC; ------output of the control unit

signal Jump : std_logic;
signal Hit: std_logic;
signal Hit_ET2 : std_logic;
signal Target_Address: std_logic_vector(31 downto 0);

signal IF_mux_Out : 	STD_LOGIC_VECTOR(31 downto 0);
signal IF_Flush : 	STD_LOGIC;

-- Data Memory
signal Read_Data_ET4: STD_LOGIC_VECTOR(31 downto 0); 
signal Read_Data_ET5: STD_LOGIC_VECTOR(31 downto 0);


-- Branch
signal Branch_Addr: STD_LOGIC_VECTOR(31 downto 0);
signal next_address_ET1: STD_LOGIC_VECTOR(31 downto 0);
signal next_address_ET2: STD_LOGIC_VECTOR(31 downto 0);

signal Bcond: STD_LOGIC;
signal PCSrc: std_logic;
signal PC_Out: std_logic_vector(31 downto 0);

-- Constant
signal One: STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000001";

--Forward unit
signal FWD_MUX2_Out_ET3 : STD_LOGIC_VECTOR(31 downto 0);
signal FWD_MUX2_Out_ET4 : STD_LOGIC_VECTOR(31 downto 0);

signal FWD_U_Sel1 : STD_LOGIC_VECTOR(1 downto 0);
signal FWD_U_Sel2 : STD_LOGIC_VECTOR(1 downto 0);

--Hazard unit
signal StallIF: std_logic;
signal StallID: std_logic;
signal CTRL_EN: std_logic;

--Forward unit 1
signal FWD_U1_Sel1 : STD_LOGIC;
signal FWD_U1_Sel2 : STD_LOGIC;

signal FWD_U1_MUX1_Out: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal FWD_U1_MUX2_Out: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal PC_Source_Select : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN 
--////////////////////////////Instantation of components////////////////////////////////////

--##########################  Instruction Fetch Stage  ############################
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
	Mux_In_2 => (next_address_ET2(31 downto 28) & "00" &Instruction_ET2(25 downto 0)),
	Mux_In_3 => Branch_Addr,
	Sel  	  => PC_Source_Select,
	Mux_Out  => PC_In);
						  
-- Flush Multipilxer
Flh:entity work.Multiplexer_32_Bits_2_Inputs port map(
	Mux_In_0 => Instruction_ET1,
	Mux_In_1 => x"00000000", 
	Sel =>IF_Flush, 
	Mux_Out =>IF_mux_Out );

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
	Clk => Clk ,
	ALUControl => ALUControl ,
	OP1 => ALU_In_1 ,
	OP2 => ALU_in_2 ,
	ALU_Result => ALU_Result_ET3);
							
							--,overflow => Bcond);
							
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



--//////////////////////////// Instantation of Stages : Control////////////////////////////////////

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
						 
--////////////////////////////  Outputs For Debugging    /////////////////////////////////////
--instructions 
Instruction_ET1_deb <= Instruction_ET1;
Instruction_ET2_deb <= Instruction_ET2;
---------------------------------------
--PC counter & Fetch Address
PC_In_deb   <= PC_In;
PC_Out_deb  <= PC_Out;

next_address_ET1_deb <= next_address_ET1;
Target_Address_deb <= Target_Address;
Hit_deb <= Hit;

--BTB
PCSrc_deb <= PCSrc;
Branch_Addr_deb <= Branch_Addr;

end arch;
