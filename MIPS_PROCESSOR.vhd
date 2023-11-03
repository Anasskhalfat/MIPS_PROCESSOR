library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS_PROCESSOR is
	Port(
		Reset : in STD_LOGIC ;
		Clk : in STD_LOGIC;
		
		--instructions 
		Instruction_ET2_out : out STD_LOGIC_VECTOR(31 downto 0);
		
		Read_Data_1_ET2_out : out STD_LOGIC_VECTOR(31 downto 0);
		Read_Data_2_ET2_out : out STD_LOGIC_VECTOR(31 downto 0);
		RF_Write_Data_o: out std_logic_vector(31 downto 0);
		
		ALU_In_1_Out : out STD_LOGIC_VECTOR(31 downto 0);
		ALU_In_2_Out : out STD_LOGIC_VECTOR(31 downto 0);
		ALU_Result_ET3_out : out STD_LOGIC_VECTOR(31 downto 0);
		
		WriteData : out STD_LOGIC_VECTOR(31 downto 0);
		Address : out STD_LOGIC_VECTOR(31 downto 0);
		Memout : out STD_LOGIC_VECTOR(31 downto 0);
		
		--ID_EX_Rs: out STD_LOGIC_VECTOR(4 downto 0);
      --ID_EX_Rt: out STD_LOGIC_VECTOR(4 downto 0);
		EX_MEM_RegWrite :out STD_LOGIC;
		MEM_WB_RegWrite : out STD_LOGIC;
      EX_MEM_Rd: out STD_LOGIC_VECTOR(4 downto 0);
		MEM_WB_Rd: out STD_LOGIC_VECTOR(4 downto 0);
		
		FWDSel1 :out STD_LOGIC_VECTOR(1 downto 0);
		FWDSel2 :out STD_LOGIC_VECTOR(1 downto 0)
	);
end MIPS_PROCESSOR;





architecture arch of MIPS_PROCESSOR is
--Components Declaration
	component PC_Counter is 
			Port(
				PC_In : in STD_LOGIC_VECTOR(31 downto 0);
				Clk : in STD_LOGIC;
				Reset : in STD_LOGIC;
				StallIF: in std_logic;
				PC_Out : out STD_LOGIC_VECTOR(31 downto 0) 
			);
	end component;

	component Control_Unit is
        Port (
            Operation: in std_logic_vector(5 downto 0);
            MemWrite, MemtoReg, MemRead: out std_logic;
            RegWrite, RegDst, ALUSrc, Branch, Jump: out std_logic;
            ALUOp: out std_logic_vector(1 downto 0);
				funct  : in std_logic_vector(5 downto 0)
        );
    end component;

	component ALU_Control is
        Port (
            Fct: in std_logic_vector(5 downto 0);
            ALUOp: in std_logic_vector(1 downto 0);
            ALUControl: out std_logic_vector(2 downto 0)
        );
    end component;
	 
	component ALU is 
        Port(
				Clk : in STD_LOGIC;
				ALUControl: in std_logic_vector(2 downto 0);
				OP1: in std_logic_vector(31 downto 0);
				OP2: in std_logic_vector(31 downto 0);
				ALU_Result: buffer std_logic_vector(31 downto 0);
				Bcond: out std_logic
			);
    end component;
	 
	component Register_File is
			  Port (
				Clk, Reset: in std_logic;--,assign
				RegWrite: in std_logic;
				Read_Addr_1, Read_Addr_2, Write_Addr: in std_logic_vector(4 downto 0);
				Write_Data: in std_logic_vector(31 downto 0);
				Read_Data_1, Read_Data_2: out std_logic_vector(31 downto 0)
			  );
			 end component;
	 
	component Data_Memory is
        Port(
				MemWrite, MemRead, Clk: in std_logic;
            Address: in std_logic_vector(31 downto 0);
            Write_Data: in std_logic_vector(31 downto 0);
            Read_Data: out std_logic_vector(31 downto 0)
        );
    end component;
	 
   component Instruction_Memory is
			Port (
				Read_Addr: in std_logic_vector(31 downto 0);
				Instr : out  std_logic_vector(31 downto 0)
			);
    end component;
	 
	component Sign_Extend is 
			Port( 
				Data_In :in std_logic_vector(15 downto 0);
				Data_Out: out std_logic_vector(31 downto 0)
				  );
	 end component;
	 
	component Mux_32_Bits is 
			Port (
				Mux_In_0, Mux_In_1 : in STD_LOGIC_VECTOR(31 downto 0);
				Sel : in STD_LOGIC;
				Mux_Out : out STD_LOGIC_VECTOR(31 downto 0)
			);
	 end component;
	
	
	component Mux_5_Bits is 
			Port (
				Mux_In_0, Mux_In_1 : in STD_LOGIC_VECTOR(4 downto 0);
				Sel : in STD_LOGIC;
				Mux_Out : out STD_LOGIC_VECTOR(4 downto 0)
			);
	 end component;
	 
	 component Mux_1_Bits is 
			Port (
				Mux_In_0, Mux_In_1 : in STD_LOGIC;
				Sel : in STD_LOGIC;
				Mux_Out : out STD_LOGIC
			);
	 end component;
		
	component Adder_32_Bits is 
			port(
				A: in STD_LOGIC_VECTOR(31 downto 0);
				B: in STD_LOGIC_VECTOR(31 downto 0);
				Sum: out STD_LOGIC_VECTOR(31 downto 0)
			);
	end component;
	
	component D_FlipFlop is 
			port(
				 Clk,aReset : in std_logic;
				 Data_In :in std_logic_vector(31 downto 0);
				 Data_Out: out std_logic_vector(31 downto 0)
			);
	end component;
	
	component D_FlipFlop_1bit is 
     port(
			 Clk,aReset : in std_logic;
          Data_In :in std_logic;
          Data_Out: out std_logic
     );
	end component;
	
	component D_FlipFlop_2bit is 
     port(
			 Clk,aReset : in std_logic;
          Data_In :in std_logic_vector(1 downto 0);
          Data_Out: out std_logic_vector(1 downto 0)
     );
	end component;
	
	component D_FlipFlop_5bit is 
     port(
			 Clk,aReset : in std_logic;
          Data_In :in std_logic_vector(4 downto 0);
          Data_Out: out std_logic_vector(4 downto 0)
     );
	end component;

	component FORWARD_UNIT is
		 Port ( 
			  ID_EX_Rs: in STD_LOGIC_VECTOR(4 downto 0);
			  ID_EX_Rt: in STD_LOGIC_VECTOR(4 downto 0);
			  EX_MEM_Rd: in STD_LOGIC_VECTOR(4 downto 0);
			  EX_MEM_RegWrite : STD_LOGIC;
			  MEM_WB_Rd: in STD_LOGIC_VECTOR(4 downto 0);
			  MEM_WB_RegWrite : in STD_LOGIC;
			  FORWARD_Out_1 : out STD_LOGIC_VECTOR(1 downto 0);
			  FORWARD_Out_2 : out STD_LOGIC_VECTOR(1 downto 0)
		 );
	end component;
	
	component Forwarding_Mux is 
			Port (
				Mux_In_0, Mux_In_1, Mux_In_2 : in STD_LOGIC_VECTOR(31 downto 0);
				Sel : in STD_LOGIC_VECTOR(1 downto 0);
				Mux_Out : out STD_LOGIC_VECTOR(31 downto 0)
			);
	 end component;
	
	component D_FlipFlop_EN is 
			port(
				 Clk,aReset,Enable : in std_logic;
				 Data_In :in std_logic_vector(31 downto 0);
				 Data_Out: out std_logic_vector(31 downto 0)
		  );
	end component;
	
	component Hazard_Unit is
		   Port ( 
			  	Operation: in std_logic_vector(5 downto 0);
				IF_ID_Rs: in STD_LOGIC_VECTOR(4 downto 0);
				IF_ID_Rt: in STD_LOGIC_VECTOR(4 downto 0);
				ID_EX_Rt: in STD_LOGIC_VECTOR(4 downto 0);
				MemRead_EX: in std_logic;	
				StallIF, StallID : out std_logic;
				CTRL_EN: out std_logic
		  );
	end component;
	
	
	
-- Signals
-- PC
signal PC_In: STD_LOGIC_VECTOR(31 downto 0);
signal PC_Out : STD_LOGIC_VECTOR(31 downto 0);
signal PC_Source: std_logic_vector(31 downto 0);

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
signal Branch_DM : std_logic;
signal RegWrite_DM : STD_LOGIC; ------output of the control unit

signal MemtoReg_WB: STD_LOGIC;
signal RegWrite_WB : STD_LOGIC; ------output of the control unit

signal Jump : std_logic;


-- Data Memory
signal Read_Data_ET4: STD_LOGIC_VECTOR(31 downto 0); 
signal Read_Data_ET5: STD_LOGIC_VECTOR(31 downto 0);


-- Branch
signal Branch_Addr_ET3: STD_LOGIC_VECTOR(31 downto 0);
signal Branch_Addr_ET4: STD_LOGIC_VECTOR(31 downto 0);
signal next_address_ET1: STD_LOGIC_VECTOR(31 downto 0);
signal next_address_ET2: STD_LOGIC_VECTOR(31 downto 0);
signal next_address_ET3: STD_LOGIC_VECTOR(31 downto 0);

signal Bcond_ET3  : std_logic;
signal Bcond_ET4  : std_logic;
signal PCSrc: std_logic;

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


BEGIN --////////////////////////////Instantation of components////////////////////////////////////

		--##########################  Instruction Fetch Stage  ############################
		-- Pc Counter
		PC: PC_Counter port map (PC_In => PC_In, Clk => Clk, Reset => Reset, PC_Out =>PC_Out, StallIF => StallIF);
		
		-- Instruction Memory
		IM: Instruction_Memory port map (Read_Addr => PC_Out, Instr => Instruction_ET1);
		
		-- Next Address
		Next_Address_Calc: Adder_32_Bits port map( A=> PC_Out, B=> One, Sum => next_address_ET1);
		
		--##########################  Instruction Decode Stage  ############################
		-- Register File
		RF: Register_File port map (Clk => Clk,
									Reset => Reset,
									RegWrite => RegWrite_WB,
									Read_Addr_1 => Instruction_ET2 (25 downto 21),
									Read_Addr_2 => Instruction_ET2 (20 downto 16),
									Write_Addr => Write_Addr_ET5,		
									Write_Data => RF_Write_Data,
									Read_Data_1 => Read_Data_1_ET2 ,																																			
									Read_Data_2 => Read_Data_2_ET2 );
		
		-- Control Unit
		CRLU: Control_Unit port map ( Operation => Instruction_ET2(31 downto 26), 
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
		SE: sign_extend port map (Data_In => Instruction_ET2(15 downto 0) , Data_Out => SignEx_ET2);
		
		-- Jump Multiplxer
		Jump_Selector : Mux_32_Bits port map (Mux_In_0 => PC_Source,
											Mux_In_1 => (next_address_ET2(31 downto 28) & "00" &Instruction_ET2(25 downto 0)),
											Sel => Jump,
											Mux_Out => PC_In );
											
		-- Hazard detector Unit
		Hazard_Detector: Hazard_Unit port map (Operation => Instruction_ET2(31 downto 26),
									IF_ID_Rs => Instruction_ET2 (25 downto 21),
									IF_ID_Rt => Instruction_ET2 (20 downto 16),
									ID_EX_Rt => Instruction_ET3 (20 downto 16),
									MemRead_EX => MemRead_EX,
									StallIF => StallIF,
									StallID => StallID,
									CTRL_EN => CTRL_EN);
									
		-- Control Signals Muxliplexer (Stalling in case of Load : Inserting NOP)
		Control_Selector_Memwrite : Mux_1_Bits port map (Mux_In_0 => To_Mux_MemWrite,
											Mux_In_1 => '0',
											Sel => CTRL_EN,
											Mux_Out => MemWrite);
		Control_Selector_MemtoReg : Mux_1_Bits port map (Mux_In_0 => To_Mux_MemtoReg,
											Mux_In_1 => '0',
											Sel => CTRL_EN,
											Mux_Out => MemtoReg);
		Control_Selector_MemRead  : Mux_1_Bits port map (Mux_In_0 => To_Mux_MemRead,
											Mux_In_1 => '0',
											Sel => CTRL_EN,
											Mux_Out => MemRead);
		Control_Selector_RegWrite : Mux_1_Bits port map (Mux_In_0 => To_Mux_RegWrite,
											Mux_In_1 => '0',
											Sel => CTRL_EN,
											Mux_Out => RegWrite);
		Control_Selector_Branch   : Mux_1_Bits port map (Mux_In_0 => To_Mux_Branch,
											Mux_In_1 => '0',
											Sel => CTRL_EN,
											Mux_Out => Branch);
		Control_Selector_RegDst   : Mux_1_Bits port map (Mux_In_0 => To_Mux_RegDst,
											Mux_In_1 => '0',
											Sel => CTRL_EN,
											Mux_Out => RegDst);
		Control_Selector_ALUSrc   : Mux_1_Bits port map (Mux_In_0 => To_Mux_ALUSrc,
											Mux_In_1 => '0',
											Sel => CTRL_EN,
											Mux_Out => ALUSrc);
		Control_Selector_Jump     : Mux_1_Bits port map (Mux_In_0 => To_Mux_Jump,
											Mux_In_1 => '0',
											Sel => CTRL_EN,
											Mux_Out => Jump);
		Control_Selector_ALUOp1   : Mux_1_Bits port map (Mux_In_0 => To_Mux_ALUOp(1),
											Mux_In_1 => '0',
											Sel => CTRL_EN,
											Mux_Out => ALUOp(1));
		Control_Selector_ALUOp2   : Mux_1_Bits port map (Mux_In_0 => To_Mux_ALUOp(0),
											Mux_In_1 => '0',
											Sel => CTRL_EN,
											Mux_Out => ALUOp(0));
		
							
		--##########################  Instruction Excute Stage  ############################
		-- ALU
		Arith_Logic_Unit: ALU port map (Clk => Clk ,
									ALUControl => ALUControl ,
									OP1 => ALU_In_1 ,
									OP2 => ALU_in_2 ,
									ALU_Result => ALU_Result_ET3 ,
									Bcond => Bcond_ET3);
									
		--MUX RegisterFile & SignExtend to ALU
		ALU_Source: Mux_32_Bits port map (Mux_In_0 => FWD_MUX2_Out_ET3 ,Mux_In_1 => SignEx_ET3 , Sel => ALUSrc_EX , Mux_Out => ALU_In_2 );
		
		-- ALU Control
		ALU_CRL: ALU_Control port map ( Fct => Instruction_ET3(5 downto 0), ALUOp => ALUOp_EX, ALUControl => ALUControl );
		
		-- Branch Address
		Branch_Address: Adder_32_Bits port map( A => SignEx_ET3, B => next_address_ET3, Sum => Branch_Addr_ET3);
		
		-- Forwarding Unit
		Forwarding_Unit : FORWARD_UNIT port map (
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
		RF_Address_Selector: Mux_5_Bits  port map (Mux_In_0 => Instruction_ET3 (20 downto 16) ,Mux_In_1 => Instruction_ET3 (15 downto 11), Sel => RegDst_EX, Mux_Out => Write_Addr_ET3);
						
		-- ALU input1 Multiplxer
		Forwarding_Mux1 : Forwarding_Mux port map (Mux_In_0 => Read_Data_1_ET3, Mux_In_1 => RF_Write_Data, Mux_In_2 => ALU_Result_ET4, Sel => FWD_U_Sel1, Mux_Out => ALU_In_1 );
		
		-- ALU input2 Multiplxer
		Forwarding_Mux2 : Forwarding_Mux port map (Mux_In_0 => Read_Data_2_ET3, Mux_In_1 => RF_Write_Data, Mux_In_2 => ALU_Result_ET4, Sel => FWD_U_Sel2, Mux_Out => FWD_MUX2_Out_ET3);

		--#############################  Data Memory  Stage  ###############################
		-- Data Memory
		DM : Data_Memory port map (Address=> ALU_Result_ET4 ,
											Write_Data => FWD_MUX2_Out_ET4,
											Read_Data => Read_Data_ET4,
											MemWrite => MemWrite_DM ,
											MemRead => MemRead_DM, 
											Clk => Clk );
		
		-- Branch Multiplxer
		Branch_Selector : Mux_32_Bits port map (Mux_In_0 => next_address_ET1,
											Mux_In_1 => Branch_Addr_ET4,
											Sel => PCSrc,
											Mux_Out => PC_Source );
											
		--#############################   Write Back  Stage  ###############################
		--DataMermory to RegisterFile
		RF_data_Selector: Mux_32_Bits port map (Mux_In_0 => ALU_Result_ET5, Mux_In_1 => Read_Data_ET5, Sel => MemtoReg_WB, Mux_Out => RF_Write_Data );

		
		
		
	

		--//////////////////////////// Instantation of Stages : DATA////////////////////////////////////
		
		--#############################   IF to ID  Stage      ###############################
		E1_Instruction:D_FlipFlop_EN port map(Clk=>Clk,aReset=>Reset,Enable=>StallID,Data_In=>Instruction_ET1,Data_Out=>Instruction_ET2);
		E1_Next_Address:D_FlipFlop_EN port map(Clk=>Clk,aReset=>Reset,Enable=>StallID,Data_In=>next_address_ET1,Data_Out=>next_address_ET2);
		
		--#############################   ID to Excute  Stage  ###############################
		E2_Instruction:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Instruction_ET2,Data_Out=>Instruction_ET3);
		E2_Read_Data_1:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Read_Data_1_ET2,Data_Out=>Read_Data_1_ET3);
		E2_Read_Data_2:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Read_Data_2_ET2,Data_Out=>Read_Data_2_ET3);
		E2_Sign_Extend:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>SignEx_ET2,Data_Out=>SignEx_ET3);
		E2_Next_Address:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>next_address_ET2,Data_Out=>next_address_ET3);
		
		--#############################   Excute to DM  Stage  ###############################
		E3_Instruction:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Instruction_ET3,Data_Out=>Instruction_ET4);
		E3_Branch_Address:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Branch_Addr_ET3,Data_Out=>Branch_Addr_ET4);
		E3_Alu_Result:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>ALU_Result_ET3,Data_Out=>ALU_Result_ET4);
		E3_Read_Data_2:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>FWD_MUX2_Out_ET3,Data_Out=>FWD_MUX2_Out_ET4);
		E3_Bcond:D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>Bcond_ET3,Data_Out=>Bcond_ET4);
		E3_Write_Addr:D_FlipFlop_5bit port map (Clk=>Clk,aReset=>Reset,Data_In=> Write_Addr_ET3 ,Data_Out=>Write_Addr_ET4 );
		
		--#############################   DM to WB  Stage      ###############################
		E4_Instruction:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Instruction_ET4,Data_Out=>Instruction_ET5);
		E4_Read_Data:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Read_Data_ET4,Data_Out=>Read_Data_ET5);
		E4_Alu_Result:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>ALU_Result_ET4,Data_Out=>ALU_Result_ET5);
		E4_Write_Addr:D_FlipFlop_5bit port map (Clk=>Clk,aReset=>Reset,Data_In=> Write_Addr_ET4 ,Data_Out=>Write_Addr_ET5 );
		
		
		
		
		
		
		--//////////////////////////// Instantation of Stages : Control////////////////////////////////////
		
      --#############################   ID to Excute  Stage  ###############################
		EX_MemWrite :D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>MemWrite ,Data_Out=>MemWrite_EX);
		EX_MemtoReg :D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>MemtoReg ,Data_Out=>MemtoReg_EX);
		EX_MemRead:D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>MemRead,Data_Out=>MemRead_EX);
		EX_RegWrite:D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>RegWrite,Data_Out=>RegWrite_EX);
		EX_Branch:D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>Branch,Data_Out=>Branch_EX);
		EX_RegDst:D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>RegDst,Data_Out=>RegDst_EX);
		EX_ALUSrc:D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>ALUSrc,Data_Out=>ALUSrc_EX);
		EX_ALUOp:D_FlipFlop_2bit port map(Clk=>Clk,aReset=>Reset,Data_In=>ALUOp,Data_Out=>ALUOp_EX);
		
		--#############################   Excute to DM  Stage  ###############################
		DM_MemWrite :D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>MemWrite_EX ,Data_Out=>MemWrite_DM);
		DM_MemtoReg :D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>MemtoReg_EX ,Data_Out=>MemtoReg_DM);
		DM_MemRead:D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>MemRead_EX,Data_Out=>MemRead_DM);
		DM_RegWrite:D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>RegWrite_EX,Data_Out=>RegWrite_DM);
		DM_Branch:D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>Branch_EX,Data_Out=>Branch_DM);
		
		--#############################   DM to WB  Stage      ###############################
		WB_MemtoReg :D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>MemtoReg_DM ,Data_Out=>MemtoReg_WB);
		WB_RegWrite:D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>RegWrite_DM,Data_Out=>RegWrite_WB);
		
		
		
		
		
		--////////////////////////////      Assignments    /////////////////////////////////////
		
		PCSrc <= Branch_DM and Bcond_ET4;
--			MemWrite<=  Control_Signals(4);
--			MemtoReg<=  Control_Signals(3);
--			MemRead<=   Control_Signals(9);
--			RegWrite<=  Control_Signals(8);
--			Branch <=   Control_Signals(5);
--			RegDst <=   Control_Signals(7);
--			ALUSrc <=   Control_Signals(6);
--			Jump <=     Control_Signals(2);
--			ALUOp <=    Control_Signals (1 downto 0);
		
		--////////////////////////////  Outputs For Debugging    /////////////////////////////////////
		
		Instruction_ET2_out <= Instruction_ET2;
		Read_Data_1_ET2_out <= Read_Data_1_ET2;
		Read_Data_2_ET2_out <= Read_Data_2_ET2;
		RF_Write_Data_o <= RF_Write_Data;
		
		ALU_In_1_Out<=ALU_In_1;
		ALU_In_2_Out<=ALU_In_2;
		ALU_Result_ET3_out <= ALU_Result_ET3;
		FWDSEL1<=FWD_U_Sel1;
		FWDSEL2<=FWD_U_Sel2;
		
		Address <= ALU_Result_ET4;
		WriteData <= FWD_MUX2_Out_ET4;
		EX_MEM_Rd<=Write_Addr_ET4 ;
      EX_MEM_RegWrite<=RegWrite_DM; 
		Memout<=Read_Data_ET4;
		
      MEM_WB_Rd<=Write_Addr_ET5;
		MEM_WB_RegWrite<= RegWrite_WB;
		
end arch;
			


			
			
			
			
			


--MUX 32 BITS
library ieee;
use ieee.std_logic_1164.all;

entity Mux_32_Bits is 
	Port (
		Mux_In_0, Mux_In_1 : in STD_LOGIC_VECTOR(31 downto 0);
		Sel : in STD_LOGIC;
		Mux_Out : out STD_LOGIC_VECTOR(31 downto 0)
	);
end Mux_32_Bits;

architecture arch of Mux_32_Bits is 

begin 
    process(Sel)
	   begin 
		    if(Sel='0') then 
				Mux_Out<=Mux_In_0;
			else 
				Mux_Out<=Mux_In_1;
			end if;
	end process;
end arch;







--MUX 5 BITS
library ieee;
use ieee.std_logic_1164.all;

entity Mux_5_Bits is 
		port( 
			Mux_In_0, Mux_In_1 : in STD_LOGIC_VECTOR(4 downto 0);
			Sel : in STD_LOGIC;
			Mux_Out : out STD_LOGIC_VECTOR(4 downto 0));
end Mux_5_Bits;

architecture arch of Mux_5_Bits is 
begin 
    process(Sel)
	   begin 
		    if(Sel='0') then 
			    Mux_Out <= Mux_In_0;
			else 
			    mux_out <= Mux_In_1;
			end if;
	end process;
end arch;



--MUX 1 BITS
library ieee;
use ieee.std_logic_1164.all;

entity Mux_1_Bits is 
		port( 
			Mux_In_0, Mux_In_1 : in STD_LOGIC;
			Sel : in STD_LOGIC;
			Mux_Out : out STD_LOGIC);
end Mux_1_Bits;

architecture arch of Mux_1_Bits is 
begin 
    process(Sel)
	   begin 
		    if(Sel='0') then 
			    Mux_Out <= Mux_In_0;
			else 
			    mux_out <= Mux_In_1;
			end if;
	end process;
end arch;



--Adder_32_Bits
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

entity Adder_32_Bits is 
port(
	A: in STD_LOGIC_VECTOR(31 downto 0);
	B: in STD_LOGIC_VECTOR(31 downto 0);
	Sum: out STD_LOGIC_VECTOR(31 downto 0)
	);
end Adder_32_Bits;

architecture behavior of Adder_32_Bits is
begin 
	Sum <= std_logic_vector(unsigned(A)+unsigned(B));
end behavior;






--sign_extend
library ieee;
use ieee.std_logic_1164.all;

entity sign_extend is 
     port(
          Data_In :in std_logic_vector(15 downto 0);
          Data_Out: out std_logic_vector(31 downto 0)
     );
end sign_extend;

architecture arch of sign_extend is
begin
  Data_Out<= x"0000"& Data_In;
end arch;





--Flip Flop 32 bits
library ieee;
use ieee.std_logic_1164.all;

entity D_FlipFlop is 
     port(
			 Clk,aReset : in std_logic;
          Data_In :in std_logic_vector(31 downto 0);
          Data_Out: out std_logic_vector(31 downto 0)
     );
end D_FlipFlop;

architecture arch of D_FlipFlop is
begin
  process(Clk)
  begin
	if(aReset = '1') then
		Data_Out <= (others => '0');
	elsif(rising_edge(Clk)) then
		Data_Out <= Data_In;
	end if;
  end process;
end arch;



--Flip Flop 32 bits with Enable
library ieee;
use ieee.std_logic_1164.all;

entity D_FlipFlop_EN is 
     port(
			 Clk,aReset,Enable : in std_logic;
          Data_In :in std_logic_vector(31 downto 0);
          Data_Out: out std_logic_vector(31 downto 0)
     );
end D_FlipFlop_EN;

architecture arch of D_FlipFlop_EN is
begin
  process(Clk)
  begin
	if(aReset = '1') then
		Data_Out <= (others => '0');
	elsif(rising_edge(Clk)) then
		if(Enable = '0') then
			Data_Out <= Data_In;
		end if;
	end if;
  end process;
end arch;



--flip flop 5 bit 

library ieee;
use ieee.std_logic_1164.all;

entity D_FlipFlop_5bit is 
     port(
			 Clk,aReset : in std_logic;
          Data_In :in std_logic_vector(4 downto 0);
          Data_Out: out std_logic_vector(4 downto 0)
     );
end D_FlipFlop_5bit;

architecture arch of D_FlipFlop_5bit is
begin
  process(Clk)
  begin
	if(aReset = '1') then
		Data_Out <= "00000";
	elsif(rising_edge(Clk)) then
		Data_Out <= Data_In;
	end if;
  end process;
end arch;





--flip flop 2 bit 

library ieee;
use ieee.std_logic_1164.all;

entity D_FlipFlop_2bit is 
     port(
			 Clk,aReset : in std_logic;
          Data_In :in std_logic_vector(1 downto 0);
          Data_Out: out std_logic_vector(1 downto 0)
     );
end D_FlipFlop_2bit;

architecture arch of D_FlipFlop_2bit is
begin
  process(Clk)
  begin
	if(aReset = '1') then
		Data_Out <= "00";
	elsif(rising_edge(Clk)) then
		Data_Out <= Data_In;
	end if;
  end process;
end arch;





--Flip Flop 1 bit
library ieee;
use ieee.std_logic_1164.all;

entity D_FlipFlop_1bit is 
     port(
			 Clk,aReset : in std_logic;
          Data_In :in std_logic;
          Data_Out: out std_logic
     );
end D_FlipFlop_1bit;

architecture arch of D_FlipFlop_1bit is
begin
  process(Clk)
  begin
	if(aReset = '1') then
		Data_Out <= '0';
	elsif(rising_edge(Clk)) then
		Data_Out <= Data_In;
	end if;
  end process;
end arch;




--Forwarding_Mux

library ieee;
use ieee.std_logic_1164.all;

entity Forwarding_Mux is 
	Port (
		Mux_In_0, Mux_In_1, Mux_In_2 : in STD_LOGIC_VECTOR(31 downto 0);
		Sel : in STD_LOGIC_VECTOR(1 downto 0);
		Mux_Out : out STD_LOGIC_VECTOR(31 downto 0)
	);
end Forwarding_Mux;

architecture arch of Forwarding_Mux is 

begin 
    process(Sel)
	   begin 
			case(Sel) is 
				when "01" => Mux_Out <= Mux_In_1;
				when "10" => Mux_Out <= Mux_In_2;
				when others => Mux_Out <= Mux_In_0;
		    end case;
	end process;
end arch;