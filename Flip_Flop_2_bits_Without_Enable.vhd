
library ieee;
use ieee.std_logic_1164.all;

entity Flip_Flop_2_bits_Without_Enable is 
     port(
			 Clk,aReset : in std_logic;
          Data_In :in std_logic_vector(1 downto 0);
          Data_Out: out std_logic_vector(1 downto 0)
     );
end entity;

architecture arch of Flip_Flop_2_bits_Without_Enable is
begin
  process(Clk)
  begin
	if(aReset = '1') then
		Data_Out <= "00";
	elsif(rising_edge(Clk)) then
		Data_Out <= Data_In;
	end if;
  end process;
end arch;
