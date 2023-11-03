library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Hazard_Unit is
    Port ( 
			Operation: in std_logic_vector(5 downto 0);
			
			IF_ID_Rs: in STD_LOGIC_VECTOR(4 downto 0);
			IF_ID_Rt: in STD_LOGIC_VECTOR(4 downto 0);
         ID_EX_Rt: in STD_LOGIC_VECTOR(4 downto 0);
			MemRead_EX: in std_logic;	
			
			
			StallIF, StallID : out std_logic;
			CTRL_EN: out std_logic
    );
end Hazard_Unit;

architecture arch of Hazard_Unit is 
begin 
	process(operation)
	begin
		StallIF  <= '0'; 
		StallID  <= '0'; 
		CTRL_EN <= '0';  
		--if the instruction in Excute stage have MemRead='1', then it's a load instruction
		--Check if the source operands of the new instruction (in ID) are the Rt of load where the data gonna be written
		
		if((MemRead_EX='1') And ((IF_ID_Rs=ID_EX_Rt) or (IF_ID_Rt=ID_EX_Rt))) then
			StallIF  <= '1';  -- Block the PC counter
			StallID  <= '1';  -- Block then instruction in Decode Stage
			CTRL_EN <= '1';  -- Insert '0' control signals (nop) in the excute stage
			
			
		end if;
	
	end process;
end arch;

