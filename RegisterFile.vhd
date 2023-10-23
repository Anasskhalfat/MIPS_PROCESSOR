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
signal registers : RegisterArray := (others => (others =>'0'));

begin
	Read_Data_1 <= registers(to_integer(unsigned(Read_Addr_1)));
	Read_Data_2 <= registers(to_integer(unsigned(Read_Addr_2)));
	process (Clk, Reset)
	begin
		if Reset = '1' then
			registers <= (others => (others => '0'));
		elsif rising_edge(Clk) then
			if RegWrite = '1' then
				 registers(to_integer(unsigned(Write_Addr))) <= Write_Data;
			end if;
		end if;
	end process;
end Behavioral;