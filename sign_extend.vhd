library ieee;
use ieee.std_logic_1164.all;


entity sign_extend is 
     port( data_in :in std_logic_vector(15 downto 0);
	        data_out: out std_logic_vector(31 downto 0));
end sign_extend;


architecture arch of sign_extend is

begin
  
 data_out<= x"0000"& data_in;

end arch;