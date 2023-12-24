library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Hazard_Unit is
    Port ( 
			Operation: in std_logic_vector(5 downto 0);
			PCSrc : in std_logic;
			Hit_ET2: in std_logic;
			Jump : in std_logic;
			
			IF_ID_Rs: in STD_LOGIC_VECTOR(4 downto 0);
			IF_ID_Rt: in STD_LOGIC_VECTOR(4 downto 0);
            ID_EX_Rt: in STD_LOGIC_VECTOR(4 downto 0);
			ID_EX_Rd: in STD_LOGIC_VECTOR(4 downto 0);
			MEM_WB_Rd: in STD_LOGIC_VECTOR(4 downto 0);
			
			
			Branch_ID: in STD_LOGIC;
			MemRead_EX: in std_logic;	
			RegWrite_EX : in STD_LOGIC;
			MemtoReg_DM : in STD_LOGIC;
			
			Stall_IF, Stall_ID : out std_logic;
			CTRL_EN: out std_logic;
			Flush_E : out STD_LOGIC
    );
end Hazard_Unit;

architecture arch of Hazard_Unit is
--signals 
signal Lw_Stall : STD_LOGIC;
signal Branch_Stall : STD_LOGIC;
signal Branch_miss_Flush : std_logic;
signal Jump_Flush : std_logic;
begin 
	process(operation,MemtoReg_DM,RegWrite_EX,MemRead_EX,Branch_ID,MEM_WB_Rd,ID_EX_Rd,ID_EX_Rt,IF_ID_Rt,IF_ID_Rs,Jump,Hit_ET2,PCSrc)
	begin
		Stall_IF  <= '0'; 
		Stall_ID  <= '0'; 
		CTRL_EN   <= '0';  
		--if the instruction in Excute stage have MemRead='1', then it's a load instruction
		--Check if the source operands of the new instruction (in ID) are the Rt of load where the data gonna be written
		
		if((MemRead_EX='1') And ((IF_ID_Rs=ID_EX_Rt) or (IF_ID_Rt=ID_EX_Rt))) then
			
			Lw_Stall <= '1';
			CTRL_EN <= '1';  -- Insert '0' control signals (nop) in the excute stage
			
		else 
			Lw_Stall <= '0';
		end if;
		
		if((Branch_ID ='1' and RegWrite_EX ='1' and(ID_EX_Rd = IF_ID_Rs or ID_EX_Rd = IF_ID_Rt )) or (Branch_ID ='1' and MemtoReg_DM ='1' and ((MEM_WB_Rd = IF_ID_Rs) or (MEM_WB_Rd= IF_ID_Rt)))) then 
			Branch_Stall <= '1';
		else 
			Branch_Stall <= '0';
		end if;
		
		-- Branch miss: this block could be implemented individually.
		-- It treats the case where the instruction is a branch but it's not a hit in the BTB
		-- Operation : 1.PC_counter changed to branch_address
		--             2.Flush the instruction (by changing Flush_E to 0)
		-- P.S: we do not stall the Program counter because we need the new value (i.e: Branch_addr)
		--		  we do flush to remove from ID (if not we will have infinite branches)
		
		if(PCSrc ='1' and Hit_ET2 = '0') then 
			Branch_miss_Flush <= '1';
		else 
			Branch_miss_Flush <= '0';
		end if;
		
		--Jump Flush
		if(Jump='1') then 
			Jump_Flush <= '1';
		else 
			Jump_Flush <= '0';
		end if;
		
	end process;

	Stall_IF <=  Lw_Stall or Branch_Stall;
	Stall_ID <=  Lw_Stall or Branch_Stall;
	FLush_E  <=  Lw_Stall or Branch_Stall or Branch_miss_Flush or Jump_Flush;
end arch;

