-- Authors: Elkanouni Samir, Mimouni Yasser, Oubrahim Ayoub, Ait Hsaine Ali, El Hanafi Oussama, Khalfat Anass
-- Date: 2023/2024

library IEEE; use IEEE.STD_LOGIC_1164.ALL; use IEEE.NUMERIC_STD.ALL;

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
		-- Initialize signals with '0'
		Stall_IF  <= '0'; 
		Stall_ID  <= '0'; 
		CTRL_EN   <= '0';  

		-- Load Stall: if the instruction in Excute stage have a MemRead='1', then it's a load instruction
		-- Check if the source operands of the new instruction (in ID) are the Rt of load where the data gonna be written
		-- if yes, then we need to stall the pipeline by inserting '0' control signals (nop) in the excute stage and disable flip flops in the IF and ID stage

		if((MemRead_EX='1') And ((IF_ID_Rs=ID_EX_Rt) or (IF_ID_Rt=ID_EX_Rt))) then	
			Lw_Stall <= '1'; -- Disable flip flops in the IF and ID stage
			CTRL_EN <= '1';  -- Insert '0' control signals (nop) in the excute stage
		else 
			Lw_Stall <= '0';
		end if;
		
		-- Branch Stall: if the instruction in instruction decode stage is a branch instruction and one of its operands is a destination register of the instruction in excute stage or write back stage
		-- then we need to stall the pipeline by disabling flip flops in the ID stage for a cycle, until the operand is ready
		if((Branch_ID ='1' and RegWrite_EX ='1' and(ID_EX_Rd = IF_ID_Rs or ID_EX_Rd = IF_ID_Rt )) or (Branch_ID ='1' and MemtoReg_DM ='1' and ((MEM_WB_Rd = IF_ID_Rs) or (MEM_WB_Rd= IF_ID_Rt)))) then 
			Branch_Stall <= '1';
			-- Inserting '0' control signals (nop) in the excute stage isn't important in this case since branch dosn't use other control signals execpt branch
		else 
			Branch_Stall <= '0';
		end if;
		
		-- Branch miss: this block could be implemented individually.
		-- It treats the case where the instruction is a branch but it's not a hit in the BTB, in that case we need to:
		-- 1. Affect Branch address to PC_counter
		-- 2. Flush the instruction following branch (i.e: the instruction in IF stage)
		-- 3. Write the branch address as well as the target address in the BTB and change the valid bit to '1'
		
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
	-- Stall Happens when there is a load instruction in the excute stage or a branch instruction in the ID stage and there is a dependency
	Stall_IF <=  Lw_Stall or Branch_Stall;
	Stall_ID <=  Lw_Stall or Branch_Stall;

	-- Flush Happens when there is a branch miss or a jump instruction
	FLush_E  <=  Branch_Stall or Branch_miss_Flush or Jump_Flush; -- why is this branch_stall here??
end arch;

