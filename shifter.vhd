library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity shifter is
port(
	data_in: in STD_LOGIC_VECTOR(31 downto 0);
	data_shifted: out STD_LOGIC_VECTOR(31 downto 0)
	);
end shifter;
	
architecture beh of shifter is
begin
	data_shifted <= STD_LOGIC_VECTOR(shift_left(unsigned(data_in), 2));
end beh;