LIBRARY ieee; USE ieee.std_logic_1164.all;                                

ENTITY testbench IS
END testbench;

ARCHITECTURE MIPS_PROCESSOR_arch OF testbench IS
-- signals                                                   
SIGNAL Clk : STD_LOGIC;
SIGNAL Reset : STD_LOGIC;

BEGIN
	i1 : entity work.MIPS_PROCESSOR PORT MAP (
											Clk => Clk,
											Reset => Reset
	);

-- Clk
t_prcs_Clk: PROCESS
BEGIN
	LOOP
		Clk <= '0';
		WAIT FOR 50 ps;
		Clk <= '1';
		WAIT FOR 50 ps;

		IF (NOW >= 1000000 ps) THEN WAIT; END IF;
	END LOOP;
END PROCESS t_prcs_Clk;

-- Reset
t_prcs_Reset: PROCESS
BEGIN
	Reset <= '1';
	WAIT FOR 20 ps;
	Reset <= '0';
WAIT;
END PROCESS t_prcs_Reset;

END MIPS_PROCESSOR_arch;