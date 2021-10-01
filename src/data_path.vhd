--data_path.vhd
--Leslie Wallace
--23 Sept, 2012: Add comments
--18 Sept, 2021: Create code based on tutorial

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.common.ALL;
entity data_path is
    port(I_CLK       : in std_logic;
         
         I_ALU_OP    : in std_logic_vector(4 downto 0);
         I_AMOD      : in std_logic_vector(5 downto 0);
         I_BIT       : in std_logic_vector(3 downto 0);
         I_DDDDD     : in std_logic_vector(4 downto 0);
         I_DIN       : in std_logic_vector(7 downto 0);
         I_IMM       : in std_logic_vector(15 downto 0);
         I_JADR      : in std_logic_vector(15 downto 0);
         I_OPC       : in std_logic_vector(15 downto 0);
         I_PC        : in std_logic_vector(15 downto 0);
         I_PC_OP     : in std_logic_vector(2 downto 0);
         I_PMS       : in std_logic;            --program memory select
         I_RD_M      : in std_logic;
         I_RRRRR     : in std_logic_vector(4 downto 0);
         I_RSEL      : in std_logic_vector(1 downto 0);
         I_WE_01     : in std_logic;
         I_WE_D      : in std_logic_vector(1 downto 0);
         I_WE_F      : in std_logic;
         I_WE_M      : in std_logic_vector(1 downto 0);
         I_WE_XYZS   : in std_logic;
         
         Q_ADR      : OUT std_logic_vector(15 downto 0);
         Q_DOUT     : OUT std_logic_vector(7 downto 0);
         Q_INT_ENA  : OUT std_logic;
         Q_LOAD_PC  : OUT std_logic;
         Q_NEW_PC   : OUT std_logic_vector(15 downto 0);
         Q_OPC      : OUT std_logic_vector(15 downto 0);
         Q_PC       : OUT std_logic_vector(15 downto 0);
         Q_RD_IO    : OUT std_logic;
         Q_SKIP     : OUT std_logic;
         Q_WE_IO    : OUT std_logic);
  end data_path;
  
  architecture Behavioral of data_path is
      
      --interacts with alu
      component alu
      port(I_ALU_OP  : in std_logic_vector(4 downto 0);
           I_BIT     : in std_logic_vector(3 downto 0);
           I_D       : in std_logic_vector(15 downto 0);
           I_D0      : in std_logic;
           I_DIN     : in std_logic_vector(7 downto 0);
           I_FLAGS   : in std_logic_vector(7 downto 0);
           I_IMM     : in std_logic_vector(7 downto 0);
           I_PC      : in std_logic_vector(15 downto 0);
           I_R       : in std_logic_vector(15 downto 0);
           I_R0      : in std_logic;
           I_RSEL    : in std_logic_vector(1 downto 0);
           
           Q_FLAGS   : out std_logic_vector(9 downto 0);
           Q_DOUT    : out std_logic_vector(15 downto 0));
      end component;
    
      signal A_DOUT  : std_logic_vector(15 downto 0);
      signal A_FLAGS : std_logic_vector(9 downto 0);

      component register_file
          port(I_CLK   : in std_logic;
         
               I_AMOD  : in std_logic_vector(5 downto 0);
               I_COND  : in std_logic_vector(3 downto 0);
               I_DDDDD : in std_logic_vector(4 downto 0);
               I_DIN   : in std_logic_vector(15 downto 0);
               I_FLAGS : in std_logic_vector(7 downto 0);
               I_IMM   : in std_logic_vector(15 downto 0);
               I_RRRR   : in std_logic_vector(4 downto 1);
               I_WE_01 : in std_logic;
               I_WE_D  : in std_logic_vector(1 downto 0);
               I_WE_F  : in std_logic;
               I_WE_M  : in std_logic;
               I_WE_XYZS : in std_logic;
         
               Q_ADR   : out std_logic_vector(15 downto 0);
               Q_CC    : out std_logic;
               Q_D     : out std_logic_vector(15 downto 0);
               Q_FLAGS : out std_logic_vector(7 downto 0);
               Q_R     : out std_logic_vector(15 downto 0);
               Q_S     : out std_logic_vector(7 downto 0);
               Q_Z     : out std_logic_vector(15 downto 0));
      end component;
        
      signal F_ADR   : std_logic_vector(15 downto 0);
      signal F_CC    : std_logic;
      signal F_D     : std_logic_vector(15 downto 0);
      signal F_FLAGS : std_logic_vector(7 downto 0);
      signal F_R     : std_logic_vector(15 downto 0);
      signal F_S     : std_logic_vector(7 downto 0);
      signal F_Z     : std_logic_vector(15 downto 0);

      --accesses with the data memory
      component data_mem
          port(I_CLK   : in std_logic;
         
               I_ADR   : in std_logic_vector(10 downto 0);
               I_DIN   : in std_logic_vector(15 downto 0);
               I_WE    : in std_logic_vector(1 downto 0);
         
               Q_DOUT  : out std_logic_vector(15 downto 0));
      end component;
      
      signal M_DOUT  : std_logic_vector(15 downto 0);
        
      signal L_DIN   : std_logic_vector(7 downto 0);
      signal L_WE_SRAM : std_logic_vector(1 downto 0);
      signal L_FLAGS_98 : std_logic_vector(9 downto 8);

  begin         
    
      alui : alu
      port map(I_ALU_OP  => I_ALU_OP,
               I_BIT     => I_BIT,
               I_D       => F_D,
               I_D0      => I_DDDDD(0),
               I_DIN     => L_DIN,
               I_FLAGS   => F_FLAGS,
               I_IMM     => I_IMM(7 downto 0),
               I_PC      => I_PC,
               I_R       => F_R,
               I_R0      => I_RRRRR(0),
               I_RSEL    => I_RSEL,
               
               Q_FLAGS   => A_FLAGS,
               Q_DOUT    => A_DOUT);
      
      regs : register_file
      port map(I_CLK      => I_CLK,
              
               I_AMOD     => I_AMOD,
               I_COND(3)  => I_OPC(10),
               I_COND(2 downto 0) => I_OPC(2 downto 0),
               I_DDDDD    => I_DDDDD,
               I_DIN      => A_DOUT,
               I_FLAGS    => A_FLAGS(7 downto 0),
               I_IMM      => I_IMM,
               I_RRRR    => I_RRRRR(4 downto 1),
               I_WE_01    => I_WE_01,
               I_WE_D     => I_WE_D,
               I_WE_F     => I_WE_F,
               I_WE_M     => I_WE_M(0),
               I_WE_XYZS  => I_WE_XYZS,
               
               Q_ADR     => F_ADR,
               Q_CC      => F_CC,
               Q_D       => F_D,
               Q_FLAGS   => F_FLAGS,
               Q_R       => F_R,
               Q_S       => F_S,   --Q_Rxx(F_ADR)
               Q_Z       => F_Z);
        
        sram : data_mem
        port map(I_CLK   => I_CLK,
         
                 I_ADR   => F_ADR(10 downto 0),
                 I_DIN   => A_DOUT,
                 I_WE    => L_WE_SRAM,
         
                 Q_DOUT  => M_DOUT);
          
        --remember A_FLAGS(9 downto 8) (within the current instruction).
        --
        flg98: process(I_CLK)
        begin
            if (rising_edge(I_CLK)) then
                L_FLAGS_98   <= A_FLAGS(9 downto 8);
            end if;
        end process;
              
        --whether PC shall be loaded wiht NEW_PC or not.
        --I.e. if a branch shall be taken or not
        --
              
        process(I_PC_OP, F_CC)
        begin
            case I_PC_OP is
                when PC_BCC  => Q_LOAD_PC <= F_CC; --maybe (PC on I_JADR)
                when PC_LD_I => Q_LOAD_PC <= '1'; --yes: new PC on I_JADR
                when PC_LD_Z => Q_LOAD_PC <= '1'; --yes: new PC on z
                when PC_LD_S => Q_LOAD_PC <= '1'; --yes: new PC on stack
                when otherS   => Q_LOAD_PC <= '0'; --no
            end case;
        end process;
              
        --whether the next instruction shall be skipped or not.
        --
        process(I_PC_OP, L_FLAGS_98, F_CC)
        begin
            case I_PC_OP is
                when PC_BCC  => Q_SKIP <= F_CC;            --if cond met
                when PC_LD_I => Q_SKIP <= '1';             --yes
                when PC_LD_Z => Q_SKIP <= '1';             --yes
                when PC_LD_S => Q_SKIP <= '1';             --yes
                when PC_SKIP_Z => Q_SKIP <= L_FLAGS_98(8); --if Z set
                when PC_SKIP_T => Q_SKIP <= L_FLAGS_98(9); --if T set
                when otherS   => Q_SKIP <= '0';            --no
            end case;
        end process;        
              
        Q_ADR    <= F_ADR;
        Q_DOUT   <= A_DOUT(7 downto 0);
        Q_INT_ENA <= A_FLAGS(7);
        Q_OPC    <= I_OPC;
        Q_PC     <= I_PC;

        Q_RD_IO  <= '0' when (F_ADR <X"20")
            else (I_RD_M and not I_PMS) when (F_ADR <X"5D")
            else '0';
        Q_WE_IO  <= '0' when (F_ADR <X"20")
            else I_WE_M(0) when (F_ADR <X"5D")
            else '0';
        L_WE_SRAM  <= "00" when (F_ADR <X"0060") 
            else I_WE_M;
        L_DIN <= I_DIN when (I_PMS = '1')
            else F_S when (F_ADR <X"0020")
            else I_DIN when (F_ADR <X"005D")
            else F_S when (F_ADR <X"0060")
            else M_DOUT(7 downto 0);
                
        --compute potential new PC valule from Z, (SP), or IMM.
        --
        Q_NEW_PC <= F_Z when I_PC_OP = PC_LD_Z    --IJMP, ICALL
            else M_DOUT when I_PC_OP = PC_LD_S    --RET, RETI
            else I_JADR;                          --JMP adr
                
end Behavioral;
               
