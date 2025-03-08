library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_4bit_tb is
end ALU_4bit_tb;

architecture Behavioral of ALU_4bit_tb is
    -- Component Declaration
    component ALU_4bit
        Port ( 
            A, B     : in  STD_LOGIC_VECTOR(3 downto 0);
            OP_CODE  : in  STD_LOGIC_VECTOR(2 downto 0);
            RESULT   : out STD_LOGIC_VECTOR(3 downto 0);
            CARRY    : out STD_LOGIC;
            ZERO     : out STD_LOGIC
        );
    end component;
    
    -- Test Signals
    signal A_tb, B_tb       : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal OP_CODE_tb       : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal RESULT_tb        : STD_LOGIC_VECTOR(3 downto 0);
    signal CARRY_tb         : STD_LOGIC;
    signal ZERO_tb          : STD_LOGIC;
    
    -- Clock signal
    signal CLK : STD_LOGIC := '0';
    constant CLK_PERIOD : time := 10 ns;  -- 100MHz clock
    
    -- Test procedure
    procedure check_result(
        A_val    : in STD_LOGIC_VECTOR(3 downto 0);
        B_val    : in STD_LOGIC_VECTOR(3 downto 0);
        OP_val   : in STD_LOGIC_VECTOR(2 downto 0);
        signal A : out STD_LOGIC_VECTOR(3 downto 0);
        signal B : out STD_LOGIC_VECTOR(3 downto 0);
        signal OP_CODE : out STD_LOGIC_VECTOR(2 downto 0)) is
    begin
        A <= A_val;
        B <= B_val;
        OP_CODE <= OP_val;
        wait for CLK_PERIOD;
    end procedure;

begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: ALU_4bit port map (
        A => A_tb,
        B => B_tb,
        OP_CODE => OP_CODE_tb,
        RESULT => RESULT_tb,
        CARRY => CARRY_tb,
        ZERO => ZERO_tb
    );
    
    -- Clock generation process
    CLK_process: process
    begin
        wait for CLK_PERIOD/2;
        CLK <= not CLK;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Wait for 100ns for global reset
        wait for 100 ns;
        
        -- Test case 1: Addition (OpCode "000")
        -- Test 1.1: Simple addition without carry
        report "Test 1.1: Addition 5 + 3";
        check_result("0101", "0011", "000", A_tb, B_tb, OP_CODE_tb);
        
        -- Test 1.2: Addition with carry
        report "Test 1.2: Addition with carry 15 + 1";
        check_result("1111", "0001", "000", A_tb, B_tb, OP_CODE_tb);
        
        -- Test case 2: Subtraction (OpCode "001")
        -- Test 2.1: Simple subtraction without borrow
        report "Test 2.1: Subtraction 7 - 3";
        check_result("0111", "0011", "001", A_tb, B_tb, OP_CODE_tb);
        
        -- Test 2.2: Subtraction with borrow
        report "Test 2.2: Subtraction 3 - 7";
        check_result("0011", "0111", "001", A_tb, B_tb, OP_CODE_tb);
        
        -- Test case 3: Increment (OpCode "010")
        -- Test 3.1: Normal increment
        report "Test 3.1: Increment 7";
        check_result("0111", "0000", "010", A_tb, B_tb, OP_CODE_tb);
        
        -- Test 3.2: Increment with overflow
        report "Test 3.2: Increment 15";
        check_result("1111", "0000", "010", A_tb, B_tb, OP_CODE_tb);
        
        -- Test case 4: Decrement (OpCode "011")
        -- Test 4.1: Normal decrement
        report "Test 4.1: Decrement 8";
        check_result("1000", "0000", "011", A_tb, B_tb, OP_CODE_tb);
        
        -- Test 4.2: Decrement zero
        report "Test 4.2: Decrement 0";
        check_result("0000", "0000", "011", A_tb, B_tb, OP_CODE_tb);
        
        -- Test case 5: AND Operation (OpCode "100")
        report "Test 5: AND 1010 and 1100";
        check_result("1010", "1100", "100", A_tb, B_tb, OP_CODE_tb);
        
        -- Test case 6: OR Operation (OpCode "101")
        report "Test 6: OR 1010 or 1100";
        check_result("1010", "1100", "101", A_tb, B_tb, OP_CODE_tb);
        
        -- Test case 7: XOR Operation (OpCode "110")
        report "Test 7: XOR 1010 xor 1100";
        check_result("1010", "1100", "110", A_tb, B_tb, OP_CODE_tb);
        
        -- Test case 8: NOT Operation (OpCode "111")
        report "Test 8: NOT 1010";
        check_result("1010", "0000", "111", A_tb, B_tb, OP_CODE_tb);
        
        -- Test case 9: Zero flag test
        report "Test 9: Zero flag test - AND 0000 and 0000";
        check_result("0000", "0000", "100", A_tb, B_tb, OP_CODE_tb);
        
        -- End simulation
        report "All tests completed";
        wait for CLK_PERIOD*2;
        wait;
    end process;
    
    -- Monitor process to display results
    monitor_proc: process
    begin
        wait for CLK_PERIOD/2;  -- Wait for half clock cycle to sample after changes
        
        if (now > 100 ns) then  -- Skip initial wait period
            report "Time: " & time'image(now) &
                  " A: " & integer'image(to_integer(unsigned(A_tb))) &
                  " B: " & integer'image(to_integer(unsigned(B_tb))) &
                  " OpCode: " & integer'image(to_integer(unsigned(OP_CODE_tb))) &
                  " Result: " & integer'image(to_integer(unsigned(RESULT_tb))) &
                  " Carry: " & std_logic'image(CARRY_tb) &
                  " Zero: " & std_logic'image(ZERO_tb);
        end if;
    end process;

end Behavioral;