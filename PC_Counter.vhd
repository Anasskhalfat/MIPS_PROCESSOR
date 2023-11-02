library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_Counter is 
	Port(
		PC_In : in STD_LOGIC_VECTOR(31 downto 0);
		Clk : in STD_LOGIC;
		Reset : in STD_LOGIC;
		PC_Out : out STD_LOGIC_VECTOR(31 downto 0) 
	);
end PC_Counter;

architecture arch of PC_Counter is 
BEGIN
	process(Clk,Reset)
		BEGIN 
			if(Reset ='1') then 
				PC_Out <= (others => '0');
			elsif(rising_edge(Clk)) then
				PC_Out <= std_logic_vector(unsigned(PC_In));
			end if;
	end process;
end arch;