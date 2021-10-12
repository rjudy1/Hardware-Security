library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart is
    generic(CLOCK_FREQ  : std_logic_vector(31 downto 0);
            BAUD_RATE   : std_logic_vector(27 downto 0));
            
    port(   I_CLK       : in std_logic;
            I_CLR       : in std_logic;
            I_RD        : in std_logic;
            I_WE        : in std_logic;
            I_RX        : in std_logic;
            I_TX_DATA   : in std_logic_vector(7 downto 0);
            
            Q_RX_DATA   : out std_logic_vector(7 downto 0);
            Q_RX_READY  : out std_logic;
            Q_TX        : out std_logic;
            Q_TX_BUSY   : out std_logic);
end uart;

architecture Behavioral of uart is
signal L_CE_1   : std_logic;
signal L_CE_16  : std_logic;

component baudgen
generic(    clock_freq  : std_logic_vector(31 downto 0);
            baud_rate   : std_logic_vector(27 downto 0));
    port(   I_CLK       : in  std_logic;
            I_CLR       : in  std_logic;
            Q_CE_1      : out std_logic;    -- baud x  1 clock enable
            Q_CE_16     : out std_logic);   -- baud x 16 clock enable
end component;
     
component uart_rx
    port(   I_CLK       : in  std_logic;
            I_CLR       : in  std_logic;
            I_CE_16     : in  std_logic;            -- 16 times baud rate 
            I_RX        : in  std_logic;            -- Serial input line
 
            Q_DATA      : out std_logic_vector(7 downto 0);
            Q_FLAG      : out std_logic);       -- toggle on every byte received
end component;

component uart_tx
    port(   I_CLK       : in  std_logic;    
            I_CLR       : in  std_logic;            -- RESET
            I_CE_1      : in  std_logic;            -- BAUD rate clock enable
            I_DATA      : in  std_logic_vector(7 downto 0);   -- DATA to be sent
            I_FLAG      : in  std_logic;            -- toggle to send data
            Q_TX        : out std_logic;            -- Serial output line
            Q_FLAG      : out std_logic);           -- Transmitting Flag
end component;

begin
    bg : baudgen
    generic map (
            clock_freq  => "25000000",               --Clock frequency, can be adjusted
            baud_rate   => "38400"                  --baud rate for UART (can be changed)
    )
    port map (
            I_CLK       => I_CLK,
            I_CLR       => I_CLR,
            Q_CE_1      => L_CE_1,
            Q_CE_16     => L_CE_16
    );
            
    tx : uart_tx
    port map (
            I_CLK       => I_CLK,    
            I_CLR       => I_CLR,           -- RESET
            I_CE_1      => L_CE_1,          -- BAUD rate clock enable
            I_DATA      => I_TX_DATA,       -- DATA to be sent
            I_FLAG      => I_WE,            -- toggle to send data
            Q_TX        => Q_TX,            -- Serial output line
            Q_FLAG      => Q_TX_BUSY        -- Transmitting Flag
    );

    rx : uart_rx
    PORT map (   
            I_CLK       => I_CLK,
            I_CLR       => I_CLR,
            I_CE_16     => L_CE_16,        -- 16 times baud rate 
            I_RX        => I_RX,           -- Serial input line
 
            Q_DATA      => Q_RX_DATA,
            Q_FLAG      => Q_RX_READY       -- toggle on every byte received
    );

end Behavioral;