library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity  ControlUnit is 
	port(
			op : in std_logic_vector(5 downto 0);
			memWrite, memtoReg ,MemRead: out std_logic;
			regWrite, regDst : out std_logic;
			alusrc, branch : out std_logic;
			ALUOp : out std_logic_vector(1 downto 0);
			jump: out std_logic
	);
end ControlUnit;

architecture structural of ControlUnit is 
	signal spec: STD_LOGIC_VECTOR(9 downto 0);
begin 
	process(op) begin
		case op is 
			when "000000" => spec <= "1110000010"; -- R TYPE
			when "100011" => spec <= "1101001000"; -- LW
			when "101011" => spec <= "0001010000"; -- SW
			when "000100" => spec <= "0000100001"; -- BEQ
			when "001000" => spec <= "1101000000"; -- ADDI
			when "000010" => spec <= "0000000100"; -- J
			when others => spec <= "0000000000";  
		end case;
	end process;
 MemRead<=spec(9);
 regWrite <= spec(8);
 regDst <= spec(7);
 alusrc <= spec(6);
 branch <= spec(5);
 memWrite <= spec(4);
 memtoReg <= spec(3);
 jump <= spec(2);
 ALUOp <= spec (1 downto 0);
end structural;