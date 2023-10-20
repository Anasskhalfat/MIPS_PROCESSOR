library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFile is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        readEnable : in STD_LOGIC;
		  writeEnable : in STD_LOGIC;
        readRegister1 : in STD_LOGIC_VECTOR(4 downto 0);  -- 5-bit input for selecting a register to read from
        readRegister2 : in STD_LOGIC_VECTOR(4 downto 0);  -- 5-bit input for selecting a register to read from
        writeRegister : in STD_LOGIC_VECTOR(4 downto 0); -- 5-bit input for selecting a register to write to
        writeData : in STD_LOGIC_VECTOR(31 downto 0);
        readData1 : out STD_LOGIC_VECTOR(31 downto 0);   -- Data read from register 1
        readData2 : out STD_LOGIC_VECTOR(31 downto 0)    -- Data read from register 2
    );
end RegisterFile;

architecture Behavioral of RegisterFile is
    type RegisterArray is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0); -- 32 32-bit registers
    signal registers : RegisterArray := (others => (others => '0')); -- Initialize registers to all zeros
begin
    process (clk, reset)
    begin
        if reset = '1' then
            -- Reset all registers to zero when reset is asserted
            registers <= (others => (others => '0'));
        elsif rising_edge(clk) then
            -- Read operation
            if readEnable = '1' then
                readData1 <= registers(to_integer(unsigned(readRegister1)));
                readData2 <= registers(to_integer(unsigned(readRegister2)));
--            else
--                readData1 <= (others => '0');
--                readData2 <= (others => '0');
--            end if;
--            
--            -- Write operation
--            if writeEnable = '1' then
				else
                registers(to_integer(unsigned(writeRegister))) <= writeData;
            end if;
        end if;
    end process;
end Behavioral;