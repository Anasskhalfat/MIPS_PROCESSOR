library ieee;
use ieee.std_logic_1164.all;

entity Flip_Flop_1_Bit_With_Enable is 
     port(
			 Clk,aReset,Enable : in std_logic;
          Data_In :in std_logic;
          Data_Out: out std_logic
     );
end entity;

architecture arch of Flip_Flop_1_Bit_With_Enable is
begin
  process(Clk)
  begin
	if(aReset = '1') then
		Data_Out <= '0';
	elsif(rising_edge(Clk)) then
		if(Enable = '0') then
			Data_Out <= Data_In;
		end if;
	end if;
  end process;
end arch;