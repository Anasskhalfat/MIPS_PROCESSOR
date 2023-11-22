library ieee;
use ieee.std_logic_1164.all;

entity Multiplexer_32_Bits_2_Inputs is 
	Port (
		Mux_In_0, Mux_In_1 : in STD_LOGIC_VECTOR(31 downto 0);
		Sel : in STD_LOGIC;
		Mux_Out : out STD_LOGIC_VECTOR(31 downto 0)
	);
end entity;

architecture arch of Multiplexer_32_Bits_2_Inputs is 

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