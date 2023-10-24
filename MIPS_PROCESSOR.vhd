library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS_PROCESSOR is
	Port(
		Clk : in STD_LOGIC;
		Reset : in STD_LOGIC
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
				OP1: in std_logic_vector(31 downto 0);
				OP2: in std_logic_vector(31 downto 0);
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
	 
	component Data_Memory is
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
	
	
	component Mux_5_Bits is 
			Port (
				Mux_In_0, Mux_In_1 : in STD_LOGIC_VECTOR(4 downto 0);
				Sel : in STD_LOGIC;
				Mux_Out : out STD_LOGIC_VECTOR(4 downto 0)
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

	
	
	
	
-- signals 

signal PC_Out : STD_LOGIC_VECTOR(31 downto 0);
signal Instruction_ET1 : STD_LOGIC_VECTOR(31 downto 0);
signal Instruction_ET2 : STD_LOGIC_VECTOR(31 downto 0);
signal Instruction_ET3 : STD_LOGIC_VECTOR(31 downto 0);
signal Instruction_ET4 : STD_LOGIC_VECTOR(31 downto 0);
signal Instruction_ET5 : STD_LOGIC_VECTOR(31 downto 0);

signal Read_Data_1_ET2 : STD_LOGIC_VECTOR(31 downto 0);
signal Read_Data_1_ET3 : STD_LOGIC_VECTOR(31 downto 0);
signal Read_Data_2_ET2 : STD_LOGIC_VECTOR(31 downto 0);
signal Read_Data_2_ET3 : STD_LOGIC_VECTOR(31 downto 0);
signal Read_Data_2_ET4 : STD_LOGIC_VECTOR(31 downto 0);
signal SignEx_ET2 : STD_LOGIC_VECTOR(31 downto 0);
signal SignEx_ET3 : STD_LOGIC_VECTOR(31 downto 0);


signal ALU_In_2 : STD_LOGIC_VECTOR(31 downto 0);  --input2 of ALU
signal RegWrite : STD_LOGIC; ------output of the control unit 

--ALU signals

signal ALUControl : STD_LOGIC_VECTOR(2 downto 0); -----output of ALU coming from ALUcontrol
signal ALU_Result_ET3 : STD_LOGIC_VECTOR(31 downto 0);
signal ALU_Result_ET4 : STD_LOGIC_VECTOR(31 downto 0);
signal ALU_Result_ET5 : STD_LOGIC_VECTOR(31 downto 0);


-- Control Unit 
signal MemWrite : STD_LOGIC;
signal MemRead : STD_LOGIC;
signal MemtoReg : STD_LOGIC;
signal RegDst : STD_LOGIC;
signal ALUSrc : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(1 downto 0);


signal Write_Addr: STD_LOGIC_VECTOR(4 downto 0);
signal RF_Write_Data : STD_LOGIC_VECTOR(31 downto 0);


signal Read_Data_ET4: STD_LOGIC_VECTOR(31 downto 0); 
signal Read_Data_ET5: STD_LOGIC_VECTOR(31 downto 0);


signal PC_In: STD_LOGIC_VECTOR(31 downto 0);
signal Branch_Addr_ET3: STD_LOGIC_VECTOR(31 downto 0);
signal Branch_Addr_ET4: STD_LOGIC_VECTOR(31 downto 0);
signal next_address_ET1: STD_LOGIC_VECTOR(31 downto 0);
signal next_address_ET2: STD_LOGIC_VECTOR(31 downto 0);
signal next_address_ET3: STD_LOGIC_VECTOR(31 downto 0);
signal next_address_ET4: STD_LOGIC_VECTOR(31 downto 0);

signal One: STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000001";
signal Branch : std_logic;
signal Bcond_ET3  : std_logic;
signal Bcond_ET4  : std_logic;
signal PCSrc: std_logic;
signal Jump : std_logic;
signal PC_Source: std_logic_vector(31 downto 0);





BEGIN
		PC: PC_Counter port map (PC_In => PC_In, Clk => Clk, Reset => Reset, PC_Out =>PC_Out );
		IM: Instruction_Memory port map (Read_Addr => PC_Out, Instr => Instruction_ET1);
		--MUXs
		--MUX RegisterFile & SignExtend to ALU
		ALU_Source: Mux_32_Bits port map (Mux_In_0 => Read_Data_2_ET3 ,Mux_In_1 => SignEx_ET3 , Sel => ALUSrc , Mux_Out => ALU_In_2 );
		--MUX IM to RegisterFile
		RF_Address_Selector: Mux_5_Bits  port map (Mux_In_0 => Instruction_ET5 (20 downto 16) ,Mux_In_1 => Instruction_ET5 (15 downto 11), Sel => RegDst, Mux_Out => Write_Addr);
		--DataMermory to RegisterFile
		RF_data_Selector: Mux_32_Bits port map (Mux_In_0 => ALU_Result_ET5, Mux_In_1 => Read_Data_ET5, Sel => MemtoReg, Mux_Out => RF_Write_Data );

		SE: sign_extend port map (Data_In => Instruction_ET2(15 downto 0) , Data_Out => SignEx_ET2);
		
		RF: Register_File port map (Clk => Clk, 
									Reset => Reset,
									RegWrite => RegWrite,
									Read_Addr_1 => Instruction_ET2 (25 downto 21) ,
									Read_Addr_2 => Instruction_ET2 (20 downto 16),
									Write_Addr => Write_Addr,		
									Write_Data => RF_Write_Data,
									Read_Data_1 => Read_Data_1_ET2 ,																																			
									Read_Data_2 => Read_Data_2_ET2 );
											
											
		Arith_Logic_Unit: ALU port map (ALUControl => ALUControl , OP1 => Read_Data_1_ET3 , OP2 => ALU_in_2 , ALU_Result => ALU_Result_ET3 ,Bcond => Bcond_ET3);
		
		CRLU: Control_Unit port map ( Operation => Instruction_ET2(31 downto 26),
									MemWrite => MemWrite, 
									MemtoReg => MemtoReg , 
									MemRead => MemRead,
									RegWrite => RegWrite , 
									Branch => Branch,
									RegDst => RegDst,
									ALUSrc => ALUSrc,
									Jump => Jump,
									ALUOp => ALUOp);  
---Change the etage here of instruction to where the alu control is
		ALU_CRL: ALU_Control port map ( Fct => Instruction_ET3(5 downto 0), ALUOp => ALUOp, ALUControl => ALUControl );
		
		DM : Data_Memory port map (  Address=> ALU_Result_ET4(9 downto 0) ,
											Write_Data => Read_Data_2_ET4 ,
											Read_Data => Read_Data_ET4,
											MemWrite => MemWrite ,
											MemRead => MemRead, 
											Clk => Clk );


		Branch_Address: Adder_32_Bits port map( A => SignEx_ET3, B => next_address_ET3, Sum => Branch_Addr_ET3);
		Next_Address_Calc: Adder_32_Bits port map( A=> PC_Out, B=> One, Sum => next_address_ET1); 

		Branch_Selector : Mux_32_Bits port map (Mux_In_0 => next_address_ET1, Mux_In_1 => Branch_Addr_ET4, Sel => PCSrc, Mux_Out => PC_Source );
		Jump_Selector : Mux_32_Bits port map (Mux_In_0 => PC_Source, Mux_In_1 => (next_address_ET2(31 downto 28) & "00" &Instruction_ET2(25 downto 0)), Sel => Jump, Mux_Out => PC_In );

		PCSrc <= Branch and Bcond_ET4;
		
		E1_Instruction:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Instruction_ET1,Data_Out=>Instruction_ET2);
		E1_Next_Address:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>next_address_ET1,Data_Out=>next_address_ET2);
		
		E2_Instruction:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Instruction_ET2,Data_Out=>Instruction_ET3);
		E2_Read_Data_1:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Read_Data_1_ET2,Data_Out=>Read_Data_1_ET3);
		E2_Read_Data_2:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Read_Data_2_ET2,Data_Out=>Read_Data_2_ET3);
		E2_Sign_Extend:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>SignEx_ET2,Data_Out=>SignEx_ET3);
		E2_Next_Address:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>next_address_ET2,Data_Out=>next_address_ET3);
		
		E3_Instruction:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Instruction_ET3,Data_Out=>Instruction_ET4);
		--E3_Next_Address:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>next_address_ET3,Data_Out=>next_address_ET4);
		E3_Branch_Address:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Branch_Addr_ET3,Data_Out=>Branch_Addr_ET4);
		E3_Alu_Result:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>ALU_Result_ET3,Data_Out=>ALU_Result_ET4);
		E3_Read_Data_2:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Read_Data_2_ET3,Data_Out=>Read_Data_2_ET4);
		E3_Bcond:D_FlipFlop_1bit port map(Clk=>Clk,aReset=>Reset,Data_In=>Bcond_ET3,Data_Out=>Bcond_ET4);
		
		E4_Instruction:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Instruction_ET4,Data_Out=>Instruction_ET5);
		E4_Read_Data:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>Read_Data_ET4,Data_Out=>Read_Data_ET5);
		E4_Alu_Result:D_FlipFlop port map(Clk=>Clk,aReset=>Reset,Data_In=>ALU_Result_ET4,Data_Out=>ALU_Result_ET5);

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





--Flip Flop
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
