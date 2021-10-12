library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_rx is
    PORT(   I_CLK       : in  std_logic;
            I_CLR       : in  std_logic;
            I_CE_16     : in  std_logic;            -- 16 times baud rate 
            I_RX        : in  std_logic;            -- Serial input line
 
            Q_DATA      : out std_logic_vector(7 downto 0);
            Q_FLAG      : out std_logic);       -- toggle on every byte received
end uart_rx;
     
architecture Behavioral of uart_rx is
     
    signal L_POSITION       : std_logic_vector(7 downto 0);     --  sample position
    signal L_BUF            : std_logic_vector(9 downto 0); 
    signal L_FLAG           : std_logic; 
    signal L_SERIN          : std_logic;                -- double clock the input
    signal L_SER_HOT        : std_logic;                -- double clock the input
     
begin
     
    -- double clock the input data...
    --
    process(I_CLK)
    begin
        if (rising_edge(I_CLK)) then  
            if (I_CLR = '1') then
                L_SERIN <= '1';
                L_SER_HOT <= '1';
            else
                L_SERIN   <= I_RX;
                L_SER_HOT <= L_SERIN;
           end if;
        end if;
    end process;
     
    process(I_CLK, L_POSITION)
        variable START_BIT : boolean;
        variable STOP_BIT  : boolean;
        variable STOP_POS  : boolean;
     
    begin
    START_BIT := L_POSITION(7 downto 4) = X"0";
    STOP_BIT  := L_POSITION(7 downto 4) = X"9";
    STOP_POS  := STOP_BIT and L_POSITION(3 downto 2) = "11"; -- 3/4 of stop bit
 
    if (rising_edge(I_CLK)) then  
        if (I_CLR = '1') then
            L_FLAG <= '0';
            L_POSITION <= X"00";    -- idle
            L_BUF      <= "1111111111";
            Q_DATA     <= "00000000";
        elsif (I_CE_16 = '1') then    
            if (L_POSITION = X"00") then            -- uart idle
                    L_BUF  <= "1111111111";
                    if (L_SER_HOT = '0')  then          -- start bit received
                        L_POSITION <= X"01";
                     end if;
            else
                    L_POSITION <= L_POSITION + X"01";
                    if (L_POSITION(3 downto 0) = "0111") then       -- 1/2 bit
                       L_BUF <= L_SER_HOT & L_BUF(9 downto 1);     -- sample data
                        --
                        -- validate start bit
                       --
                       if (START_BIT and L_SER_HOT = '1') then     -- 1/2 start bit
                         L_POSITION <= X"00";
                       end if;
 
                        if (STOP_BIT) then                          -- 1/2 stop bit
                            Q_DATA <= L_BUF(9 downto 2);
                        end if;
                    elsif (STOP_POS) then                       -- 3/4 stop bit
                        L_FLAG <= L_FLAG xor (L_BUF(9) and not L_BUF(0));
                        L_POSITION <= X"00";
                    end if;
                end if;
            end if;
        end if;
    end process;    
 
    Q_FLAG <= L_FLAG;
 
end Behavioral;