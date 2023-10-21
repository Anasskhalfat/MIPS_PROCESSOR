library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Data_Memory_32bits is
	port(
		MemWrite, MemRead, Clk: in std_logic;
		Address: in std_logic_vector(9 downto 0);
		Write_Data: in std_logic_vector(31 downto 0);
		Read_Data: out std_logic_vector(31 downto 0)
	);	
end Data_Memory_32bits;

architecture arch of Data_Memory_32bits is
type Memory is array (0 to 1023) of std_logic_vector (31 downto 0);
signal Data_Memory : Memory := (others => (others => '0')); -- Initialize registers to all zeros
signal index : natural;


begin
	index <= to_integer(unsigned(Address));

	process(Clk, Address, MemRead, MemWrite)
	begin
		if(rising_edge(Clk)) then
		
			if(MemWrite = '1') then
				Data_Memory(index) <= Write_Data;
			end if;
			
			if(MemRead = '1') then
				Read_Data <= Data_Memory(index); 
			end if;
			
		end if;
	end process;
end arch;