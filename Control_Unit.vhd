library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity  Control_Unit is 
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
	process(Operation) begin
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