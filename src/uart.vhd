 --
 library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.STD_LOGIC_ARITH.ALL;
 use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart is
	generic(CLOCK_FREQ	: std_logic_vector(31 downto 0);
			BAUD_RATE	: std_logic_vector(27 downto 0));
			
	port(	I_CLK		: in std_logic;
			I_CLR		: in std_logic;
			I_RD		: in std_logic;
			I_WE		: in std_logic;
			I_RX		: in std_logic;
			I_TX_DATA	: in std_logic_vector(7 downto 0);
			
			Q_RX_DATA	: out std_logic_vector(7 downto 0);
			Q_RX_READY	: out std_logic;
			Q_TX		: out std_logic;
			Q_TX_BUSY	: out std_logic);
end uart;

architecture Behavioral of uart_rx is
	 
 entity uart_rx is
    PORT(   I_CLK       : in  std_logic;
            I_CLR       : in  std_logic;
            I_CE_16     : in  std_logic;            -- 16 times baud rate 
            I_RX        : in  std_logic;            -- Serial input line
 
            Q_DATA      : out std_logic_vector(7 downto 0);
            Q_FLAG      : out std_logic);       -- toggle on every byte received
end uart_rx;
 entity uart_tx is 
     port(   I_CLK       : in  std_logic;    
             I_CLR       : in  std_logic;            -- RESET
             I_CE_1      : in  std_logic;            -- BAUD rate clock enable
             I_DATA      : in  std_logic_vector(7 downto 0);   -- DATA to be sent
             I_FLAG      : in  std_logic;            -- toggle to send data
             Q_TX        : out std_logic;            -- Serial output line
             Q_FLAG      : out std_logic);           -- Transmitting Flag
 end uart_tx;
 	 
	 
begin
	 

end Behavioral;