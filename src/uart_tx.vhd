-- Module Name:    uart_tx - Behavioral 
-- Create Date:    14:21:59 11/07/2009 
-- Description:    a UART receiver.
--
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_tx is 
    port(   I_CLK       : in  std_logic;    
            I_CLR       : in  std_logic;            -- RESET
            I_CE_1      : in  std_logic;            -- BAUD rate clock enable
            I_DATA      : in  std_logic_vector(7 downto 0);   -- DATA to send
            I_FLAG      : in  std_logic;            -- toggle to send data
            Q_TX_N      : out std_logic;            -- Serial output, active low
            Q_BUSY      : out std_logic);           -- Transmitter busy
end uart_tx;
 
architecture Behavioral of uart_tx is
 
signal L_BUF            : std_logic_vector(8 downto 0);
signal L_FLAG           : std_logic;
signal L_TODO           : std_logic_vector(3 downto 0);     -- bits to send

 attribute mark_debug : string;
 attribute mark_debug of L_TODO : signal is "true";
 
begin
 
    process(I_CLK)
    begin
        if (rising_edge(I_CLK)) then
            if (I_CLR = '1') then               -- reset
                Q_TX_N <= '1';
                L_BUF  <= "111111111";
                L_TODO <= "0000";
                L_FLAG <= I_FLAG;
            elsif (L_TODO = "0000") then        -- idle
                if (L_FLAG /= I_FLAG) then      -- new byte
                    L_BUF <= I_DATA & '0';      -- 8 data / 1 start
                    L_TODO <= "1100";           -- 11 bits to send
                    L_FLAG <= I_FLAG;
                end if;
            else                                -- shifting
                if (I_CE_1 = '1') then 
                    Q_TX_N <= L_BUF(0);
                    L_BUF <= '1' & L_BUF(8 downto 1);
                    L_TODO <= L_TODO - "0001";
                end if;
            end if;
        end if;
    end process; 
 
    Q_BUSY <= '0' when (L_TODO = "0000") else '1';
 
end Behavioral;  
