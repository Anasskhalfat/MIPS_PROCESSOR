library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


Entity Arithmetic_Logic_Unit is 
	Port(
		Clk : in STD_LOGIC;
		ALUControl: in std_logic_vector(2 downto 0);
		OP1: in std_logic_vector(31 downto 0);
		OP2: in std_logic_vector(31 downto 0);
		ALU_Result: buffer std_logic_vector(31 downto 0);
		overflow: out std_logic
	);
end entity;

architecture arch of Arithmetic_Logic_Unit is 
begin
		process(Clk,ALUControl,OP1,OP2)
			begin 
				case(ALUControl) is
			     when "010" => 	ALU_Result<= std_logic_vector(signed(OP1)+signed(OP2));
				  when "110" =>   ALU_Result<= std_logic_vector(signed(OP1)-signed(OP2));
										if(ALU_Result="00000000000000000000000000000000") then
											overflow <= '1';
										else overflow <= '0';
										end if;
				  when "000" =>   ALU_Result<= OP1 AND OP2 ;
				  when others =>  ALU_Result<= "00000000000000000000000000000000" ;
				end case;
	    end process;
end arch;