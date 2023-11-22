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
    process(Sel)
	   begin 
			case(Sel) is
				when "00" => Mux_Out <= Mux_In_0;
				when "01" => Mux_Out <= Mux_In_1;
				when "10" => Mux_Out <= Mux_In_2;
				when others => Mux_Out <= Mux_In_3;
		    end case;
	end process;
end arch;