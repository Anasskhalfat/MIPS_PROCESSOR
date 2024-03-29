-- Authors: Elkanouni Samir, Mimouni Yasser, Oubrahim Ayoub, Ait Hsaine Ali, El Hanafi Oussama, Khalfat Anass
-- Date: 2023/2024

library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

entity Branch_Prediction_Buffer is
    port(    
        Clk : in std_logic;
        Reset : in std_logic;
        b_instr : in std_logic; -- b_instr is asserted when the instruction is determined as a branch instruction in the ID stage.
        PC_Out : in std_logic_vector(31 downto 0); 
        Branch_Addr : in std_logic_vector(31 downto 0);

	--The Target_Address output provides the predicted target address for the branch instruction.
        Target_Address : out std_logic_vector(31 downto 0);

	--The Hit output indicates whether the prediction was a hit (the corresponding entry was valid).
        Hit : out std_logic
	 );
end entity;



architecture arch of Branch_Prediction_Buffer is

-- Types Declaration
type table is array(0 to 31) of std_logic_vector(31 downto 0);  -- 32 rows of 32 bits
type column is array(0 to 31) of std_logic;                     -- 32 bits  (valid bits), each one for a row in the table array

-- Signlas Declaration:
signal Target_table : table := (others=>(others=>'0'));

--There is a corresponding valid bit for each entry in the table.
signal Vaild_bits : column := (others=>'0');

--The Read_Index is used to read the target address and valid bit from the BTB during the instruction fetch stage.
signal Read_Index : natural;

--The Write_Index is used to write the target address into the BTB during the instruction decode stage when a branch instruction 
--is encountered (b_instr is asserted).
signal Write_index: integer;
	 
begin
	 -- Affecting the PC counter to read and write index
	 -- Note that the write index is not the read address as we write
	 -- when the branch instruction reaches the ID Stage (write_address = read_address - 1)
    Read_Index <= to_integer(unsigned(PC_Out(4 downto 0))); -- 5 bits
	Write_index <= (Read_Index-1) ; -- 5 bits
	 
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
