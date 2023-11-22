library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Branch_Prediction_Buffer is
    port(    
        Clk : in std_logic;
        Reset : in std_logic;
        b_instr : in std_logic;
        PC_Out : in std_logic_vector(31 downto 0);
        Branch_Addr : in std_logic_vector(31 downto 0);
        Target_Address : out std_logic_vector(31 downto 0);
        Hit : out std_logic
	 );
end entity;

architecture arch of Branch_Prediction_Buffer is
-- Types Declaration
type table is array(0 to 31) of std_logic_vector(31 downto 0);
type column is array(0 to 31) of std_logic;

-- Signlas Declaration
signal Target_table : table := (others=>(others=>'0'));
signal Vaild_bits : column := (others=>'0');
signal Read_Index : natural;
signal Write_index: natural;
	 
begin
	 -- Affecting the PC counter to read and write index
	 -- Note that the write index is not the read address as we write
	 -- when the branch instruction reaches the ID Stage (write_address = read_address - 1)
    Read_Index <= to_integer(unsigned(PC_Out(4 downto 0))) mod 4;
	 Write_index <= (Read_Index-1) mod 4;
	 
	 -- Reading the target address if it is a valid field, else raise it to high impedance
    Target_Address <= Target_table(Read_Index) when Vaild_bits(Read_Index) ='1' else (others => 'Z');
	 -- if it is a valid field then it's a hit
    Hit <= '1' when Vaild_bits(Read_Index) = '1' else '0';
	 
    process(Clk,Reset)
    begin
        if Reset = '1' then
            Target_table <= (others=>(others=>'0'));
            Vaild_bits   <= x"00000000";

        elsif rising_edge(Clk) then
				-- Write operation : fill the target address of the corresponding index
            if b_instr='1'   then
                Target_table(Write_index) <= Branch_Addr;
                Vaild_bits(Write_index)   <= '1';
            end if;
        end if;
    end process;
end arch;