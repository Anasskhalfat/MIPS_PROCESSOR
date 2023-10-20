library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS_PROCESSOR is 

	Port(
	pc : in STD_LOGIC_VECTOR(1 downto 0) := "00";
	clk : in STD_LOGIC;
	reset : in STD_LOGIC
		);
		
end MIPS_PROCESSOR;

architecture arch of MIPS_PROCESSOR is 
--signals 
	component PCounter is 
		Port(
			pc : in STD_LOGIC_VECTOR(1 downto 0);
			clk : in STD_LOGIC;
			reset : in STD_LOGIC;
			dout : out STD_LOGIC_VECTOR(1 downto 0) 
		);
	end component;


	component ControlUnit is
        Port (
            op: in std_logic_vector(5 downto 0);
            memWrite, memtoReg, MemRead: out std_logic;
            --regWrite, regDst, alusrc, branch, pcSrc, jump: out std_logic;
				--we commented them so that we can do the processor without jump and branch 
				regWrite, regDst, alusrc: out std_logic;
            ALUOp: out std_logic_vector(1 downto 0)
        );
    end component;

	 component ALUControl is
        Port (
            fct: in std_logic_vector(5 downto 0);
            ALUOp: in std_logic_vector(1 downto 0);
            aluctrl: out std_logic_vector(2 downto 0)
        );
    end component;
	 
	 component ALU is 
        Port(
            ALU_control: in std_logic_vector(2 downto 0);
            rs: in std_logic_vector(31 downto 0);
            rt: in std_logic_vector(31 downto 0);
            rd: out std_logic_vector(31 downto 0)
        );
    end component;
	 
	 component RegisterFile is
        Port (
            clk, reset: in std_logic;
            readEnable : in std_logic;
            readRegister1, readRegister2, writeRegister: in std_logic_vector(4 downto 0);
            writeData: in std_logic_vector(31 downto 0);
            readData1, readData2: out std_logic_vector(31 downto 0)
        );
    end component;
	 
	 component Data_Memory_32bits is
        Port(
            Address: in std_logic_vector(9 downto 0);
            Write_Data: in std_logic_vector(31 downto 0);
            Read_Data: out std_logic_vector(31 downto 0);
            MemWrite, MemRead, Clock: in std_logic
        );
    end component;
	 
    component Instruction_Memory is
			Port (
				pc: in std_logic_vector(1 downto 0);
				instruction: out  std_logic_vector(31 downto 0)
			);
    end component;
	 
	 component sign_extend is 
     Port( 
				data_in :in std_logic_vector(15 downto 0);
				data_out: out std_logic_vector(31 downto 0)
			  );
	 end component;
	 
	 component Mux_32 is 
			Port (
				mux_in0, mux_in1 : in STD_LOGIC_VECTOR(31 downto 0);
				select_mux : in STD_LOGIC;
				mux_out : out STD_LOGIC_VECTOR(31 downto 0)
			);
	 end component;
	
	 component Mux_2 is 
			Port (
				mux_in0, mux_in1 : in STD_LOGIC_VECTOR(1 downto 0);
				select_mux : in STD_LOGIC;
				mux_out : out STD_LOGIC_VECTOR(1 downto 0)
			);
	 end component;
	
	 component Mux_5 is 
			Port (
				mux_in0, mux_in1 : in STD_LOGIC_VECTOR(4 downto 0);
				select_mux : in STD_LOGIC;
				mux_out : out STD_LOGIC_VECTOR(4 downto 0)
			);
	 end component;
	
-- signals 

signal IM_in : STD_LOGIC_VECTOR(1 downto 0); --ouput of PC input of IM
signal instruction : STD_LOGIC_VECTOR(31 downto 0); --output of IM
signal R1Data : STD_LOGIC_VECTOR(31 downto 0);   --output data of register file
signal R2Data : STD_LOGIC_VECTOR(31 downto 0);	--output data of register file input of mux M1
signal SignEx : STD_LOGIC_VECTOR(31 downto 0);  -- output of signExtend input of ALU


signal ALU_in2 : STD_LOGIC_VECTOR(31 downto 0);  --input2 of ALU
signal read_write_E : STD_LOGIC; ------output of the control unit 

--ALU signals

signal ALU_control_sel : STD_LOGIC_VECTOR(2 downto 0); -----output of ALU coming from ALUcontrol
signal ALU_result : STD_LOGIC_VECTOR(31 downto 0);

-- ControlUnit 

signal memWriteEnable : STD_LOGIC;
signal memReadEnable : STD_LOGIC;
signal memToRegMux : STD_LOGIC;
signal RegDstMux : STD_LOGIC;
signal ALUSrc_out : STD_LOGIC;
signal ALUop_out : STD_LOGIC_VECTOR(1 downto 0);

--MUX to RgisterFile 

signal WriteAdd: STD_LOGIC_VECTOR(4 downto 0);

--DataMemory

signal DataMout: STD_LOGIC_VECTOR(31 downto 0); 

signal result : STD_LOGIC_VECTOR(31 downto 0);

BEGIN
	
		U1: PCounter port map (pc => pc, clk => clk, reset => reset, dout =>IM_in );
		U2: Instruction_Memory port map (pc => IM_in , instruction => instruction );
		
		--MUXs
		
		--MUX RegisterFile & SignExtend to ALU
		
		M1: mux_32 port map (mux_in0 => R2Data ,mux_in1 => SignEX , select_mux => ALUSrc_out , mux_out => ALU_in2 );
		
		--MUX IM to RegisterFile
		
		M2: mux_5 port map (mux_in0 => instruction (20 downto 16) ,mux_in1 => instruction (15 downto 11), select_mux => RegDstMux, mux_out => WriteAdd);

		--DataMermory to RegisterFile
		
		M3: mux_32 port map (mux_in0 => ALU_result, mux_in1 => DataMout, select_mux => memToRegMux, mux_out => result );

		
		
		U3: sign_extend port map (data_in => instruction(15 downto 0) , data_out => SignEX);
		
		
		U4: RegisterFile port map (clk => clk, 
											reset => reset,
											readEnable => read_write_E, 											--read/write enable (read ='1' write ='0'
											readRegister1 => instruction (25 downto 21) ,	--read register 1
											readRegister2 => instruction (20 downto 16),		--read register 2
											writeRegister => WriteAdd,		
											writeData => result,
											readData1 => R1Data ,																																			
											readData2 => R2Data );
											
											
		U5: ALU port map (ALU_control => ALU_control_sel , rs => R1Data , rt => ALU_in2 , rd => ALU_result );
		
		
		U6: ControlUnit port map ( op => instruction(31 downto 26),
											memWrite => memWriteEnable, 
											memtoReg => memToRegMux , 
											MemRead => memReadEnable,
											regWrite => read_write_E , 
											regDst => RegDstMux,
											alusrc => ALUSrc_out,
											ALUOp => ALUop_out );  
		
		
		U7: ALUControl port map ( fct => instruction(5 downto 0), ALUOp => ALUop_out, aluctrl => ALU_control_sel );
		
		
		U8 : Data_Memory_32bits port map (  Address=> ALU_result(9 downto 0) ,
														Write_Data => R2Data ,
														Read_Data => DataMout,
														MemWrite => memWriteEnable ,
														MemRead => memReadEnable, 
														Clock => clk );

end arch;

			



--MUX 32 BITS
library ieee;
use ieee.std_logic_1164.all;


entity mux_32 is 
		port( mux_in0, mux_in1 : in STD_LOGIC_VECTOR(31 downto 0);
				select_mux : in STD_LOGIC;
				mux_out : out STD_LOGIC_VECTOR(31 downto 0));
end mux_32;


architecture arch of mux_32 is 

begin 

   process(select_mux)
	   begin 
		    if(select_mux='0') then 
			     mux_out<=mux_in0;
			  else 
			     mux_out<=mux_in1;
			  end if;
	 end process;
	
end arch;



--MUX 2 BITS

library ieee;
use ieee.std_logic_1164.all;


entity mux_2 is 
		port( mux_in0, mux_in1 : in STD_LOGIC_VECTOR(1 downto 0);
				select_mux : in STD_LOGIC;
				mux_out : out STD_LOGIC_VECTOR(1 downto 0));
end mux_2;


architecture arch of mux_2 is 

begin 

   process(select_mux)
	   begin 
		    if(select_mux='0') then 
			     mux_out<=mux_in0;
			  else 
			     mux_out<=mux_in1;
			  end if;
	 end process;
	
end arch;



--MUX 5 BITS

library ieee;
use ieee.std_logic_1164.all;


entity mux_5 is 
		port( mux_in0, mux_in1 : in STD_LOGIC_VECTOR(4 downto 0);
				select_mux : in STD_LOGIC;
				mux_out : out STD_LOGIC_VECTOR(4 downto 0));
end mux_5;


architecture arch of mux_5 is 

begin 

   process(select_mux)
	   begin 
		    if(select_mux='0') then 
			     mux_out<=mux_in0;
			  else 
			     mux_out<=mux_in1;
			  end if;
	 end process;
	
end arch;