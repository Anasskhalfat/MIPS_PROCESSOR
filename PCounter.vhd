library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PCounter is 
	Port(
	pc : in STD_LOGIC_VECTOR(1 downto 0);
	clk : in STD_LOGIC;
	reset : in STD_LOGIC;
	dout : out STD_LOGIC_VECTOR(1 downto 0) 
		);
end PCounter;

architecture arch of PCounter is 
--signals 


BEGIN
	
	process(clk,reset)
	BEGIN 
		
		if(reset ='1') then 
		
			dout <= "00";
			
		elsif(rising_edge(clk)) then
		
			dout <= std_logic_vector(unsigned(pc) +1);
		
		end if;
		
	end process;

end arch;