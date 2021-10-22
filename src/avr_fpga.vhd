 -- Module Name:     avr_fpga - Behavioral 
 -- Create Date:     13:51:24 11/07/2009 
 -- Description:     top level of a CPU
 --
 -------------------------------------------------------------------------------
    
 library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.STD_LOGIC_ARITH.ALL;
 use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
 entity avr_fpga is
     port (  I_CLK_100   : in  std_logic;
             I_SWITCH    : in  std_logic_vector(1 downto 0); --expected 10
             I_BUTTONS   : in  std_logic_vector(3 downto 0);
             I_RX        : in  std_logic;
             Q_LEDS      : out std_logic_vector(3 downto 0);
             Q_7_SEGMENT : out std_logic_vector(6 downto 0);
             Q_TX        : out std_logic);
 end avr_fpga;
 
 architecture Behavioral of avr_fpga is
 
  component cpu_core 
     port (  I_CLK       : in  std_logic;
             I_CLR       : in  std_logic;
             I_INTVEC    : in  std_logic_vector( 5 downto 0);
             I_DIN       : in  std_logic_vector( 7 downto 0);
             Q_OPC       : out std_logic_vector(15 downto 0);
             Q_PC        : out std_logic_vector(15 downto 0);
             Q_DOUT      : out std_logic_vector( 7 downto 0);
             Q_ADR_IO    : out std_logic_vector( 7 downto 0);
             Q_RD_IO     : out std_logic;
             Q_WE_IO     : out std_logic);
  end component;
    
  signal  C_PC            : std_logic_vector(15 downto 0);
  signal  C_OPC           : std_logic_vector(15 downto 0);
  signal  C_ADR_IO        : std_logic_vector( 7 downto 0);
  signal  C_DOUT          : std_logic_vector( 7 downto 0);
  signal  C_RD_IO         : std_logic;
  signal  C_WE_IO         : std_logic;
  signal  EXTEND_SWITCH   : std_logic_vector(9 downto 0);
 
  component io
     port (  I_CLK       : in  std_logic;
             I_CLR       : in  std_logic;
             I_ADR_IO    : in  std_logic_vector( 7 downto 0);
             I_DIN       : in  std_logic_vector( 7 downto 0);
             I_RD_IO     : in  std_logic;
             I_WR_IO     : in  std_logic;
             I_SWITCH    : in  std_logic_vector( 7 downto 0);
             I_RX        : in  std_logic;
             I_BUTTONS   : in  std_logic_vector(3 downto 0);
             Q_7_SEGMENT : out std_logic_vector( 6 downto 0);
             Q_DOUT      : out std_logic_vector( 7 downto 0);
             Q_INTVEC    : out std_logic_vector(5 downto 0);
             Q_LEDS      : out std_logic_vector( 1 downto 0);
             Q_TX        : out std_logic);
 
  end component;
 
  signal N_INTVEC         : std_logic_vector( 5 downto 0);
  signal N_DOUT           : std_logic_vector( 7 downto 0);
  signal N_TX             : std_logic;
  signal N_7_SEGMENT      : std_logic_vector( 6 downto 0);
    
  component segment7
     port ( I_CLK        : in  std_logic;
            I_CLR        : in  std_logic;
            I_OPC        : in  std_logic_vector(15 downto 0);
            I_PC         : in  std_logic_vector(15 downto 0);
 
            Q_7_SEGMENT  : out std_logic_vector( 6 downto 0));
  end component;
    
  signal S_7_SEGMENT      : std_logic_vector( 6 downto 0);
    
  signal L_LEDS           : std_logic_vector( 3 downto 0);
  signal L_CLK            : std_logic := '0';
  signal L_CLK_CNT        : std_logic_vector( 2 downto 0) := "000";
  signal L_CLR            : std_logic;            -- reset,  active low
  signal L_CLR_N          : std_logic := '0';     -- reset,  active low
  signal L_C1_N           : std_logic := '0';     -- switch debounce, active low
  signal L_C2_N           : std_logic := '0';     -- switch debounce, active low
  signal L_BUTTONS        : std_logic_vector(3 downto 0);
  signal L_CLR_BN, L_C1_BN, L_C2_BN : std_logic := '0';
    
  attribute mark_debug : string;
  attribute mark_debug of C_PC : signal is "true";
  attribute mark_debug of Q_LEDS : signal is "true";
  attribute mark_debug of Q_7_Segment : signal is "true";
  attribute mark_debug of I_BUTTONS : signal is "true";
  attribute mark_debug of L_BUTTONS : signal is "true";
  
    
  begin
  
    EXTEND_SWITCH  <= "11000000" & I_SWITCH;
    
    cpu : cpu_core
    port map(   I_CLK       => L_CLK,
                I_CLR       => L_CLR,
                I_DIN       => N_DOUT,
                I_INTVEC    => N_INTVEC,

                Q_ADR_IO    => C_ADR_IO,
                Q_DOUT      => C_DOUT,
                Q_OPC       => C_OPC,
                Q_PC        => C_PC,
                Q_RD_IO     => C_RD_IO,
                Q_WE_IO     => C_WE_IO);
    
    ino : io
    port map(   I_CLK       => L_CLK,
                I_CLR       => L_CLR,
                I_ADR_IO    => C_ADR_IO,
                I_DIN       => C_DOUT,
                I_RD_IO     => C_RD_IO,
                I_RX        => I_RX,
                I_SWITCH    => EXTEND_SWITCH(7 downto 0),
                I_WR_IO     => C_WE_IO,
                I_BUTTONS   => L_BUTTONS,
    
                Q_7_SEGMENT => N_7_SEGMENT,
                Q_DOUT      => N_DOUT,
                Q_INTVEC    => N_INTVEC,
                Q_LEDS      => L_LEDS(1 downto 0),
                Q_TX        => N_TX);

    seg : segment7
    port map(   I_CLK       => L_CLK,
                I_CLR       => L_CLR,
                I_OPC       => C_OPC,
                I_PC        => C_PC,
    
                Q_7_SEGMENT => S_7_SEGMENT);
        
        -- input clock scaler
        --
        clk_div : process(I_CLK_100)
        begin
        if (rising_edge(I_CLK_100)) then
            L_CLK_CNT <= L_CLK_CNT + "001";
            if (L_CLK_CNT = "001") then
                L_CLK_CNT <= "000";
                L_CLK <= not L_CLK;
            end if;
        end if;
    end process;
        
    -- reset button debounce process
    --
    deb : process(L_CLK)
    begin
        if (rising_edge(L_CLK)) then
            -- switch debounce
            if ((EXTEND_SWITCH(8) = '0') or (EXTEND_SWITCH(9) = '0')) then    -- pushed
                L_CLR_N <= '0';
                L_C2_N  <= '0';
                L_C1_N  <= '0';
            else                                                    -- released
                L_CLR_N <= L_C2_N;
                L_C2_N  <= L_C1_N;
                L_C1_N  <= '1';
            end if;
        end if;
    end process;
    
    deb1 : process(L_CLK)
    begin
        if (rising_edge(L_CLK)) then
            -- switch debounce
            if (I_BUTTONS(3 downto 0) /= "0000") then    -- pushed
                L_CLR_BN <= '0';
                L_C1_BN  <= '0';
                L_C2_BN  <= '0';
            else                                                    -- released
                L_CLR_BN <= L_C2_BN;
                L_C2_BN  <= L_C1_BN;
                L_C1_BN  <= '1';
            end if;
        end if;
    end process;
    
    L_CLR <= not L_CLR_N;
    
    L_BUTTONS <= "000" & not L_CLR_BN;
    L_LEDS(2) <= I_RX;
    L_LEDS(3) <= N_TX;
    Q_LEDS(1 downto 0) <= I_BUTTONS(1 downto 0);
    Q_LEDS(2) <= C_PC(0);
    Q_LEDS(3) <= I_CLK_100;
    Q_7_SEGMENT  <= N_7_SEGMENT when (EXTEND_SWITCH(0) = '1') else S_7_SEGMENT;
    Q_TX <= N_TX;
    
end Behavioral;
