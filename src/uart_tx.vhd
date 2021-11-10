 ------------------------------------------------------------------------------
 --
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
             I_DATA      : in  std_logic_vector(7 downto 0);   -- DATA to be sent
             I_FLAG      : in  std_logic;            -- toggle to send data
             Q_TX        : out std_logic;            -- Serial output line
             Q_FLAG      : out std_logic);           -- Transmitting Flag
 end uart_tx;
     
 architecture Behavioral of uart_tx is
  
    signal L_BUF            : std_logic_vector(7 downto 0);
    signal L_TODO           : std_logic_vector(3 downto 0);     -- bits to send
    signal L_FLAG           : std_logic := '0';
  
  attribute mark_debug : string;
  attribute mark_debug of Q_TX : signal is "true";
  attribute mark_debug of L_TODO : signal is "true";
  attribute mark_debug of L_FLAG : signal is "true";
  attribute mark_debug of I_FLAG : signal is "true";
  attribute mark_debug of L_BUF : signal is "true";
    
 begin
     
    process(I_CLK)
        begin
            if (rising_edge(I_CLK)) then
                if (I_CLR = '1') then
                    Q_TX   <= '1';
                    L_BUF  <= "11111111";
                    L_TODO <= "0000";
                    L_FLAG <= I_FLAG;                   -- idle
                elsif (I_CE_1 = '1') then
                   if (L_TODO = "1001") then
                        Q_TX <= '0';
                   elsif (L_TODO /= "0000") then          -- transmitting
                        Q_TX <= L_BUF(0);               -- next bit
                        L_BUF     <= '1' & L_BUF(7 downto 1);
                        if (L_TODO = "0001") then
                            L_FLAG <= I_FLAG;
                        end if;
                   end if;
                   L_TODO <= L_TODO - "0001";
                 end if;
                 
                 -- possibly an issue with this being outside i_ce_1?
                 if (L_FLAG /= I_FLAG) then           -- new byte
--                        Q_TX <= '0';                -- start bit
                      L_BUF <= I_DATA;                -- data bits
                      L_TODO <= "1001";
                 end if;
            end if;
        end process; 
  
     Q_FLAG <= L_FLAG;
     
 end Behavioral;  