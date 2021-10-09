library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity io is
    port ( I_CLK       : in  std_logic;
           I_CLR       : in  std_logic;
           I_ADR_IO    : in  std_logic_vector( 7 downto 0);
           I_DIN       : in  std_logic_vector( 7 downto 0);
           I_SWITCH    : in  std_logic_vector( 7 downto 0);
           I_RD_IO     : in  std_logic;
           I_RX        : in  std_logic;
           I_WR_IO     : in  std_logic;
    
           Q_7_SEGMENT : out std_logic_vector( 6 downto 0);
           Q_DOUT      : out std_logic_vector( 7 downto 0);
           Q_INTVEC    : out std_logic_vector( 5 downto 0);
           Q_LEDS      : out std_logic_vector( 1 downto 0);
           Q_TX        : out std_logic);
end io;

architecture behavior of io is

component uart
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
end component;

signal U_RX_READY       : std_logic;
signal U_TX_BUSY        : std_logic;
signal U_RX_DATA        : std_logic_vector(7 downto 0);

signal L_INTVEC         : std_logic_vector(5 downto 0);
signal L_LEDS           : std_logic;
signal L_RD_UART        : std_logic;
signal L_RX_INT_ENABLED : std_logic;
signal L_TX_INT_ENABLED : std_logic;
signal L_WE_UART        : std_logic;

begin
    urt: uart
    generic map(CLOCK_FREQ  => std_logic_vector(conv_unsigned(25000000, 32)),
                BAUD_RATE   => std_logic_vector(conv_unsigned(38400, 28)))
                
    port map(   I_CLK       => I_CLK,
                I_CLR       => I_CLR,
                I_RD        => L_RD_UART,
                I_WE        => L_WE_UART,
                I_RX        => I_RX,
                I_TX_DATA   => I_DIN(7 downto 0),
                
                Q_RX_DATA   => U_RX_DATA,
                Q_RX_READY  => U_RX_READY,
                Q_TX        => Q_TX,
                Q_TX_BUSY   => U_TX_BUSY);
                
    
    -- IO read process
    iord: process(I_ADR_IO, I_SWITCH, U_RX_DATA, U_RX_READY, L_RX_INT_ENABLED, U_TX_BUSY, L_TX_INT_ENABLED)
    begin
        case I_ADR_IO is
            when X"2A"  => Q_DOUT   <=                              --UCSRB:        (Note: Look at CPU register UCSRB in AVR datasheet for explaination)
                                        L_RX_INT_ENABLED            --RX complete int enabled
                                        & L_TX_INT_ENABLED          --TX complete int enabled
                                        & L_TX_INT_ENABLED          --TX empty int enabled
                                        & '1'                       --RX enabled
                                        & '1'                       --TX enabled
                                        & '0'                       --8 bits/char
                                        & '0'                       --RX bit 8
                                        & '0';                      --TX bit 8
                                        
            when X"2B"  => Q_DOUT   <=                              --UCSRA:        (Note: Look at CPU register UCSRA in AVR datasheet for explaination)
                                        U_RX_READY                  --Rx complete
                                        & not U_TX_BUSY             --Tx complete
                                        & not U_TX_BUSY             --Tx ready
                                        & '0'                       --Frame error
                                        & '0'                       --Data overrun
                                        & '0'                       --Parity error
                                        & '0'                       --Double Speed
                                        & '0';                      --Multiproc mode
                                        
            when X"2C"  =>  Q_DOUT  <= U_RX_DATA;                   --UDR
            
            when X"40"  =>  Q_DOUT  <=                              --UCSRC:        (Note: Look at CPU register UCSRC in AVR datasheet for explaination)
                                        '1'                         --URSEL
                                        & '0'                       --Asynchronous
                                        & "00"                      --No parity
                                        & '1'                       --Two stop bits
                                        & "11"                      --8 bits/char
                                        & '0';                      --Rising clock edge
            
            when X"36"  =>  Q_DOUT  <= I_SWITCH;                    --PINB
            
            when others =>  Q_DOUT  <= X"AA";                       --For any invalid address, AA is returned
        end case;
    end process;
    
    -- IO write process
    iowr: process(I_CLK)
    begin
        if(rising_edge(I_CLK)) then         --On a rising clock,
            if(I_CLR = '1') then                --Check if there is a clear signal, and if there is
                L_RX_INT_ENABLED <= '0';                --RX_INT_ENABLED is cleared
--              L_TX_INT_ENABLED <= '0';                --TX_INT_ENABLED is cleared - multiple drivers for this
            elsif (I_WR_IO = '1') then          --if there isn't a clear signal and write is enabled,
                case I_ADR_IO is
                    when X"38" =>   Q_7_SEGMENT <= I_DIN(6 downto 0);       --PORTB
                                    L_LEDS <= not L_LEDS;
                    
                    when X"40"  =>  --handled by UART
                    
                    when X"41"  =>  --handled by UART
                    
                    when X"43"  =>  L_RX_INT_ENABLED <= I_DIN(0);
                                    L_TX_INT_ENABLED <= I_DIN(1);
                                    
                    when others =>  --Intentionally blank
                end case;
            end if;
        end if;
    end process;
    
    ioint: process(I_CLK)
    begin
        if(rising_edge(I_CLK)) then                     --On a rising clock,
            if(I_CLR = '1') then                                --Check if there is a clear signal, and if there is
--              L_RX_INT_ENABLED <= '0';                                --RX_INT_ENABLED is cleared
--              L_TX_INT_ENABLED <= '0';                                --TX_INT_ENABLED is cleared
                L_INTVEC <= "000000";                                   --Interrupt vector is invalid (MSB is 0) and clear (all bits are 0)
            else                                                --If there was no clear,
                if(L_RX_INT_ENABLED and U_RX_READY) = '1' then          --If RX is ready and enabled
                    if(L_INTVEC(5) = '0') then                              --If there is no interrupt pending
                        L_INTVEC <= "101011";                                   --Generate Interrupt, vector 11
                    end if;
                elsif(L_TX_INT_ENABLED and not U_TX_BUSY) = '1' then    --else if TX is enabled and not busy (ready)
                    if(L_INTVEC(5) = '0') then                              --If there is no interrupt pending
                        L_INTVEC <= "101011";                                   --Generate Interrupt, vector 12
                    end if;
                else
                    L_INTVEC <= "000000";                               --else clear interrupt vector and make invalid
                end if;
            end if;
        end if;
    end process;
    
    L_WE_UART <= I_WR_IO when (I_ADR_IO = X"2C") else '0';      --Write UART UDR
    L_RD_UART <= I_RD_IO when (I_ADR_IO = X"2C") else '0';      --Read UART UDR
    
    Q_LEDS(1) <= L_LEDS;
    Q_LEDS(0) <= not L_LEDS;
    Q_INTVEC <= L_INTVEC;
    
end behavior;