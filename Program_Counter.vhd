-- Authors: Elkanouni Samir, Mimouni Yasser, Oubrahim Ayoub, Ait Hsaine Ali, El Hanafi Oussama, Khalfat Anass
-- Date: 2023/2024

library IEEE; use IEEE.STD_LOGIC_1164.ALL; use IEEE.NUMERIC_STD.ALL;

entity Program_Counter is 
	Port(
		PC_In : in STD_LOGIC_VECTOR(31 downto 0);
		Clk : in STD_LOGIC;
		Reset : in STD_LOGIC;
		StallIF: in std_logic;
		PC_Out : out STD_LOGIC_VECTOR(31 downto 0) 
	);
end entity;

architecture arch of Program_Counter is 
BEGIN
	process(Clk,Reset)
		BEGIN 
			if(Reset ='1') then 
				PC_Out <= (others => '0');
			elsif(rising_edge(Clk)) then
				if(StallIF='0') then
					PC_Out <= std_logic_vector(signed(PC_In));
				end if;
			end if;
	end process;
end arch;