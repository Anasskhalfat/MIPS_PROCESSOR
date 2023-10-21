library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS_PROCESSOR is 
	Port(
		Clk : in STD_LOGIC;
		Reset : in STD_LOGIC;
		Instr_Out : out std_logic_vector(31 downto 0);
		
		RF_Input_1 : out std_logic_vector(4 downto 0);
		RF_Input_2 : out std_logic_vector(4 downto 0);
		RF_Ouput_1 : out std_logic_vector(31 downto 0);
		RF_Ouput_2 : out std_logic_vector(31 downto 0);
		Out_Result : out std_logic_vector(31 downto 0)
	);
end MIPS_PROCESSOR;

architecture arch of MIPS_PROCESSOR is 
--Components Declaration
	component PC_Counter is 
		Port(
			PC_In : in STD_LOGIC_VECTOR(31 downto 0);
			Clk : in STD_LOGIC;
			Reset : in STD_LOGIC;
			PC_Out : out STD_LOGIC_VECTOR(31 downto 0) 
		);
	end component;

	component Control_Unit is
        Port (
            Operation: in std_logic_vector(5 downto 0);
            MemWrite, MemtoReg, MemRead: out std_logic;
            RegWrite, RegDst, ALUSrc, Branch, Jump: out std_logic;
            ALUOp: out std_logic_vector(1 downto 0)
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
				ALUControl: in std_logic_vector(2 downto 0);
				RS: in std_logic_vector(31 downto 0);
				RT: in std_logic_vector(31 downto 0);
				ALU_Result: buffer std_logic_vector(31 downto 0);
				Bcond: out std_logic
			);
    end component;
	 
	component Register_File is
			  Port (
				Clk, Reset: in std_logic;
				RegWrite: in std_logic;
				Read_Addr_1, Read_Addr_2, Write_Addr: in std_logic_vector(4 downto 0);
				Write_Data: in std_logic_vector(31 downto 0);
				Read_Data_1, Read_Data_2: out std_logic_vector(31 downto 0)
			  );
			 end component;
	 
	component Data_Memory_32bits is
        Port(
				MemWrite, MemRead, Clk: in std_logic;
            Address: in std_logic_vector(9 downto 0);
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
	
	component Mux_2_Bits is 
			Port (
				Mux_In_0, Mux_In_1 : in STD_LOGIC_VECTOR(1 downto 0);
				Sel : in STD_LOGIC;
				Mux_Out : out STD_LOGIC_VECTOR(1 downto 0)
			);
	 end component;
	
	component Mux_5_Bits is 
			Port (
				Mux_In_0, Mux_In_1 : in STD_LOGIC_VECTOR(4 downto 0);
				Sel : in STD_LOGIC;
				Mux_Out : out STD_LOGIC_VECTOR(4 downto 0)
			);
	 end component;
	 
	component L_Shifter_32_Bits is
			port(
				Data_In: in STD_LOGIC_VECTOR(31 downto 0);
				Data_Out: out STD_LOGIC_VECTOR(31 downto 0)
			);
	end component;
		
	component Adder_32_Bits is 
			port(
				A: in STD_LOGIC_VECTOR(31 downto 0);
				B: in STD_LOGIC_VECTOR(31 downto 0);
				Sum: out STD_LOGIC_VECTOR(31 downto 0)
			);
	end component;
		
	component  L_Shifter_26_Bits is
			port(
				Data_In: in STD_LOGIC_VECTOR(25 downto 0);
				Data_Out: out STD_LOGIC_VECTOR(27 downto 0)
			);
	end component;

-- signals 

signal PC_Out : STD_LOGIC_VECTOR(31 downto 0); --ouput of PC input of IM
signal Instruction : STD_LOGIC_VECTOR(31 downto 0); --output of IM
signal Read_Data_1 : STD_LOGIC_VECTOR(31 downto 0);   --output data of register file
signal Read_Data_2 : STD_LOGIC_VECTOR(31 downto 0);	--output data of register file input of mux M1
signal SignEx : STD_LOGIC_VECTOR(31 downto 0);  -- output of signExtend input of ALU


signal ALU_In_2 : STD_LOGIC_VECTOR(31 downto 0);  --input2 of ALU
signal RegWrite : STD_LOGIC; ------output of the control unit 

--ALU signals

signal ALUControl : STD_LOGIC_VECTOR(2 downto 0); -----output of ALU coming from ALUcontrol
signal ALU_Result : STD_LOGIC_VECTOR(31 downto 0);

-- Control Unit 
signal MemWrite : STD_LOGIC;
signal MemRead : STD_LOGIC;
signal MemtoReg : STD_LOGIC;
signal RegDst : STD_LOGIC;
signal ALUSrc : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(1 downto 0);

--MUX to RgisterFile 

signal Write_Addr: STD_LOGIC_VECTOR(4 downto 0);

--DataMemory

signal Read_Data: STD_LOGIC_VECTOR(31 downto 0); 

signal RF_Write_Data : STD_LOGIC_VECTOR(31 downto 0);

signal PC_In: STD_LOGIC_VECTOR(31 downto 0);
signal Branch_Addr: STD_LOGIC_VECTOR(31 downto 0);
signal next_address: STD_LOGIC_VECTOR(31 downto 0);

signal One: STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000001";
signal Branch : std_logic;
signal Bcond  : std_logic;
signal PCSrc: std_logic;
signal Jump : std_logic;
signal Jump_Offset: std_logic_vector(27 downto 0);
signal PC_Source: std_logic_vector(31 downto 0);
signal Branch_Offset: std_logic_vector(31 downto 0);


BEGIN
		PC: PC_Counter port map (PC_In => PC_In, Clk => Clk, Reset => Reset, PC_Out =>PC_Out );
		IM: Instruction_Memory port map (Read_Addr => PC_Out, Instr => Instruction);
		--MUXs
		--MUX RegisterFile & SignExtend to ALU
		ALU_Source: Mux_32_Bits port map (Mux_In_0 => Read_Data_2 ,Mux_In_1 => SignEX , Sel => ALUSrc , Mux_Out => ALU_In_2 );
		--MUX IM to RegisterFile
		RF_Address_Selector: Mux_5_Bits  port map (Mux_In_0 => Instruction (20 downto 16) ,Mux_In_1 => Instruction (15 downto 11), Sel => RegDst, Mux_Out => Write_Addr);
		--DataMermory to RegisterFile
		RF_data_Selector: Mux_32_Bits port map (Mux_In_0 => ALU_Result, Mux_In_1 => Read_Data, Sel => MemtoReg, Mux_Out => RF_Write_Data );

		SE: sign_extend port map (Data_In => instruction(15 downto 0) , Data_Out => SignEX);
		
		RF: Register_File port map (Clk => Clk, 
									Reset => Reset,
									RegWrite => RegWrite,
									Read_Addr_1 => instruction (25 downto 21) ,
									Read_Addr_2 => instruction (20 downto 16),
									Write_Addr => Write_Addr,		
									Write_Data => RF_Write_Data,
									Read_Data_1 => Read_Data_1 ,																																			
									Read_Data_2 => Read_Data_2 );
											
											
		Arith_Logic_Unit: ALU port map (ALUControl => ALUControl , RS => Read_Data_1 , RT => ALU_in_2 , ALU_Result => ALU_Result ,Bcond => Bcond);
		
		CRLU: Control_Unit port map ( Operation => instruction(31 downto 26),
									MemWrite => MemWrite, 
									MemtoReg => MemtoReg , 
									MemRead => MemRead,
									RegWrite => RegWrite , 
									Branch => Branch,
									RegDst => RegDst,
									ALUSrc => ALUSrc,
									Jump => Jump,
									ALUOp => ALUOp);  

		ALU_CRL: ALU_Control port map ( Fct => Instruction(5 downto 0), ALUOp => ALUOp, ALUControl => ALUControl );
		
		DM : Data_Memory_32bits port map (  Address=> ALU_Result(9 downto 0) ,
											Write_Data => Read_Data_2 ,
											Read_Data => Read_Data,
											MemWrite => MemWrite ,
											MemRead => MemRead, 
											Clk => Clk );


		Branch_Shifter: L_Shifter_32_Bits port map( Data_In => SignEX, Data_Out => Branch_Offset);
		
		Branch_Address: Adder_32_Bits port map( A => Branch_Offset, B => Next_Address, Sum => Branch_Addr);
		Next_Address_Calc: Adder_32_Bits port map( A=> PC_Out, B=> One, Sum => Next_Address);  
		Branch_Selector : Mux_32_Bits port map (Mux_In_0 => next_address, Mux_In_1 => Branch_Addr, Sel => PCSrc, Mux_Out => PC_Source );
		Jump_Selector : Mux_32_Bits port map (Mux_In_0 => PC_Source, Mux_In_1 => (Next_Address(31 downto 28) & Jump_Offset), Sel => Jump, Mux_Out => PC_In );

		PCSrc <= Branch and Bcond;
		
		Jump_Shifter: L_Shifter_26_Bits port map(Data_In => Instruction(25 downto 0),Data_Out =>Jump_Offset);
		
		Instr_Out <= Instruction;
		RF_Input_1 <= Instruction(25 downto 21);
		RF_Input_2 <= Instruction(20 downto 16);
		RF_Ouput_1 <= Read_Data_1;
		RF_Ouput_2 <= Read_Data_2;
		Out_Result <= ALU_Result;

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



--L_Shifter_32_Bits
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity L_Shifter_32_Bits is
	port(
		Data_In: in STD_LOGIC_VECTOR(31 downto 0);
		Data_Out: out STD_LOGIC_VECTOR(31 downto 0)
	);
end L_Shifter_32_Bits;
	
architecture Behavioral of L_Shifter_32_Bits is
begin
	Data_Out <= STD_LOGIC_VECTOR(shift_left(unsigned(Data_In), 2));
end Behavioral;


--L_Shifter_26_Bits
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity L_Shifter_26_Bits is
	port(
		Data_In: in STD_LOGIC_VECTOR(25 downto 0);
		Data_Out: out STD_LOGIC_VECTOR(27 downto 0)
	);
end L_Shifter_26_Bits;
	
architecture behavioral of L_Shifter_26_Bits is
begin
	Data_Out <= STD_LOGIC_VECTOR(shift_left(unsigned(Data_In), 2)) & "00";
end behavioral;


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