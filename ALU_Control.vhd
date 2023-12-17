library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--########### ALU Control ###########
--This entity is used to control the ALU, it takes as input the function code from the instruction memory and the type of instruction from the control unit
--and outputs the control signal to the ALU.
entity ALU_Control is 
	generic (
		--constants
		ITYPE: std_logic_vector(1 downto 0) := "00";
		BEQ: std_logic_vector(1 downto 0) := "01"
		
	);
	Port (
	Fct: in std_logic_vector(5 downto 0);
	-- RTYPE function specifier, specifies which type of operation to be done by the ALU in case of the RTYPE instruction
	ALUOp: in std_logic_vector(1 downto 0);
	--type of instruction, RTYPE, ITYPE jump or branch
	ALUControl: out std_logic_vector(2 downto 0)
	--output going to the ALU, specifies the operation to be done by the ALU.
	);
end entity;

architecture arch of ALU_Control is 

type RTYPE is record --constant record to group the Rtype operations
		ADD: std_logic_vector(5 downto 0);
		SUB: std_logic_vector(5 downto 0);
		AND_OP: std_logic_vector(5 downto 0);
end record;
constant RTYPE_op : RTYPE := (
	ADD => "100000",
	SUB => "100010",
	AND_OP => "100100"
);

begin 
	process(ALUOp, Fct) begin
		case ALUOp is
			when ITYPE => ALUControl <= "010"; -- type I
			when BEQ => ALUControl <= "110"; -- type beq (jump doesn't need ALU)
			when others => case Fct is -- type R
					when RTYPE_op.ADD => ALUControl <= "010"; -- add
					when RTYPE_op.SUB => ALUControl <= "110"; -- sub
					when RTYPE_op.AND_OP => ALUControl <= "000"; -- and
					when others => ALUControl <= "111"; 
			end case;
		end case;
	end process;
end arch;