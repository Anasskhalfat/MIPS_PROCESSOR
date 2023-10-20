library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  
entity Instruction_Memory is
	port (
		pc: in std_logic_vector(1 downto 0);
		instruction: out  std_logic_vector(31 downto 0)
	);

	end Instruction_Memory;
architecture Behavioral of Instruction_Memory is

	signal rom_addr: std_logic_vector(3 downto 0);
	type ROM_type is array (0 to 15 ) of std_logic_vector(31 downto 0);
	constant rom_data: ROM_type:=(
		"00000000000000001000000110000000",
		"00000000000000000010110010001011",
		"00000000000000001100010000000011",
		"00000000000000000001000111000000",
		"00000000000000001110110110000001",
		"00000000000000001100000001111011",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000"
  );
begin

 --rom_addr <= pc(4 downto 1);
  instruction <= rom_data(to_integer(unsigned(pc)));-- when pc < x"00000004" else x"00000000";

end Behavioral;


















--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--
--entity Instruction_Memory is
--
--	PORT (address: in STD_LOGIC_VECTOR(31 DOWNTO 0);
--	
--			data: out STD_LOGIC_VECTOR(31 DOWNTO 0));
--			
--end Instruction_Memory;
--
--architecture Behavioral of Instruction_Memory is
--
--TYPE rom IS ARRAY (0 TO 256) OF STD_LOGIC_VECTOR(31 DOWNTO 0);  -- 1kbytes of memory
--
--	CONSTANT imem: rom:=(
--   "1000000110000000",
--   "0010110010001011",
--   "1100010000000011",
--   "0001000111000000",
--   "1110110110000001",
--   "1100000001111011",
--   "0000000000000000",
--   "0000000000000000",
--   "0000000000000000",
--   "0000000000000000",
--   "0000000000000000",
--   "0000000000000000",
--   "0000000000000000",
--   "0000000000000000",
--   "0000000000000000",
--   "0000000000000000"
--  );
--
--	
--	begin
--	
--	data<=imem(TO_INTEGER(address));
--	
--end Behavioral;