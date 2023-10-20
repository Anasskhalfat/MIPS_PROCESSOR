library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity shifter_26 is
port(
	data_in: in STD_LOGIC_VECTOR(25 downto 0);
	data_shifted: out STD_LOGIC_VECTOR(27 downto 0)
	);
end shifter_26;
	
architecture behavioral of shifter_26 is
begin
	data_shifted <= STD_LOGIC_VECTOR(shift_left(unsigned(data_in), 2)) & "00";
end behavioral;