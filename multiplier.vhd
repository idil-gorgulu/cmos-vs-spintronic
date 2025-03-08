library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier is
	generic (
        DATA_WIDTH : integer := 8
    );
	port (
		clock    	:	in	std_logic;
        start    	: 	in	std_logic;
        a,b         :   in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        result      :   out std_logic_vector(DATA_WIDTH + DATA_WIDTH - 1 downto 0);
        done     	: 	out std_logic         
    );
end multiplier;

architecture Behavioral of multiplier is

	type layer_state is (mult,idle,data_ready,sign_check);
    signal  state           : layer_state  := idle;
    signal  temp_a          : std_logic_vector(DATA_WIDTH + DATA_WIDTH - 1 downto 0) := (others => '0');
    signal  temp_b          : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal  counter         : integer range 0 to DATA_WIDTH := 0;
    signal  shift_a, sum    : unsigned(DATA_WIDTH + DATA_WIDTH - 1 downto 0) := (others => '0');
    signal  done_reg        : std_logic := '0';
    signal  sum_time,sign   : std_logic := '0';
    
    
begin
    done <= done_reg;
    result <= std_logic_vector(sum);
process (clock)
begin
    if rising_edge(clock) then
        case state is
            when idle =>
                done_reg    <= '0';
                sign        <= a(DATA_WIDTH-1) xor b(DATA_WIDTH-1);
                
                sum     <= (others => '0');
                shift_a <= (others => '0');
                if start = '1' then
                    state       <= data_ready;
                end if;
            when data_ready =>
                
                    if a(DATA_WIDTH-1) = '0' then   temp_a  <= "00000000" & a;
                    else                            temp_a  <= std_logic_vector(unsigned(not("11111111" & a)) + 1);
                    end if;
                    
                    if b(DATA_WIDTH-1) = '0' then   temp_b  <= b;
                    else                            temp_b  <= std_logic_vector(unsigned(not(b)) + 1);
                    end if;
                    state   <= mult;
                
            when mult =>
                if counter < DATA_WIDTH then
                    counter <= counter + 1;        
                    if temp_b(counter) = '1' then
                        shift_a <= shift_left(unsigned(temp_a),counter);
                        sum_time <= '1';
                    else
                        sum_time <= '0';
                    end if;
                    
                    if sum_time = '1' then
                        sum <= sum + shift_a;
                        sum_time <= '0';
                    end if;           
                else
                    counter <= 0;
                    state <= sign_check;
                    
                end if;
                
             when sign_check =>
                done_reg <= '1';
                if sign = '1' then
                    sum <= unsigned(not(sum))+1;
                end if;
                state <= idle;
        end case;
    end if;
end process;

end Behavioral;
