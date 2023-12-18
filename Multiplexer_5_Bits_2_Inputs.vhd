library ieee;
use ieee.std_logic_1164.all;

entity Multiplexer_5_Bits_2_Inputs is 
		port( 
			Mux_In_0, Mux_In_1 : in STD_LOGIC_VECTOR(4 downto 0);
			Sel : in STD_LOGIC;
			Mux_Out : out STD_LOGIC_VECTOR(4 downto 0));
end entity;

architecture arch of Multiplexer_5_Bits_2_Inputs is 
begin 
 Mux_Out <= Mux_In_0 when Sel = '0' else
            Mux_In_1 when Sel = '1';
end arch;
