library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Forwarding_Unit is
    Port ( 
        ID_EX_Rs: in STD_LOGIC_VECTOR(4 downto 0);
        ID_EX_Rt: in STD_LOGIC_VECTOR(4 downto 0);
        EX_MEM_Rd: in STD_LOGIC_VECTOR(4 downto 0);
        EX_MEM_RegWrite : in STD_LOGIC;
        MEM_WB_Rd: in STD_LOGIC_VECTOR(4 downto 0);
		  MEM_WB_RegWrite : in STD_LOGIC;
        
		  FORWARD_Out_1 : out STD_LOGIC_VECTOR(1 downto 0);
		  FORWARD_Out_2 : out STD_LOGIC_VECTOR(1 downto 0)
    );
end entity;

architecture arch of Forwarding_Unit is 
begin 
	process (ID_EX_Rs, ID_EX_Rt, EX_MEM_Rd, EX_MEM_RegWrite, MEM_WB_Rd, MEM_WB_RegWrite)
		begin 
			if(EX_MEM_RegWrite ='1' and (EX_MEM_Rd = ID_EX_Rs) and ID_EX_Rs /= "00000" ) then
				FORWARD_Out_1 <= "10";
			else
				FORWARD_Out_1 <= "00";
			end if;
			
			if(EX_MEM_RegWrite ='1' and (EX_MEM_Rd = ID_EX_Rt) and ID_EX_Rt /= "00000" ) then --
				FORWARD_Out_2 <= "10";
			else
				FORWARD_Out_2 <= "00";		
			end if;
			
			----------------------
			
			if(MEM_WB_RegWrite ='1' and(EX_MEM_Rd /= ID_EX_Rs) and (MEM_WB_Rd = ID_EX_Rs ) and ID_EX_Rs /= "00000") then 
				FORWARD_Out_1 <= "01";
			end if;
			
			if(MEM_WB_RegWrite ='1' and(EX_MEM_Rd /= ID_EX_Rt) and (MEM_WB_Rd = ID_EX_Rt ) and ID_EX_Rt /= "00000") then 
				FORWARD_Out_2 <= "01";
			end if;
			
			
			if(MEM_WB_RegWrite ='1' and EX_MEM_RegWrite ='0' and (MEM_WB_Rd = ID_EX_Rs ) and ID_EX_Rs /= "00000") then 
				FORWARD_Out_1 <= "01";
			end if;
			
			if(MEM_WB_RegWrite ='1' and EX_MEM_RegWrite ='0' and (MEM_WB_Rd = ID_EX_Rt ) and ID_EX_Rt /= "00000") then 
				FORWARD_Out_2 <= "01";
			end if;
			
	end process;

end arch;

