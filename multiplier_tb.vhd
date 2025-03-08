library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier_tb is
-- No ports for testbench
end multiplier_tb;

architecture Behavioral of multiplier_tb is
    -- Component declaration for the Unit Under Test (UUT)
    component multiplier
        generic (
            DATA_WIDTH : integer := 8
        );
        port (
            clock     : in  std_logic;
            start     : in  std_logic;

            a, b      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            result    : out std_logic_vector(DATA_WIDTH + DATA_WIDTH - 1 downto 0);
            done      : out std_logic
        );
    end component;

    -- Constants
    constant DATA_WIDTH : integer := 8;
    constant CLK_PERIOD : time := 20 ns;
    
    -- Signals for UUT
    signal clk          : std_logic := '0';
    signal start_signal : std_logic := '0';
    signal a_input      : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal b_input      : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal done_signal  : std_logic;
    signal result       : std_logic_vector(DATA_WIDTH + DATA_WIDTH - 1 downto 0):= (others => '0');
    -- Simulation control
    signal sim_done     : boolean := false;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: multiplier
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clock     => clk,
            start     => start_signal,
            a         => a_input,
            b         => b_input,
            result    => result,
            done      => done_signal
        );

    -- Clock process
    clock_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize inputs
        start_signal <= '0';
        a_input <= (others => '0');
        b_input <= (others => '0');
        
        -- Wait for global reset
        wait for 100 ns;
        
        -- Test Case 1: 3*4
        a_input <= "00000011";  -- 3 in decimal
        b_input <= "00000100";  -- 4 in decimal
        
        -- Apply start signal
        wait for CLK_PERIOD;
        start_signal <= '1';
        wait for CLK_PERIOD;
        start_signal <= '0';
        
        -- Wait for done signal with timeout (in case done is not implemented)
        for i in 0 to 20 loop
            wait for CLK_PERIOD;
            if done_signal = '1' then
                exit;
            end if;
        end loop;
        wait for CLK_PERIOD * 2;
        
        -- Test Case 2: 85*4
        a_input <= "01010101";  -- 85 in decimal
        b_input <= "00000100";  -- 4 in decimal
        
        -- Apply start signal
        wait for CLK_PERIOD;
        start_signal <= '1';
        wait for CLK_PERIOD;
        start_signal <= '0';
        
        -- Wait for done signal with timeout
        for i in 0 to 20 loop
            wait for CLK_PERIOD;
            if done_signal = '1' then
                exit;
            end if;
        end loop;
        wait for CLK_PERIOD * 2;
        
        -- Test Case 3: -4*5 (using 2's complement for negative numbers)
        a_input <= "11111100";  -- -4 in 2's complement
        b_input <= "00000101";  -- 5 in decimal
        
        -- Apply start signal
        wait for CLK_PERIOD;
        start_signal <= '1';
        wait for CLK_PERIOD;
        start_signal <= '0';
        
        -- Wait for done signal with timeout
        for i in 0 to 20 loop
            wait for CLK_PERIOD;
            if done_signal = '1' then
                exit;
            end if;
        end loop;
        wait for CLK_PERIOD * 2;
        
        -- Test Case 4: -4*-5 (using 2's complement for negative numbers)
        a_input <= "11111100";  -- -4 in 2's complement
        b_input <= "11111011";  -- -5 in 2's complement
        
        -- Apply start signal
        wait for CLK_PERIOD;
        start_signal <= '1';
        wait for CLK_PERIOD;
        start_signal <= '0';
        
        -- Wait for done signal with timeout
        for i in 0 to 20 loop
            wait for CLK_PERIOD;
            if done_signal = '1' then
                exit;
            end if;
        end loop;
        
        -- End simulation
        wait for 100 ns;
        sim_done <= true;
        wait;
    end process;

end Behavioral;