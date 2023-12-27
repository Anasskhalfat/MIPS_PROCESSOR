-- Authors: Elkanouni Samir, Mimouni Yasser, Oubrahim Ayoub, Ait Hsaine Ali, El Hanafi Oussama, Khalfat Anass
-- Date: 2023/2024

library IEEE; use IEEE.STD_LOGIC_1164.ALL;

entity  Control_Unit is 
	--generic (
	--	RTYPE: std_logic_vector(5 downto 0) := "000000";
	--	LW: std_logic_vector(5 downto 0) := "100011";
	--	SW: std_logic_vector(5 downto 0) := "101011";
	--	BEQ: std_logic_vector(5 downto 0) := "000100";
	--	ADDI: std_logic_vector(5 downto 0) := "001000";
	--	J: std_logic_vector(5 downto 0) := "000010"
	--);
	Port (
		Operation: in std_logic_vector(5 downto 0);
		funct  : in std_logic_vector(5 downto 0);
		MemWrite, MemtoReg, MemRead: out std_logic;
		RegWrite, RegDst, ALUSrc, Branch, Jump: out std_logic;
		ALUOp: out std_logic_vector(1 downto 0)
	);
end Control_Unit;

architecture structural of Control_Unit is 
	signal spec: STD_LOGIC_VECTOR(9 downto 0);
begin 
	process(Operation,funct) begin
		case Operation is 
			when "000000" => if funct = "000000" then
										spec <= "0000000000"; --this is a SLL instruction(not implemented)/ in case of restarting the processor we get a prob because of control signals in case of x"00000000"
									else
										spec <= "0110000010"; -- R TYPE
									end if;
			when "100011" => spec <= "1101001000"; -- LW
			when "101011" => spec <= "0001010000"; -- SW
			when "000100" => spec <= "0000100001"; -- BEQ
			
			when "001000" => spec <= "0101000000"; -- ADDI
			when "000010" => spec <= "0000000100"; -- J
			when others   => spec <= "0000000000";  
		end case;
	end process;
	
	-- SPEC is the control signals, it is 10 bits long:
	
	-- 10th bit: memory read control signal 
	-- 9th bit: Register Write control signal used to specify when an instruction should write to the RF (i.e. the LW instruction)
	-- 8th bit: Register destination wether to use bits 20-16 of the instruction (LOW, Rt) or 11-15 (HIGH, Rd) for write back operations in the RF.
	-- 7th bit: ALU source, specifies the operand for the ALU (from RF or an immediate)
	-- 6th bit: Branch operation instruction specifier
	-- 5th bit: memory write control signal, spicifies when an instruction should write to memory (i.e. the SW instruction)
	-- 4th bit: memory to register control signal, specifies when a value should be loaded from memory and stored in a register (i.e. the LW instruction)
	-- 3rd bit: Jump instruction specifier, high when the current instruction is a jump instruction (i.e. the J instruction) 
	-- 2nd and 1st bits: ALU operation specifier, specifies the type of operation to be performed by the ALU ( ITYPE, RTYPE, JTYPE)
 MemRead<=spec(9);
 RegWrite <= spec(8);
 RegDst <= spec(7);
 ALUSrc <= spec(6);
 Branch <= spec(5);
 MemWrite <= spec(4);
 MemtoReg <= spec(3);
 Jump <= spec(2);
 ALUOp <= spec (1 downto 0);
end structural;