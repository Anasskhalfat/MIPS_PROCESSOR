library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_File is
    Port ( 
        Clk, Reset: in std_logic;
        RegWrite: in std_logic;
        Read_Addr_1, Read_Addr_2, Write_Addr: in std_logic_vector(4 downto 0);
        Write_Data: in std_logic_vector(31 downto 0);
        Read_Data_1, Read_Data_2: out std_logic_vector(31 downto 0)
    );
end Register_File;

architecture Behavioral of Register_File is
    type RegisterArray is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0); -- 32 32-bit registers
    signal registers : RegisterArray :=(
		x"00000000",--$zero
		x"00000000",--$at
		x"00000000",--$v0
		x"00000000",--$v1
		x"00000000",--$a0
		x"00000000",--$a1
		x"00000000",--$a2
		x"00000000",--$a3
		x"00000001",--$t0
		x"00000001",--$t1
		x"00000000",--$t2
		x"00000000",--$t3
		x"00000000",--$t4
		x"00000000",--$t5
		x"00000000",--$t6
		x"00000000",--$t7
		x"00000000",--$s0
		x"00000000",--$s1
		x"00000000",--$s2
		x"00000000",--$s3
		x"00000000",--$s4
		x"00000000",--$s5
		x"00000000",--$s6
		x"00000000",--$s7
		x"00000000",--$t8
		x"00000000",--$t9
		x"00000000",--$k0
		x"00000000",--$k1
		x"00000000",--$gp
		x"00000000",--$sp
		x"00000000",--$fp
		x"00000000" --$ra
  );
	 
begin
    process (Clk, Reset)
    begin
        if Reset = '1' then
            -- Reset all registers to zero when reset is asserted
            registers <= (others => (others => '0'));
        elsif rising_edge(Clk) then
            Read_Data_1 <= registers(to_integer(unsigned(Read_Addr_1)));
            Read_Data_2 <= registers(to_integer(unsigned(Read_Addr_2)));
            -- Write operation
            if RegWrite = '1' then
                registers(to_integer(unsigned(Write_Addr))) <= Write_Data;
            end if;
        end if;
    end process;
end Behavioral;