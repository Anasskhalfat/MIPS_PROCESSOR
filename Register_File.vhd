-- Authors: Elkanouni Samir, Mimouni Yasser, Oubrahim Ayoub, Ait Hsaine Ali, El Hanafi Oussama, Khalfat Anass
-- Date: 2023/2024

library IEEE; use IEEE.STD_LOGIC_1164.ALL; use IEEE.NUMERIC_STD.ALL;

entity Register_File is
    Port ( 
        Clk, Reset: in std_logic;
        RegWrite: in std_logic;
        Read_Addr_1, Read_Addr_2, Write_Addr: in std_logic_vector(4 downto 0);
        Write_Data: in std_logic_vector(31 downto 0);
        Read_Data_1, Read_Data_2: out std_logic_vector(31 downto 0)
    );
end entity;

architecture arch of Register_File is
type RegisterArray is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0); -- 32 32-bit registers
signal registers : RegisterArray := (others => (others =>'0'));

begin
	
	process (Clk, Reset)
	begin

		if Reset = '1' then
			-- Reset all registers to default values when reset is asserted
			registers(0) <= x"00000000"; 	registers(1) <= x"00000001";	registers(2) <= x"00000002";	registers(3) <= x"00000003";
			registers(4) <= x"00000004";	registers(5) <= x"00000005";	registers(6) <= x"00000006";	registers(7) <= x"00000007";
			registers(8) <= x"00000008";	registers(9) <= x"00000009";	registers(10)<= x"0000000A";	registers(11)<= x"0000000B";
			registers(12)<= x"0000000C";	registers(13)<= x"0000000D";	registers(14)<= x"0000000E";	registers(15)<= x"0000000F";
			registers(16)<= x"00000010";	registers(17)<= x"00000011";	registers(18)<= x"00000012";	registers(19)<= x"00000013";
			registers(20)<= x"00000014";	registers(21)<= x"00000015";	registers(22)<= x"00000016";	registers(23)<= x"00000017";
			registers(24)<= x"00000018";	registers(25)<= x"00000019";	registers(26)<= x"0000001A";	registers(27)<= x"0000001B";
			registers(28)<= x"0000001C";	registers(29)<= x"0000001D";	registers(30)<= x"0000001E";	registers(31)<= x"0000001F";

		elsif rising_edge(Clk) then
			if RegWrite = '1' then
				 registers(to_integer(unsigned(Write_Addr))) <= Write_Data;
			end if;
		
		end if;
	end process;

	process(Clk,Reset,RegWrite)
	begin
		if(RegWrite='1') then
			if (Write_Addr=Read_Addr_1) then
				Read_Data_1 <= Write_Data;
				Read_Data_2 <= registers(to_integer(unsigned(Read_Addr_2)));
			elsif(Write_Addr=Read_Addr_2) then
				Read_Data_1 <= registers(to_integer(unsigned(Read_Addr_1)));
				Read_Data_2 <= Write_Data;
			else
				Read_Data_1 <= registers(to_integer(unsigned(Read_Addr_1)));
				Read_Data_2 <= registers(to_integer(unsigned(Read_Addr_2)));
			end if;
		else
			Read_Data_1 <= registers(to_integer(unsigned(Read_Addr_1)));
			Read_Data_2 <= registers(to_integer(unsigned(Read_Addr_2)));
		end if;
	end process;
end arch;




--		elsif RegWrite = '1' then
			-- Write operation
			
--			if (clk='1') then
--				 registers(to_integer(unsigned(Write_Addr))) <= Write_Data;
--			end if;
			
--		elsif falling_edge(Clk) then
--			Read_Data_1 <= registers(to_integer(unsigned(Read_Addr_1)));
--			Read_Data_2 <= registers(to_integer(unsigned(Read_Addr_2)));
--		end if;
--	end process;
--end arch;
