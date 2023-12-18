-- Branch condition comparator
--if the 32 bits operands are equal, the output is 1, otherwise 0

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Comparator_32_Bits is 
		Port(
			OP1 : in STD_LOGIC_VECTOR(31 DOWNTO 0);
			OP2 : in STD_LOGIC_VECTOR(31 DOWNTO 0);
			RES : out STD_LOGIC
		);
end entity;

architecture arch of Comparator_32_Bits is 
begin
	process(OP1,OP2)
	begin
		if (OP1 = OP2) then 
		
			RES <='1';
		
		else RES <='0';
		end if;
	end process;
end arch;