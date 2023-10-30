library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_File is
    Port ( 
        Clk, Reset,assign: in std_logic;
        RegWrite: in std_logic;
        Read_Addr_1, Read_Addr_2, Write_Addr: in std_logic_vector(4 downto 0);
        Write_Data: in std_logic_vector(31 downto 0);
        Read_Data_1, Read_Data_2: out std_logic_vector(31 downto 0)
    );
end Register_File;

architecture Behavioral of Register_File is
type RegisterArray is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0); -- 32 32-bit registers
signal registers : RegisterArray := (others => (others =>'0'));

begin
	Read_Data_1 <= registers(to_integer(unsigned(Read_Addr_1)));
	Read_Data_2 <= registers(to_integer(unsigned(Read_Addr_2)));
	process (Clk, Reset)
	begin
	if assign='1' then
		   registers(0) <= x"11111111";
			registers(1) <= x"22222222";
			registers(2) <= x"33333333";
			registers(3) <= x"44444444";
			registers(4) <= x"55555555";
			registers(5) <= x"66666666";
			registers(6) <= x"77777777";
			registers(7) <= x"88888888";
			registers(8) <= x"99999999";
			registers(9) <= x"AAAAAAAA";
			registers(10) <= x"BBBBBBBB";
			registers(11) <= x"CCCCCCCC";
			registers(12) <= x"DDDDDDDD";
			registers(13) <= x"EEEEEEEE";
			registers(14) <= x"FFFFFFFF";
			registers(15) <= x"00000000";
			registers(16) <= x"00000000";
			registers(17) <= x"00000000";
			registers(18) <= x"00000000";
			registers(19) <= x"00000000";
			registers(20) <= x"00000000";
			registers(21) <= x"00000000";
			registers(22) <= x"00000000";
			registers(23) <= x"00000000";
			registers(24) <= x"00000000";
			registers(25) <= x"00000000";
			registers(26) <= x"00000000";
			registers(27) <= x"00000000";
			registers(28) <= x"00000000";
			registers(29) <= x"00000000";
			registers(30) <= x"00000000";
			registers(31) <= x"00000000";	
		end if ;
		if Reset = '1' then
		   registers <= (others => (others => '0'));
	
		elsif rising_edge(Clk) then
			if RegWrite = '1' then
				 registers(to_integer(unsigned(Write_Addr))) <= Write_Data;
			end if;
		end if;
		
	end process;
end Behavioral;