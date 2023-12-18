-- Data Memory: writing on the rising edge and reading in the falling edge, the write and read are controled by Memwrite and Memread
library IEEE; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity Data_Memory is
	port(
		MemWrite, MemRead, Clk, Reset: in std_logic;
		Address: in std_logic_vector;
		Write_Data: in std_logic_vector(31 downto 0);
		Read_Data: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000"
	);	
end entity;

architecture arch of Data_Memory is
type Memory is array (0 to 255) of std_logic_vector (31 downto 0); -- 256 rows of 32 bits
signal Data_Memory : Memory := (others => (others => '0')); 	   -- Initialize all registers to zeros
signal index : natural;

begin
	index <= to_integer(unsigned(Address));

	process(Clk)
	begin
		if(reset='1') then
			Data_Memory <= (others => (others => '0'));
			
		elsif(rising_edge(Clk)) then

			if(MemWrite = '1') then
				Data_Memory(index) <= Write_Data;
			end if;
			
		elsif(falling_edge(Clk)) then
			if(MemRead = '1') then
				Read_Data <= Data_Memory(index); 
			end if;
			
		end if;
	end process;
end arch;
