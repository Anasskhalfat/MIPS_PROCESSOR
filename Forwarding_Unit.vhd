-- Authors: Elkanouni Samir, Mimouni Yasser, Oubrahim Ayoub, Ait Hsaine Ali, El Hanafi Oussama, Khalfat Anass
-- Date: 2023/2024

--the forwarding unit is a critical component for improving the performance of pipelined processors by minimizing pipeline stalls caused by data hazards
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Forwarding_Unit is
    Port ( 
        ID_EX_Rs: in STD_LOGIC_VECTOR(4 downto 0);	--a 5bits input signal for the RS register(source) signal on the Decode/Execute stage
        ID_EX_Rt: in STD_LOGIC_VECTOR(4 downto 0);	--a 5bits input signal for the RT register signal on the Decode/Execute stage
        EX_MEM_Rd: in STD_LOGIC_VECTOR(4 downto 0);	--a 5bits input signal for the RD register(destination) signal on the Execute/DataMemory stage
        EX_MEM_RegWrite : in STD_LOGIC;			--an input signal for the register's controlling signal on the Execute/DataMemory stage
        MEM_WB_Rd: in STD_LOGIC_VECTOR(4 downto 0);	--a 5bits input signal for the RD register(destination) signal on the DataMemory/WriteBack stage
	MEM_WB_RegWrite : in STD_LOGIC;			--an input signal for the register's controlling signal on the DataMemory/Execute stage
        
	FORWARD_Out_1 : out STD_LOGIC_VECTOR(1 downto 0);	--an output signal to select the first operand value to enter the ALU (the current or the forwarded)
	FORWARD_Out_2 : out STD_LOGIC_VECTOR(1 downto 0)	--an output signal to select the second operand value to enter the ALU (the current or the forwarded)
    );
end entity;

architecture arch of Forwarding_Unit is 
begin 
	process (ID_EX_Rs, ID_EX_Rt, EX_MEM_Rd, EX_MEM_RegWrite, MEM_WB_Rd, MEM_WB_RegWrite)
		begin 
			-- Forwarding the Decode/Execute to Execute/Memory stage
			if(EX_MEM_RegWrite ='1' and (EX_MEM_Rd = ID_EX_Rs) and ID_EX_Rs /= "00000" ) then	--if the register_writing signal in the execute stage is HIGH and the source register(RS) in the Decode stage is equal to the destination register(RD) in the Execute stage
				FORWARD_Out_1 <= "10";		--to Select the EX_MEM_Rd
			else
				FORWARD_Out_1 <= "00";		--to Select the current register's value
			end if;

				
			if(EX_MEM_RegWrite ='1' and (EX_MEM_Rd = ID_EX_Rt) and ID_EX_Rt /= "00000" ) then 	--if the register_writing signal in the execute stage is HIGH and the source register(RT) in the Decode stage is equal to the destination register (RT) in the Execute stage
				FORWARD_Out_2 <= "10";		--to Select the EX_MEM_Rd
			else
				FORWARD_Out_2 <= "00";		--to Select the current register's value
			end if;
			
			----------------------

			-- Forwarding the Execute/Memory to the Memory/WriteBack stage
			if(MEM_WB_RegWrite ='1' and (EX_MEM_Rd /= ID_EX_Rs) and (MEM_WB_Rd = ID_EX_Rs ) and ID_EX_Rs /= "00000") then 		--if the register_writing signal in the execute stage is HIGH and the source register(RS) in the Decode stage is equal to the destination register(RD) in the WriteBack stage
				FORWARD_Out_1 <= "01";		--to Select the MEM_WB_Rd
			end if;
			
			if(MEM_WB_RegWrite ='1' and (EX_MEM_Rd /= ID_EX_Rt) and (MEM_WB_Rd = ID_EX_Rt ) and ID_EX_Rt /= "00000") then 		--if the register_writing signal in the execute stage is HIGH and the source register(RS) in the Decode stage is equal to the destination register(RD) in the WriteBack stage
				FORWARD_Out_2 <= "01";		--to Select the MEM_WB_Rd
			end if;
			
			
			if(MEM_WB_RegWrite ='1' and EX_MEM_RegWrite ='0' and (MEM_WB_Rd = ID_EX_Rs ) and ID_EX_Rs /= "00000") then 		
				FORWARD_Out_1 <= "01";
			end if;
			
			if(MEM_WB_RegWrite ='1' and EX_MEM_RegWrite ='0' and (MEM_WB_Rd = ID_EX_Rt ) and ID_EX_Rt /= "00000") then 
				FORWARD_Out_2 <= "01";
			end if;
			
	end process;

end arch;

