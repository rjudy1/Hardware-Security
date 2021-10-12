library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity baudgen is
    generic(clock_freq  : std_logic_vector(31 downto 0);
            baud_rate   : std_logic_vector(27 downto 0));
        port(   I_CLK       : in  std_logic;
                I_CLR       : in  std_logic;
                Q_CE_1      : out std_logic;    -- baud x  1 clock enable
                Q_CE_16     : out std_logic);   -- baud x 16 clock enable
end baudgen;
    
     
architecture Behavioral of baudgen is
    constant BAUD_16        : std_logic_vector(31 downto 0) := baud_rate & "0000";
    constant LIMIT          : std_logic_vector(31 downto 0) := clock_freq - BAUD_16; 
    signal L_CE_16          : std_logic;
    signal L_CNT_16         : std_logic_vector( 3 downto 0);
    signal L_COUNTER        : std_logic_vector(31 downto 0);
     
    begin
        -- counter for timing of baud x 16
        baud16: process(I_CLK)
        begin
            if (rising_edge(I_CLK)) then
                if (I_CLR = '1') then
                    L_COUNTER <= X"00000000";
                elsif (L_COUNTER >= LIMIT) then
                    L_COUNTER <= L_COUNTER - LIMIT;
                else
                    L_COUNTER <= L_COUNTER + BAUD_16;
                end if;
            end if;
        end process;
     
        -- increments L_CNT_16 which is used for baud gen x 1
        baud1: process(I_CLK)
        begin
            if (rising_edge(I_CLK)) then
                if (I_CLR = '1') then
                    L_CNT_16 <= "0000";
                elsif (L_CE_16 = '1') then
                    L_CNT_16 <= L_CNT_16 + "0001";
                end if;
            end if;
        end process;
    
        L_CE_16 <= '1' when (L_COUNTER >= LIMIT) else '0';
        Q_CE_16 <= L_CE_16; -- puts out one when the counter = the limit
        Q_CE_1 <= L_CE_16 when L_CNT_16 = "1111" else '0'; -- puts out high when L_CNT_16 meets top
    
end behavioral;
