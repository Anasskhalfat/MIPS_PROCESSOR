library ieee;
use ieee.std_logic_1164.all;

entity Sign_Extend_Unit is 
     port(
          Data_In :in std_logic_vector(15 downto 0);
          Data_Out: out std_logic_vector(31 downto 0)
     );
end entity;

architecture arch of Sign_Extend_Unit  is
begin
 process(Data_In)
begin
  if Data_In(15)='0' then 
     Data_Out<= x"0000"& Data_In;
  else 
      Data_Out<= x"FFFF"& Data_In;
	end if ;
end process;
end arch;
