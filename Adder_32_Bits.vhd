-- Authors: Elkanouni Samir, Mimouni Yasser, Oubrahim Ayoub, Ait Hsaine Ali, El Hanafi Oussama, Khalfat Anass
-- Date: 2023/2024
-- Description: This is a 32 bit adder that takes two 32 bit inputs and outputs a 32 bit sum

library IEEE; use IEEE.STD_LOGIC_1164.ALL; USE IEEE.numeric_std.all;  

entity Adder_32_Bits is 
port(
	A: in STD_LOGIC_VECTOR(31 downto 0);
	B: in STD_LOGIC_VECTOR(31 downto 0);
	Sum: out STD_LOGIC_VECTOR(31 downto 0)
	);
end entity;

architecture arch of Adder_32_Bits is
begin 
	Sum <= std_logic_vector(signed(A)+signed(B));
end arch;
