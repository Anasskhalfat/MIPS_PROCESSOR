	library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Data_Memory is
	port(
		MemWrite, MemRead, Clk,reset: in std_logic;
		Address: in std_logic_vector(31 downto 0);
		Write_Data: in std_logic_vector(31 downto 0);
		Read_Data: out std_logic_vector(31 downto 0)
	);	
end entity;

architecture arch of Data_Memory is
type Memory is array (0 to 32) of std_logic_vector (31 downto 0);
signal Data_Memory : Memory := (others => (others => '0')); -- Initialize registers to all zeros


begin
	--if(MemRead = '1') then
				--Read_Data <= Data_Memory(to_integer(unsigned(Address))); 
	--		end if;
	process(Clk,reset, Address, MemRead, MemWrite)
	begin
	   if(reset='1') then
		
		   --Data_Memory <= (others => (others => '0'));
			Data_Memory(0) <= x"00000005";
			Data_Memory(1) <= x"00000001";
			Data_Memory(2) <= x"00000002";
			Data_Memory(3) <= x"00000003";
			Data_Memory(4) <= x"00000004";
			Data_Memory(5) <= x"000000FF";
			Data_Memory(6) <= x"00000006";
			Data_Memory(7) <= x"00000007";
			Data_Memory(8) <= x"00000008";
			Data_Memory(9) <= x"00000009";
			Data_Memory(10)<= x"0000000A";
			Data_Memory(11)<= x"0000000B";
			Data_Memory(12)<= x"0000000C";
			Data_Memory(13)<= x"0000000D";
			Data_Memory(14)<= x"0000000E";
			Data_Memory(15)<= x"0000000F";
			Data_Memory(16)<= x"00000010";
			 
		elsif(rising_edge(Clk)) then
		
			if(MemWrite = '1') then
				Data_Memory(to_integer(unsigned(Address))) <= Write_Data;
			end if;
		
		elsif(falling_edge(Clk)) then	
			if(MemRead = '1') then
					Read_Data <= Data_Memory(to_integer(unsigned(Address))); 
			end if;
			
		end if;
	end process;
end arch;