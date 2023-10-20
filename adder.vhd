library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

entity adder is 
port(
	A: in STD_LOGIC_VECTOR(31 downto 0);
	B: in STD_LOGIC_VECTOR(31 downto 0);
	sum: out STD_LOGIC_VECTOR(31 downto 0)
	);
end adder;

architecture behavior of adder is
begin 
	sum <= std_logic_vector(unsigned(A)+unsigned(B));
end behavior;