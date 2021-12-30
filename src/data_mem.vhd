--data_mem.vhd
--Leslie Wallace
--23 Sept, 2021: Add comments
--18 Sept, 2021: Create code based on tutorial
-- 29 Dec 2021 : Interchange RAMB4s for Block Mem Generator memory blocks

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.common.ALL;

entity data_mem is
    port(I_CLK   : in std_logic;
         
         I_ADR   : in std_logic_vector(10 downto 0);
         I_DIN   : in std_logic_vector(15 downto 0);
         I_WE    : in std_logic_vector(1 downto 0);
         
         Q_DOUT  : out std_logic_vector(15 downto 0));
end data_mem;
         
architecture Behavioral of data_mem is 
     
    constant zero_265 : bit_vector := X"00000000000000000000000000000000"
                                    & X"00000000000000000000000000000000";
    constant nine_256 : bit_vector := X"99999999999999999999999999999999"
                                    & X"99999999999999999999999999999999"; 
    component RAMB4_S4_S4
         generic(INIT_00 : bit_vector := zero_265;
                 INIT_01 : bit_vector := zero_265;
                 INIT_02 : bit_vector := zero_265;
                 INIT_03 : bit_vector := zero_265;
                 INIT_04 : bit_vector := zero_265;
                 INIT_05 : bit_vector := zero_265;
                 INIT_06 : bit_vector := zero_265;
                 INIT_07 : bit_vector := zero_265;
                 INIT_08 : bit_vector := zero_265;
                 INIT_09 : bit_vector := zero_265;
                 INIT_0A : bit_vector := zero_265;
                 INIT_0B : bit_vector := zero_265;
                 INIT_0C : bit_vector := zero_265;
                 INIT_0D : bit_vector := zero_265;
                 INIT_0E : bit_vector := zero_265;
                 INIT_0F : bit_vector := zero_265
          );
          port(DOA    : out std_logic_vector (3 downto 0);
               DOB    : out std_logic_vector (3 downto 0);
               ADDRA  : in std_logic_vector (9 downto 0);
               ADDRB  : in std_logic_vector (9 downto 0);
               CLKA   : in std_ulogic;
               CLKB   : in std_ulogic;
               DIA    : in std_logic_vector (3 downto 0);
               DIB    : in std_logic_vector (3 downto 0);
               ENA    : in std_ulogic;
               ENB    : in std_ulogic;
               RSTA   : in std_ulogic;
               RSTB   : in std_ulogic;
               WEA    : in std_ulogic;
               WEB    : in std_ulogic
               );
          end component;
    COMPONENT blk_mem_gen_0
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
      );
    END COMPONENT;
                   
    signal L_ADR_0 : std_logic; 
    signal L_ADR_E : std_logic_vector(10 downto 1);
    signal L_ADR_O : std_logic_vector(10 downto 1);
    signal L_DIN_E : std_logic_vector(7 downto 0);
    signal L_DIN_O : std_logic_vector(7 downto 0);
    signal L_DOUT_E : std_logic_vector(7 downto 0);
    signal L_DOUT_O : std_logic_vector(7 downto 0);
    signal L_WE_E : std_logic_vector(0 downto 0);
    signal L_WE_O : std_logic_vector(0 downto 0);
          
begin
    sr_0 : blk_mem_gen_0
    PORT MAP (
        clka => I_CLK,
        ena => '1',
        wea => L_WE_E,
        addra => L_ADR_E,
        dina => L_DIN_E(3 downto 0),
        douta => L_DOUT_E(3 downto 0),
        clkb => I_CLK,
        enb => '0',
        web => "0",
        addrb => "0000000000",
        dinb => "0000",
        doutb => open
    );
    
--          sr_0 : RAMB4_S4_S4 --------------------------------------------------------------------------------
--          generic map(INIT_00 => nine_256, INIT_01 => nine_256, INIT_02 => nine_256,
--                      INIT_03 => nine_256, INIT_04 => nine_256, INIT_05 => nine_256,
--                      INIT_06 => nine_256, INIT_07 => nine_256, INIT_08 => nine_256,
--                      INIT_09 => nine_256, INIT_0A => nine_256, INIT_0B => nine_256,
--                      INIT_0C => nine_256, INIT_0D => nine_256, INIT_0E => nine_256,
--                      INIT_0F => nine_256)
               
--          port map(ADDRA => L_ADR_E,            ADDRB => "0000000000",
--                   CLKA => I_CLK,               CLKB => I_CLK,
--                   DIA => L_DIN_E(3 downto 0),  DIB => "0000",
--                   ENA => '1',                  ENB => '0',
--                   RSTA => '0',                 RSTB => '0',
--                   WEA => L_WE_E(0),               WEB => '0',
--                   DOA => L_DOUT_E(3 downto 0), DOB => open);
           
    sr_1 : blk_mem_gen_0
    PORT MAP (
        clka => I_CLK,
        ena => '1',
        wea => L_WE_E,
        addra => L_ADR_E,
        dina => L_DIN_E(7 downto 4),
        douta => L_DOUT_E(7 downto 4),
        clkb => I_CLK,
        enb => '0',
        web => "0",
        addrb => "0000000000",
        dinb => "0000",
        doutb => open
    );
    
--          sr_1 : RAMB4_S4_S4 ---------------------------------------------------------------------------------
--          generic map(INIT_00 => nine_256, INIT_01 => nine_256, INIT_02 => nine_256,
--                      INIT_03 => nine_256, INIT_04 => nine_256, INIT_05 => nine_256,
--                      INIT_06 => nine_256, INIT_07 => nine_256, INIT_08 => nine_256,
--                      INIT_09 => nine_256, INIT_0A => nine_256, INIT_0B => nine_256,
--                      INIT_0C => nine_256, INIT_0D => nine_256, INIT_0E => nine_256,
--                      INIT_0F => nine_256)
               
--          port map(ADDRA => L_ADR_E,            ADDRB => "0000000000",
--                   CLKA => I_CLK,               CLKB => I_CLK,
--                   DIA => L_DIN_E(7 downto 4),  DIB => "0000",
--                   ENA => '1',                  ENB => '0',
--                   RSTA => '0',                 RSTB => '0',
--                   WEA => L_WE_E(0),               WEB => '0',
--                   DOA => L_DOUT_E(7 downto 4), DOB => open);
                   
    sr_2 : blk_mem_gen_0
    PORT MAP (
        clka => I_CLK,
        ena => '1',
        wea => L_WE_O,
        addra => L_ADR_O,
        dina => L_DIN_O(3 downto 0),
        douta => L_DOUT_O(3 downto 0),
        clkb => I_CLK,
        enb => '0',
        web => "0",
        addrb => "0000000000",
        dinb => "0000",
        doutb => open
    );
    
--          sr_2 : RAMB4_S4_S4 ---------------------------------------------------------------------------------
--          generic map(INIT_00 => nine_256, INIT_01 => nine_256, INIT_02 => nine_256,
--                      INIT_03 => nine_256, INIT_04 => nine_256, INIT_05 => nine_256,
--                      INIT_06 => nine_256, INIT_07 => nine_256, INIT_08 => nine_256,
--                      INIT_09 => nine_256, INIT_0A => nine_256, INIT_0B => nine_256,
--                      INIT_0C => nine_256, INIT_0D => nine_256, INIT_0E => nine_256,
--                      INIT_0F => nine_256)
               
--          port map(ADDRA => L_ADR_O,            ADDRB => "0000000000",
--                   CLKA => I_CLK,               CLKB => I_CLK,
--                   DIA => L_DIN_O(3 downto 0),  DIB => "0000",
--                   ENA => '1',                  ENB => '0',
--                   RSTA => '0',                 RSTB => '0',
--                   WEA => L_WE_O(0),               WEB => '0',
--                   DOA => L_DOUT_O(3 downto 0), DOB => open);
               
    sr_3 : blk_mem_gen_0
    PORT MAP (
        clka => I_CLK,
        ena => '1',
        wea => L_WE_O,
        addra => L_ADR_O,
        dina => L_DIN_O(7 downto 4),
        douta => L_DOUT_O(7 downto 4),
        clkb => I_CLK,
        enb => '0',
        web => "0",
        addrb => "0000000000",
        dinb => "0000",
        doutb => open
     );
               
--          sr_3 : RAMB4_S4_S4 ---------------------------------------------------------------------------------
--          generic map(INIT_00 => nine_256, INIT_01 => nine_256, INIT_02 => nine_256,
--                      INIT_03 => nine_256, INIT_04 => nine_256, INIT_05 => nine_256,
--                      INIT_06 => nine_256, INIT_07 => nine_256, INIT_08 => nine_256,
--                      INIT_09 => nine_256, INIT_0A => nine_256, INIT_0B => nine_256,
--                      INIT_0C => nine_256, INIT_0D => nine_256, INIT_0E => nine_256,
--                      INIT_0F => nine_256)
               
--          port map(ADDRA => L_ADR_O,            ADDRB => "0000000000",
--                   CLKA => I_CLK,               CLKB => I_CLK,
--                   DIA => L_DIN_O(7 downto 4),  DIB => "0000",
--                   ENA => '1',                  ENB => '0',
--                   RSTA => '0',                 RSTB => '0',
--                   WEA => L_WE_O(0),               WEB => '0',
--                   DOA => L_DOUT_O(7 downto 4), DOB => open);
               
    --remember ADR(0)
    --
    adr0: process(I_CLK)
    begin
       if(rising_edge(I_CLK)) then
           L_ADR_0 <= I_ADR(0);
       end if;
    end process;
       
    --we use two memory bloces _E and _O (even and odd)
    --this gives us a memory with ADR and ADR + 1 at the same time
    --the second port is comrrently unused, but may be used later.
    --e.g. for DMA
    --
    
    --internal signal assignment
    --Addresses
    --this seems like it might be flipped
    L_ADR_E  <= I_ADR(10 downto 1) + ("000000000" & I_ADR(0));
    L_ADR_O  <= I_ADR(10 downto 1);
    
    --data in
    --depends where it is spaced in memory
    L_DIN_E  <= I_DIN(7 downto 0) when (I_ADR(0) = '0') else I_DIN(15 downto 8);
    L_DIN_O  <= I_DIN(7 downto 0) when (I_ADR(0) = '1') else I_DIN(15 downto 8);
    
    --write enable
    L_WE_O(0)   <= I_WE(1) or (I_WE(0) and not I_ADR(0));
    L_WE_E(0)   <= I_WE(1) or (I_WE(0) and I_ADR(0));
       
    --output
    Q_DOUT( 7 downto 0) <= L_DOUT_E when (L_ADR_0 = '0') else L_DOUT_O;
    Q_DOUT(15 downto 8) <= L_DOUT_E when (L_ADR_0 = '1') else L_DOUT_O;
               
end Behavioral; 
               
          
