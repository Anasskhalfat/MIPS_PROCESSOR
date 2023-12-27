-- Authors: Elkanouni Samir, Mimouni Yasser, Oubrahim Ayoub, Ait Hsaine Ali, El Hanafi Oussama, Khalfat Anass
-- Date: 2023/2024

library IEEE; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity Data_Memory is
	port(
		MemWrite, MemRead, Clk, Reset: in std_logic; -- input signals to manipulate reading or writing in the DataMemory and clock signals
		Address: in std_logic_vector(31 downto 0);	-- an 32bits input signal to indicate the address inside the DataMemory
		Write_Data: in std_logic_vector(31 downto 0);	-- a 32bits input signal giving the Data to write inside the DataMemory
		Read_Data: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000" --a 32bits output signal to give the Data required from the DataMemory
	);	
end entity;

architecture arch of Data_Memory is
type Memory is array (0 to 255) of std_logic_vector (31 downto 0); -- 256 rows of 32 bits
signal Data_Memory : Memory := (others => (others => '0')); 	   -- Initialize all registers to zeros
signal index: natural;

begin
	index <= to_integer(unsigned(Address)); 	--assigning the address to an index natural signal

	process(Clk)
	begin
		if(reset='1') then
			Data_Memory <= (others => (others => '0'));	--resetting the DataMemory to zeros
			
		elsif(rising_edge(Clk)) then		--the condition to write on the rising edge of the clock

			if(MemWrite = '1') then         --the condition on the writing signal
				Data_Memory(index) <= Write_Data;
			end if;
			
		elsif(falling_edge(Clk)) then		--the condition to read on the falling edge  of the clock 
			if(MemRead = '1') then		    --the condition on the reading signal 
				Read_Data <= Data_Memory(index); 
			end if;
			
		end if;
	end process;
end arch;
