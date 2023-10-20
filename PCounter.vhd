library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PCounter is 
	Port(
	pc_in : in STD_LOGIC_VECTOR(31 downto 0);
	clk : in STD_LOGIC;
	reset : in STD_LOGIC;
	pc_out : out STD_LOGIC_VECTOR(31 downto 0) 
		);
end PCounter;

architecture arch of PCounter is 
--signals 


BEGIN
	
	process(clk,reset)
	BEGIN 
		
		if(reset ='1') then 
		
			pc_out <= (others => '0');
			
		elsif(rising_edge(clk)) then
		
			pc_out <= std_logic_vector(unsigned(pc_in));
		
		end if;
		
	end process;

end arch;