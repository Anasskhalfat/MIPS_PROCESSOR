-- Authors: Elkanouni Samir, Mimouni Yasser, Oubrahim Ayoub, Ait Hsaine Ali, El Hanafi Oussama, Khalfat Anass
-- Date: 2023/2024

-- An array of instruction 32*32, the output is the instruction at the read address index.

library IEEE; use IEEE.STD_LOGIC_1164.ALL; USE IEEE.numeric_std.all;  
entity Instruction_Memory is
	port (
		Read_Addr: in std_logic_vector(31 downto 0);
		Instr : out  std_logic_vector(31 downto 0)
	);
end entity;

architecture arch of Instruction_Memory is

type ROM_type is array (0 to 31) of std_logic_vector(31 downto 0);

constant rom_data: ROM_type:=(
--R type without dependencies:
		--"00000001101101010100000000100000",  --add $t0,$t5,$s5
		--"00000001101101010100000000100010",  --sub $t0,$t5,$s5
		--"00000001101101010100000000100100",  --and $t0,$t5,$s5

--R type with RF dependency:
		--"00000001101101010100000000100000",    -- add $t0,$t5,$s5
		--"00000001101101010100100000100010",    -- sub $t1,$t5,$s5
		--"00000001101101010101000000100000",    -- add $t2,$t5,$s5
		--"00000001000101010101100000100100",    -- and $t3,$t0,$s5
		--"00000001000101010100000000100000",    -- add $t0,$t0,$s5

--R type with RAW dependencies: forwarding from MEM and WB to EXE stage

		--"00000001101101010100000000100000",    -- add $t0,$t5,$s5
		--"00000001000101010100100000100010",    -- sub $t1,$t0,$s5
		--"00000001101010000101000000100000",    -- add $t2,$t5,$t0
		--"00000001000101010101100000100100",    -- and $t3,$t0,$s5

--I,J type instructions without dependencies
		
		"10001100101010000000000000000000",     -- LW $t0, 0($R5)
		"00000000000000000000000000000000",     -- NOP
		"00100001000010000000000000000001",     -- addi $t0,$t0,1
		"10101100101010000000000000000000",     -- SW $t0, 0($R5)
		"00100000101001011111111111111111",     -- addi $R5,$R5,-1
		"00010000000001010000000000000010",     -- beq $zero, $R5, +2
		"00001000000000000000000000000000",     -- jump 0


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
end arch;

--
--		"00100001000010000000000000000011",--Addi $t0,$t0,3  // t0=8+3=11
--		
--		"10101101000010000000000000000000",--SW $t0,0($t0)
--				
--		"10001101000100000000000000000000",--LW $s0,0($t0)  // s0=11
--
--		"00000010000010011000000000100000",--Add $s0,$s0,$t1  // s0=11+9=20
--
--		"00000011101010111000100000100010",--sub $s1,$r29,$t3  //s1= 29 - 11 = 18	//s1 = 29 - 9 = 20		
--
--		"00010010001100000000000000000010",--beq  $s1,$s0,+2 //18!=20 => no branch  //20==20 => branch taken, program counter goes to nop instructions.
--
--		"00000001011010010101100000100100",--And  $t3,$t3,t1 // t3 = 11 and 9 = 9
--
--		"00001000000000000000000000000100",--j    4