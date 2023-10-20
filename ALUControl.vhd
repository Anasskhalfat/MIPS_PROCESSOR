library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ALU_Control is 
	Port (
	Fct: in std_logic_vector(5 downto 0);
	ALUOp: in std_logic_vector(1 downto 0);
	ALUControl: out std_logic_vector(2 downto 0)
	);
end ALU_Control;

architecture structural of ALU_Control is 
begin 
	process(ALUOp, Fct) begin
		case ALUOp is
			when "00" => ALUControl <= "010"; -- type I
			when "01" => ALUControl <= "110"; -- type J
			when others => case Fct is -- type R
					when "100000" => ALUControl <= "010"; -- add
					when "100010" => ALUControl <= "110"; -- sub
					when "100100" => ALUControl <= "000"; -- and
					when others => ALUControl <= "111"; 
			end case;
		end case;
	end process;
end structural;