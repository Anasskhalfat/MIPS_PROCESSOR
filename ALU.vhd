library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


Entity ALU is 

   Port( ALU_control: in std_logic_vector(2 downto 0);
			rs: in std_logic_vector(31 downto 0);
			rt: in std_logic_vector(31 downto 0);
			rd: buffer std_logic_vector(31 downto 0);
			bcond: out std_logic);
end ALU;

architecture behavioral of ALU is 

begin

		process(ALU_control,rs,rt)

			begin 
			
				case(ALU_control) is
				
			     when "010" => 	rd<= std_logic_vector(signed(rs)+signed(rt));
				  
				  when "110" =>   rd<= std_logic_vector(signed(rs)-signed(rt));
										if(rd="00000000000000000000000000000000") then
											bcond <= '1';
										else bcond <= '0';
										end if;
								
				  when "000" =>   rd<= rs AND rt ;
				  
				  when others => rd<= "00000000000000000000000000000000" ;

	    
				end case;
				
	    end process;
end behavioral;