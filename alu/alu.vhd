library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_4bit is
    Port ( 
        A, B     : in  STD_LOGIC_VECTOR(3 downto 0);  -- 4-bit inputs
        OP_CODE  : in  STD_LOGIC_VECTOR(2 downto 0);  -- 3-bit operation code
        RESULT   : out STD_LOGIC_VECTOR(3 downto 0);  -- 4-bit result
        CARRY    : out STD_LOGIC;                     -- Carry flag
        ZERO     : out STD_LOGIC                      -- Zero flag
    );
end ALU_4bit;

architecture Behavioral of ALU_4bit is
    -- Internal signals for operations
    signal temp_result : STD_LOGIC_VECTOR(4 downto 0);
    
    -- Intermediate signals for addition
    signal c0, c1, c2, c3 : STD_LOGIC;
    signal sum0, sum1, sum2, sum3 : STD_LOGIC;
    
    -- Intermediate signals for two's complement of B (for subtraction)
    signal not_b0, not_b1, not_b2, not_b3 : STD_LOGIC;
    signal sub_c0, sub_c1, sub_c2, sub_c3 : STD_LOGIC;
    signal sub_sum0, sub_sum1, sub_sum2, sub_sum3 : STD_LOGIC;
    
    -- Intermediate signals for increment
    signal inc_c0, inc_c1, inc_c2, inc_c3 : STD_LOGIC;
    signal inc_sum0, inc_sum1, inc_sum2, inc_sum3 : STD_LOGIC;
    
    -- Intermediate signals for decrement
    signal dec_c0, dec_c1, dec_c2, dec_c3 : STD_LOGIC;
    signal dec_sum0, dec_sum1, dec_sum2, dec_sum3 : STD_LOGIC;
    
begin
    -- Bitwise NOT of B (for subtraction)
    not_b0 <= not B(0);
    not_b1 <= not B(1);
    not_b2 <= not B(2);
    not_b3 <= not B(3);
    
    -- Addition logic (A + B) - synthesizable without loops
    -- First bit
    sum0 <= A(0) xor B(0) xor '0';
    c0 <= (A(0) and B(0)) or (A(0) and '0') or (B(0) and '0');
    
    -- Second bit
    sum1 <= A(1) xor B(1) xor c0;
    c1 <= (A(1) and B(1)) or (A(1) and c0) or (B(1) and c0);
    
    -- Third bit
    sum2 <= A(2) xor B(2) xor c1;
    c2 <= (A(2) and B(2)) or (A(2) and c1) or (B(2) and c1);
    
    -- Fourth bit
    sum3 <= A(3) xor B(3) xor c2;
    c3 <= (A(3) and B(3)) or (A(3) and c2) or (B(3) and c2);
    
    -- Subtraction logic (A - B = A + not(B) + 1) - synthesizable without loops
    -- First bit
    sub_sum0 <= A(0) xor not_b0 xor '1';
    sub_c0 <= (A(0) and not_b0) or (A(0) and '1') or (not_b0 and '1');
    
    -- Second bit
    sub_sum1 <= A(1) xor not_b1 xor sub_c0;
    sub_c1 <= (A(1) and not_b1) or (A(1) and sub_c0) or (not_b1 and sub_c0);
    
    -- Third bit
    sub_sum2 <= A(2) xor not_b2 xor sub_c1;
    sub_c2 <= (A(2) and not_b2) or (A(2) and sub_c1) or (not_b2 and sub_c1);
    
    -- Fourth bit
    sub_sum3 <= A(3) xor not_b3 xor sub_c2;
    sub_c3 <= (A(3) and not_b3) or (A(3) and sub_c2) or (not_b3 and sub_c2);
    
    -- Increment logic (A + 1) - synthesizable without loops
    -- First bit
    inc_sum0 <= A(0) xor '1' xor '0';
    inc_c0 <= (A(0) and '1') or (A(0) and '0') or ('1' and '0');
    
    -- Second bit
    inc_sum1 <= A(1) xor '0' xor inc_c0;
    inc_c1 <= (A(1) and '0') or (A(1) and inc_c0) or ('0' and inc_c0);
    
    -- Third bit
    inc_sum2 <= A(2) xor '0' xor inc_c1;
    inc_c2 <= (A(2) and '0') or (A(2) and inc_c1) or ('0' and inc_c1);
    
    -- Fourth bit
    inc_sum3 <= A(3) xor '0' xor inc_c2;
    inc_c3 <= (A(3) and '0') or (A(3) and inc_c2) or ('0' and inc_c2);
    
    -- Decrement logic (A - 1) - synthesizable without loops
    -- First bit
    dec_sum0 <= A(0) xor '0' xor '1';
    dec_c0 <= (A(0) and '0') or (A(0) and '1') or ('0' and '1');
    
    -- Second bit
    dec_sum1 <= A(1) xor '1' xor dec_c0;
    dec_c1 <= (A(1) and '1') or (A(1) and dec_c0) or ('1' and dec_c0);
    
    -- Third bit
    dec_sum2 <= A(2) xor '1' xor dec_c1;
    dec_c2 <= (A(2) and '1') or (A(2) and dec_c1) or ('1' and dec_c1);
    
    -- Fourth bit
    dec_sum3 <= A(3) xor '1' xor dec_c2;
    dec_c3 <= (A(3) and '1') or (A(3) and dec_c2) or ('1' and dec_c2);
    
    -- Main process for ALU operations
    process(A, B, OP_CODE, 
            sum0, sum1, sum2, sum3, c3,
            sub_sum0, sub_sum1, sub_sum2, sub_sum3, sub_c3,
            inc_sum0, inc_sum1, inc_sum2, inc_sum3, inc_c3,
            dec_sum0, dec_sum1, dec_sum2, dec_sum3, dec_c3)
    begin
        -- Default values
        temp_result <= "00000";
        
        case OP_CODE is
            -- Arithmetic Operations using logical operations
            when "000" =>  -- Addition
                temp_result <= c3 & sum3 & sum2 & sum1 & sum0;
                
            when "001" =>  -- Subtraction
                temp_result <= sub_c3 & sub_sum3 & sub_sum2 & sub_sum1 & sub_sum0;
                
            when "010" =>  -- Increment A
                temp_result <= inc_c3 & inc_sum3 & inc_sum2 & inc_sum1 & inc_sum0;
                
            when "011" =>  -- Decrement A
                temp_result <= dec_c3 & dec_sum3 & dec_sum2 & dec_sum1 & dec_sum0;
                
            -- Logical Operations
            when "100" =>  -- Bitwise AND
                temp_result <= '0' & (A(3) and B(3)) & (A(2) and B(2)) & (A(1) and B(1)) & (A(0) and B(0));
                
            when "101" =>  -- Bitwise OR
                temp_result <= '0' & (A(3) or B(3)) & (A(2) or B(2)) & (A(1) or B(1)) & (A(0) or B(0));
                
            when "110" =>  -- Bitwise XOR
                temp_result <= '0' & (A(3) xor B(3)) & (A(2) xor B(2)) & (A(1) xor B(1)) & (A(0) xor B(0));
                
            when "111" =>  -- Bitwise NOT (A)
                temp_result <= '0' & not A(3) & not A(2) & not A(1) & not A(0);
                
            when others =>  -- Undefined operation
                temp_result <= "00000";
        end case;
    end process;
    
    -- Output assignments
    RESULT <= temp_result(3 downto 0);
    CARRY <= temp_result(4);
    ZERO <= '1' when temp_result(3 downto 0) = "0000" else '0';
    
end Behavioral;