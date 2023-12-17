library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--the ALU unit is used to perform arithmetic and logical operations on the operands

--it takes as input the ALU control signal from the ALU control unit, the two operands and the clock signal
--it outputs the result of the operation and the zero flag signal in case of equality between the two operands
--the zero flag signal is used to check if the result of the operation is zero or not, it's useful for the branch instructions


Entity Arithmetic_Logic_Unit is 
	Port(
		Clk : in STD_LOGIC;
		ALUControl: in std_logic_vector(2 downto 0);
		OP1: in std_logic_vector(31 downto 0);
		OP2: in std_logic_vector(31 downto 0);
		ALU_Result: buffer std_logic_vector(31 downto 0);
		Bcond: out std_logic --this is the zero flag signal
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
											Bcond <= '1';
										else Bcond <= '0';
										end if;
				  when "000" =>   ALU_Result<= OP1 AND OP2 ;
				  when others =>  ALU_Result<= "00000000000000000000000000000000" ;
				end case;
	    end process;
end arch;