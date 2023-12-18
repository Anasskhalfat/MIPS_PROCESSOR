library ieee;
use ieee.std_logic_1164.all;

entity Multiplexer_32_Bits_4_Inputs is 
	Port (
		Mux_In_0, Mux_In_1, Mux_In_2, Mux_In_3 : in STD_LOGIC_VECTOR(31 downto 0);
		Sel : in STD_LOGIC_VECTOR(1 downto 0);
		Mux_Out : out STD_LOGIC_VECTOR(31 downto 0)
	);
end entity;

architecture arch of Multiplexer_32_Bits_4_Inputs is 

begin 
 Mux_Out <= Mux_In_0 when Sel = "00" else
            Mux_In_1 when Sel = "01" else
            Mux_In_2 when sel = "10" else
            Mux_In_3 when sel = "11";
end arch;
