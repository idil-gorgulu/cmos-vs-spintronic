library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity divider is
	generic (
        DATA_WIDTH : integer := 8
    );
	port (
		clock    	:	in	std_logic;
        start    	: 	in	std_logic;
        a,b         :   in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        result      :   out std_logic_vector(DATA_WIDTH - 1 downto 0);
        done     	: 	out std_logic         
    );
end divider;

architecture Behavioral of divider is

	type layer_state is (mult,idle,data_ready,sign_check);
    signal  state           : layer_state  := idle;
    signal  temp_a          : unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal  temp_b          : unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal  counter         : unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal  done_reg        : std_logic := '0';
    signal  sign            : std_logic := '0';
    
    
begin
    done <= done_reg;
    result <= std_logic_vector(counter);
process (clock)
begin
    if rising_edge(clock) then
        case state is
            when idle =>
                done_reg    <= '0';
                sign        <= a(DATA_WIDTH-1) xor b(DATA_WIDTH-1);
                counter     <= (others => '0');
                if start = '1' then
                    state       <= data_ready;
                end if;
            when data_ready =>
                    if a(DATA_WIDTH-1) = '0' then   temp_a  <= unsigned(a);
                    else                            temp_a  <= unsigned(not(a)) + 1;
                    end if;
                    
                    if b(DATA_WIDTH-1) = '0' then   temp_b  <= unsigned(b);
                    else                            temp_b  <= unsigned(not(b)) + 1;
                    end if;
                    state   <= mult;
                
            when mult =>
                    if temp_a(DATA_WIDTH - 1) = '0' then
                        temp_a <= temp_a + not(temp_b) + 1;
                        counter <= counter + 1;
                    else
                        counter <= counter - 1;
                        state <= sign_check;
                    end if;
                
             when sign_check =>
                done_reg <= '1';
                if sign = '1' then
                    counter <= unsigned(not(counter))+1;
                end if;
                state <= idle;
        end case;
    end if;
end process;

end Behavioral;
