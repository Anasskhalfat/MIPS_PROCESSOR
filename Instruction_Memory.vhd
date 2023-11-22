library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  
entity Instruction_Memory is
	port (
		Read_Addr: in std_logic_vector(31 downto 0);
		Instr : out  std_logic_vector(31 downto 0)
	);
end entity;

architecture arch of Instruction_Memory is
type ROM_type is array (0 to 3) of std_logic_vector(31 downto 0);
constant rom_data: ROM_type:=(
"00010000000000000000000000000010",	   --beq $0,$0, 2       
"00000010101101101010100000100000",	--add $s5,$s5,$s6,
"00000010101101101010100000100000",	--add $s5,$s5,$s6 
"00000000000000000000000000000000"
                  
--"00000010000100011000000000100000",	--add $s0,$s0,$s1                      
--"00000001000010010100000000100000",	--add $t0,$t0,$t1                      
--"00000010101101101010100000100000",	--add $s5,$s5,$s6                      
                   
--"00010000000000001111111111111011",	--beq $0,$0, -5  
--"00000000000000000000000000000000"                   
  );

begin
	Instr <= rom_data(to_integer(unsigned(Read_Addr(1 downto 0))));
end arch;