-- Module Name:    opc_fetch - Behavioral 
-- Create Date:    13:00:44 10/30/2009 
-- Description:    the opcode fetch stage of a CPU.
--
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;
    
entity opc_fetch is
    port (  I_CLK       : in  std_logic;                            --Clock input
            I_CLR       : in  std_logic;                            --When 1, clear program counter to 0
            I_INTVEC    : in  std_logic_vector(5 downto 0);         --Interrupt vector number to take (if MSB is 1) 
            I_LOAD_PC   : in  std_logic;                            --If set, load the value on NEW_PC to the PC
            I_NEW_PC    : in  std_logic_vector(15 downto 0);        --Load this PC if LOAD_PC is set
            I_PM_ADR    : in  std_logic_vector(11 downto 0);
            I_SKIP      : in  std_logic;                            --Comes from execution stage, invalidates part of the pipeline
    
            Q_OPC       : out std_logic_vector(31 downto 0);
            Q_PC        : out std_logic_vector(15 downto 0);
            Q_PM_DOUT   : out std_logic_vector(7 downto 0);         --Data output (program memory?) from data at PM_ADR
            Q_T0        : out std_logic);
end opc_fetch;
    
architecture Behavioral of opc_fetch is

    component prog_mem
    port (  I_CLK       : in  std_logic;
            I_WAIT      : in  std_logic;
            I_PC        : in  std_logic_vector (15 downto 0);
            I_PM_ADR    : in  std_logic_vector (11 downto 0);
    
            Q_OPC       : out std_logic_vector (31 downto 0);
            Q_PC        : out std_logic_vector (15 downto 0);
            Q_PM_DOUT   : out std_logic_vector ( 7 downto 0));
    end component;
    
    signal P_OPC            : std_logic_vector(31 downto 0);
    signal P_PC             : std_logic_vector(15 downto 0);
    
    signal L_INVALIDATE     : std_logic;                        --Set if I_CLR or I_SKIP is set
    signal L_LONG_OP        : std_logic;                        --Set if instruction has length of two words, causes PC to increment by 2
    signal L_NEXT_PC        : std_logic_vector(15 downto 0);    --What the program counter should be on the next clock
    signal L_PC             : std_logic_vector(15 downto 0);    --The program counter
    signal L_T0             : std_logic;
    signal L_WAIT           : std_logic;                        --Set on first cycle of 2 cycle instructions, halts the PC

begin
    
    pmem : prog_mem
    port map(   I_CLK       => I_CLK,
                I_WAIT      => L_WAIT,
                I_PC        => L_NEXT_PC,
                I_PM_ADR    => I_PM_ADR,
                Q_OPC       => P_OPC,
                Q_PC        => P_PC,
                Q_PM_DOUT   => Q_PM_DOUT);
 
    lpc: process(I_CLK)
    begin
         if (rising_edge(I_CLK)) then
             L_PC <= L_NEXT_PC;         --Set the program counter to its next value on rising edge
             L_T0 <= not L_WAIT;        --Clear T0 on rising edge if the WAIT signal was raised
         end if;
     end process;
    
     L_INVALIDATE <= I_CLR or I_SKIP;       --Set invalidate flag if external clear or skip was given
 
     L_NEXT_PC <= X"0000"       when (I_CLR     = '1')     --Clear the PC if I_CLR signal is high (reset)
            else L_PC           when (L_WAIT    = '1')      --Hold the PC if L_WAIT  is high(instructions that take 2 CLK cycles)
            else I_NEW_PC       when (I_LOAD_PC = '1')      --Load the PC (JUMP instruction)
            else L_PC + X"0002" when (L_LONG_OP = '1')      --Increment the PC by 2 (instructions that take 2 words)
            else L_PC + X"0001";    --Increment the PC by 1 (regular instructions)


    -- Two word opcodes:
    --
    --        9       3210
    -- 1001 000d dddd 0000 kkkk kkkk kkkk kkkk - LDS
    -- 1001 001d dddd 0000 kkkk kkkk kkkk kkkk - SDS
    -- 1001 010k kkkk 110k kkkk kkkk kkkk kkkk - JMP
    -- 1001 010k kkkk 111k kkkk kkkk kkkk kkkk - CALL
    
    
    L_LONG_OP <= '1' when (((P_OPC(15 downto  9) = "1001010") and (P_OPC( 3 downto  2) = "11"))       -- JMP, CALL
                       or  ((P_OPC(15 downto 10) = "100100") and (P_OPC( 3 downto  0) = "0000")))    -- LDS, STS
                else '0';


    -- Two cycle opcodes:
    --
    -- 1001 000d dddd .... - LDS etc.
    -- 1001 0101 0000 1000 - RET
    -- 1001 0101 0001 1000 - RETI
    -- 1001 1001 AAAA Abbb - SBIC
    -- 1001 1011 AAAA Abbb - SBIS
    -- 1111 110r rrrr 0bbb - SBRC
    -- 1111 111r rrrr 0bbb - SBRS
    
    
    L_WAIT <= '0'  when (L_INVALIDATE = '1')
         else '0'  when (I_INTVEC(5)  = '1')        --On valid interrupt
         else L_T0 when ((P_OPC(15 downto   9) = "1001000" )    -- LDS etc.
                     or  (P_OPC(15 downto   8) = "10010101")    -- RET etc.
                     or  ((P_OPC(15 downto 10) = "100110")      -- SBIC, SBIS
                       and P_OPC(8) = '1')
                     or  (P_OPC(15 downto  10) = "111111"))     -- SBRC, SBRS
        else  '0';
    
    Q_OPC <= X"00000000" when (L_INVALIDATE = '1')      --Invalid OPCODE due to I_CLR or I_SKIP
        else P_OPC       when (I_INTVEC(5) = '0')       --If not an interrupt
        else (X"000000" & "00" & I_INTVEC);     -- "interrupt opcode"
    
    Q_PC <= P_PC;
    Q_T0 <= L_T0;
    
end Behavioral;