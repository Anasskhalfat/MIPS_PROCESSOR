library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  
entity Instruction_Memory is
	port (
		Read_Addr: in std_logic_vector(31 downto 0);
		Instr : out  std_logic_vector(31 downto 0)
	);
end Instruction_Memory;

architecture Behavioral of Instruction_Memory is
type ROM_type is array (0 to 31) of std_logic_vector(31 downto 0);
constant rom_data: ROM_type:=(
		"00100001000010000000000000000011",--Addi $t0,$t0,3 
		
		"10101100000010000000000000000000",--SW $t0,0($zero)
		
		"00100001000010000000000000000011",--Addi $t0,$t0,3 
		
		"10001100000100000000000000000000",--LW $s0,0($zero)
		
		"00100010000100000000000000000000",--Addi $s0,$s0,0
		
		"00100001001010010000000000000100",--Addi $t1,$t1,4
		"00000001000010011000000000100000",--Add  $s0,$t0,$t1
		
		"00000010000010001000000000100100",--And  $s0,$s0,t0
		"00010001000100000000000000000010",--beq  $t0,$s0,+2 -3(1111111111111100)
		"00000010000010011000000000100010",--sub  $s0,$t1,4	
		"00001000000000000000000000000010",--j    2
		
		"00100010000100000000000000000000",--Addi $s0,$s0,0
		"00000010000010011000000000100010",--sub  $s0,$t1,4	
		"00000010000010011000000000100010",--sub  $s0,$t1,4	
		"00000010000010011000000000100010",--sub  $s0,$t1,4		
		"00000010000010011000000000100000",--Add  $s0,$t1,4	
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
	
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
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
	Instr <= rom_data(to_integer(unsigned(Read_Addr)));
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