library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ALUControl is 
	port(
			fct : in std_logic_vector(5 downto 0);
			ALUOp : in std_logic_vector(1 downto 0);
			aluctrl : out std_logic_vector(2 downto 0)
		  );
end ALUControl;

architecture structural of ALUControl is 
begin 
	process(ALUOp, fct) begin
		case ALUop is
			when "00" => aluctrl <= "010"; -- type I
			when "01" => aluctrl <= "110"; -- type J
			when others => case fct is -- type R
					when "100000" => aluctrl <= "010"; -- add
					when "100010" => aluctrl <= "110"; -- sub
					when "100100" => aluctrl <= "000"; -- and
					when others => aluctrl <= "111"; 
			end case;
		end case;
	end process;
end structural;