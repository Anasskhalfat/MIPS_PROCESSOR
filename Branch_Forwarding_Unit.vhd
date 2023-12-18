-- Importing the IEEE numeric standard library
use IEEE.NUMERIC_STD.ALL;

-- Defining the entity Branch_Forwarding_Unit
entity Branch_Forwarding_Unit is
    -- Defining the ports for the entity
    Port ( 
        -- Input ports
        IF_ID_Rs: in STD_LOGIC_VECTOR(4 downto 0); -- Register source from IF/ID pipeline register
        IF_ID_Rt: in STD_LOGIC_VECTOR(4 downto 0); -- Register target from IF/ID pipeline register
        EX_MEM_Rd: in STD_LOGIC_VECTOR(4 downto 0); -- Destination register from EX/MEM pipeline register
        EX_MEM_RegWrite : in STD_LOGIC; -- Signal to indicate if a register write operation is to be performed
        
        -- Output ports
        FORWARD_Out_1 : out STD_LOGIC; -- Forwarding signal 1
        FORWARD_Out_2 : out STD_LOGIC -- Forwarding signal 2
    );
end entity;

-- Defining the architecture for the entity
architecture arch of Branch_Forwarding_Unit is 
begin 
    -- Defining the process with sensitivity list
    process (IF_ID_Rs, IF_ID_Rt, EX_MEM_Rd, EX_MEM_RegWrite)
        begin 
            -- If a register write operation is to be performed and the destination register matches the source register
            if(EX_MEM_RegWrite ='1' and (EX_MEM_Rd = IF_ID_Rs) and IF_ID_Rs/= "00000" ) then
                -- Set the forwarding signal 1 to '0'
                FORWARD_Out_1 <= '0';
            else
                -- Otherwise, set the forwarding signal 1 to '1'
                FORWARD_Out_1 <= '1';
            end if;
            
            -- If a register write operation is to be performed and the destination register matches the target register
            if(EX_MEM_RegWrite ='1' and (EX_MEM_Rd = IF_ID_Rt) and IF_ID_Rt /= "00000" ) then --
                -- Set the forwarding signal 2 to '0'
                FORWARD_Out_2 <= '0';
            else
                -- Otherwise, set the forwarding signal 2 to '1'
                FORWARD_Out_2 <= '1';
            end if;
        end process;
end architecture;