library ieee;
use ieee.std_logic_1164.all;

entity Multiplexer_1_Bit_2_Inputs is 
		port( 
			Mux_In_0, Mux_In_1 : in STD_LOGIC;
			Sel : in STD_LOGIC;
			Mux_Out : out STD_LOGIC);
end entity;

architecture arch of Multiplexer_1_Bit_2_Inputs is 
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