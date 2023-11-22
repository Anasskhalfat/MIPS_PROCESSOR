library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Branch_Forwarding_Unit is
    Port ( 
        IF_ID_Rs: in STD_LOGIC_VECTOR(4 downto 0);
        IF_ID_Rt: in STD_LOGIC_VECTOR(4 downto 0);
        EX_MEM_Rd: in STD_LOGIC_VECTOR(4 downto 0);
        EX_MEM_RegWrite : in STD_LOGIC;
        
		  FORWARD_Out_1 : out STD_LOGIC;
		  FORWARD_Out_2 : out STD_LOGIC
		  
    );
end entity;

architecture arch of Branch_Forwarding_Unit is 
begin 
	process (IF_ID_Rs, IF_ID_Rt, EX_MEM_Rd, EX_MEM_RegWrite)
		begin 
			if(EX_MEM_RegWrite ='1' and (EX_MEM_Rd = IF_ID_Rs) and IF_ID_Rs/= "00000" ) then
				FORWARD_Out_1 <= '0';
			else
				FORWARD_Out_1 <= '1';
			end if;
			
			if(EX_MEM_RegWrite ='1' and (EX_MEM_Rd = IF_ID_Rt) and IF_ID_Rt /= "00000" ) then --
				FORWARD_Out_2 <= '0';
			else
				FORWARD_Out_2 <= '1';		
			end if;
			
			----------------------
			
	end process;

end arch;

