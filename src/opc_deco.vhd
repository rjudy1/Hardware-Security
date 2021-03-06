 library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.STD_LOGIC_ARITH.ALL;
 use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
use work.common.ALL;
    
entity opc_deco is
   port (  I_CLK       : in  std_logic; -- clk signal input
    
            I_OPC       : in  std_logic_vector(31 downto 0); -- opcode input to be decoded
            I_PC        : in  std_logic_vector(15 downto 0); -- address from which it was fetched
            I_T0        : in  std_logic; -- 1 in first cycle, 0 on second cycle
    
            Q_ALU_OP    : out std_logic_vector( 4 downto 0); -- operation put out

    -- based on data path
    -- AS_SP = stack pointer (3 bits of addr source)
    -- AS_Z = Z register pair
    -- AS_IMM = immediate 
    -- A0_Q, offset q from address source provided on IMM input (derived from opcode)
    -- AM_ indicates if X, Y, Z, SP are updated and go with decode of WE_XYZS

            Q_AMOD      : out std_logic_vector( 5 downto 0); -- addressing mode
            Q_BIT       : out std_logic_vector( 3 downto 0); -- bit value used in bit instructions
            Q_DDDDD     : out std_logic_vector( 4 downto 0); -- destination register
            Q_IMM       : out std_logic_vector(15 downto 0); -- immediate value
            Q_JADR      : out std_logic_vector(15 downto 0); -- jump addr
            Q_OPC       : out std_logic_vector(15 downto 0); -- opcode being decoded
            Q_PC        : out std_logic_vector(15 downto 0); -- pc from which opcode fetched
            Q_PC_OP     : out std_logic_vector( 2 downto 0); -- operation to be performed on pc
            Q_PMS       : out std_logic;  -- program memory select - for pm not data memory
            Q_RD_M      : out std_logic; -- set high for reads from data mem
            Q_RRRRR     : out std_logic_vector( 4 downto 0); -- second register
            Q_RSEL      : out std_logic_vector( 1 downto 0); -- select source of second operand as immediate, data from memory or I/O on DIN

            Q_WE_01     : out std_logic; -- indicates mult instruction for reg pair 0
            Q_WE_D      : out std_logic_vector( 1 downto 0); -- when reg Dx5 should be written, WE_D bit 0 indicates to use Dx5[0]
            Q_WE_F      : out std_logic; -- for status flags
            Q_WE_M      : out std_logic_vector( 1 downto 0); -- for memory writing
            Q_WE_XYZS   : out std_logic); -- for stack pointer or XYZ, encoded in AMOD
end opc_deco;

architecture behavioral of opc_deco is

begin
    process(I_CLK)
    begin
        if (rising_edge(I_CLK)) then
        --set most common settings as default (also nop)
            Q_ALU_OP <= ALU_D_MV_Q; -- move query
            Q_AMOD    <= AMOD_ABS; -- absolute addressing
            Q_BIT     <= I_OPC(10) & I_OPC(2 downto 0);
            Q_DDDDD   <= I_OPC(8 downto 4); -- 5 bits 8 to 4 of opcode represent DDDDD
            Q_IMM     <= X"0000";
            Q_JADR    <= I_OPC(31 downto 16); -- jump address contained in top 15 bits
            Q_OPC     <= I_OPC(15 downto  0); -- opcode contained in bottom 15
            Q_PC      <= I_PC;
            Q_PC_OP   <= PC_NEXT;
            Q_PMS     <= '0'; -- don't use program memory
            Q_RD_M    <= '0'; -- don't read from data mem by default
            Q_RRRRR   <= I_OPC(9) & I_OPC(3 downto 0); -- second reg address
            Q_RSEL    <= RS_REG;
            Q_WE_D    <= "00";
            Q_WE_01   <= '0';
            Q_WE_F    <= '0';
            Q_WE_M    <= "00";
            Q_WE_XYZS <= '0'; -- flags off

        -- case based on opcode
        case I_OPC(15 downto 10) is
            when "000000" =>
            case I_OPC(9 downto 8) is
                when "00" =>
                -- 0x0000 = NOP
                -- 0x00 001v vvvv - INTERUPT
                if (I_T0 and I_OPC(5)) = '1' then
                    Q_ALU_OP <= ALU_INTR;
                    Q_AMOD <= AMOD_ddSP;
                    Q_JADR <= "0000000000" & I_OPC(4 downto 0) & "0";
                                Q_PC_OP <= PC_LD_I;
                                Q_WE_F <= '1';
                                Q_WE_M <= "11";
                                Q_WE_XYZS <= '1'; 
                end if;

                    when "01" =>
                            -- 0000 0001 dddd rrrr - MOVW
                            Q_DDDDD <= I_OPC(7 downto 4) & "0";
                            Q_RRRRR <= I_OPC(3 downto 0) & "0";
                            Q_ALU_OP <= ALU_MV_16;
                            Q_WE_D <= "11";
    
                        when "10" =>
                            -- 0000 0010 dddd rrrr - MULS
                            Q_DDDDD <= "1" & I_OPC(7 downto 4);
                            Q_RRRRR <= "1" & I_OPC(3 downto 0);
                            Q_ALU_OP <= ALU_MULT;
                            Q_IMM(7 downto 5) <= MULT_SS;
                            Q_WE_01 <= '1';
                            Q_WE_F <= '1';
    
                        when others =>
                            -- 0000 0011 0ddd 0rrr -  MULSU  SU "010"
                            -- 0000 0011 0ddd 1rrr - FMUL    UU "100"
                            -- 0000 0011 1ddd 0rrr - FMULS   SS "111"
                            -- 0000 0011 1ddd 1rrr - FMULSU  SU "110"
                            Q_DDDDD(4 downto 3) <= "10";    -- regs 16 to 23
                            Q_RRRRR(4 downto 3) <= "10";    -- regs 16 to 23
                            Q_ALU_OP <= ALU_MULT;
                            if I_OPC(7) = '0' then
                                if I_OPC(3) = '0' then 
                                    Q_IMM(7 downto 5) <= MULT_SU;
                                else
                                    Q_IMM(7 downto 5) <= MULT_FUU;
                                end if;
                            else
                                if I_OPC(3) = '0' then 
                                    Q_IMM(7 downto 5) <= MULT_FSS;
                                else
                                    Q_IMM(7 downto 5) <= MULT_FSU;
                                end if;
                            end if;
                            Q_WE_01 <= '1';
                            Q_WE_F <= '1';
                    end case;
                when "000001" | "000010" =>
                    -- 0000 01rd dddd rrrr - CPC = SBC without Q_WE_D
                    -- 0000 10rd dddd rrrr - SBC
                    --
                    Q_ALU_OP <= ALU_SBC;
                    Q_WE_D <= '0' & I_OPC(11);  -- write Rd if SBC.
                    Q_WE_F <= '1';
    
                when "000011" =>
                    -- 0000 11rd dddd rrrr - ADD
                    --
                    Q_ALU_OP <= ALU_ADD;
                    Q_WE_D <= "01";
                    Q_WE_F <= '1';
    
                when "000100" => -- CPSE
                    Q_ALU_OP <= ALU_SUB;
                    Q_PC_OP <= PC_SKIP_Z;
    
                when "000101" | "000110" =>
                    -- 0001 01rd dddd rrrr - CP = SUB without Q_WE_D
                    -- 0000 10rd dddd rrrr - SUB
                    --
                    Q_ALU_OP <= ALU_SUB;
                    Q_WE_D <= '0' & I_OPC(11);  -- write Rd if SUB.
                    Q_WE_F <= '1';
    
                when "000111" =>
                    -- 0001 11rd dddd rrrr - ADC
                    --
                    Q_ALU_OP <= ALU_ADC;
                    Q_WE_D <= "01";
                    Q_WE_F <= '1';    

                when "001000" =>
                    -- 0010 00rd dddd rrrr - AND
                    --
                    Q_ALU_OP <= ALU_AND;
                    Q_WE_D <= "01";
                    Q_WE_F <= '1';
    
                when "001001" =>
                    --
                    -- 0010 01rd dddd rrrr - EOR
                    --
                    Q_ALU_OP <= ALU_EOR;
                    Q_WE_D <= "01";
                    Q_WE_F <= '1';
    
                when "001010" => -- OR
                    --
                    -- 0010 10rd dddd rrrr - OR
                    --
                    Q_ALU_OP <= ALU_OR;
                    Q_WE_D <= "01";
                    Q_WE_F <= '1';
    
                when "001011" =>
                    --
                    -- 0010 11rd dddd rrrr - MOV
                    --
                    Q_ALU_OP <= ALU_R_MV_Q;
                    Q_WE_D <= "01";
    
                when "001100" | "001101" | "001110" | "001111"
                   | "010100" | "010101" | "010110" | "010111" =>
                    --
                    -- 0011 KKKK dddd KKKK - CPI
                    -- 0101 KKKK dddd KKKK - SUBI
                    --
                    Q_ALU_OP <= ALU_SUB;
                    Q_IMM(7 downto 0) <= I_OPC(11 downto 8) & I_OPC(3 downto 0);
                    Q_RSEL <= RS_IMM;
                    Q_DDDDD(4) <= '1';    -- Rd = 16...31
                    Q_WE_D <= '0' & I_OPC(14);
                    Q_WE_F <= '1';
                
                when "010000" | "010001" | "010010" | "010011" =>
                    --
                    -- 0100 KKKK dddd KKKK - SBCI
                    --
                    Q_ALU_OP <= ALU_SBC;
                    Q_IMM(7 downto 0) <= I_OPC(11 downto 8) & I_OPC(3 downto 0);
                    Q_RSEL <= RS_IMM;
                    Q_DDDDD(4) <= '1';    -- Rd = 16...31
                    Q_WE_D <= "01";
                    Q_WE_F <= '1';

                when "011000" | "011001" | "011010" | "011011" =>
                    -- 0110 KKKK dddd KKKK - ORI
                    --
                    Q_ALU_OP <= ALU_OR;
                    Q_IMM(7 downto 0) <= I_OPC(11 downto 8) & I_OPC(3 downto 0);
                    Q_RSEL <= RS_IMM;
                    Q_DDDDD(4) <= '1';    -- Rd = 16...31
                    Q_WE_D <= "01";
                    Q_WE_F <= '1';
    
                when "011100" | "011101" | "011110" | "011111" =>
                    -- 0111 KKKK dddd KKKK - ANDI
                    --
                    Q_ALU_OP <= ALU_AND;
                    Q_IMM(7 downto 0) <= I_OPC(11 downto 8) & I_OPC(3 downto 0);
                    Q_RSEL <= RS_IMM;
                    Q_DDDDD(4) <= '1';    -- Rd = 16...31
                    Q_WE_D <= "01";
                    Q_WE_F <= '1';
    
                when "100000" | "100001" | "100010" | "100011"
                   | "101000" | "101001" | "101010" | "101011" =>
                    -- LDD (Y + q) == LD(y) if q == 0
                    -- 10q0 qq0d dddd 1qqq  LDD (Y + q)
                    -- 10q0 qq0d dddd 0qqq  LDD (Z + q)
                    -- 10q0 qq1d dddd 1qqq  SDD (Y + q)
                    -- 10q0 qq1d dddd 0qqq  SDD (Z + q)
                    --        L/      Z/
                    --        S       Y
                    --
                    -- device specific
                    --
                    Q_IMM(5 downto 0) <= I_OPC(13) & I_OPC(11 downto 10)
                                       & I_OPC(2 downto 0);
    
                    if (I_OPC(3) = '0') then    Q_AMOD <= AMOD_Zq;
                    else                        Q_AMOD <= AMOD_Yq;
                    end if;
    
                    Q_RD_M <= not I_OPC(9);             -- '1'  if LDD
                    Q_WE_M <= '0' & I_OPC(9);           -- "01" if STD
    
                when "100100" =>
                    Q_IMM <= I_OPC(31 downto 16);   -- for LDS/STS
                    if (I_OPC(9) = '0') then    -- LDD / POP
                        --
                        -- 1001 00-0d dddd 0000 - LDS
                        -- 1001 00-0d dddd 0001 - LD Rd, Z+
                        -- 1001 00-0d dddd 0010 - LD Rd, -Z
                        -- 1001 00-0d dddd 0100 - (ii)  LPM Rd, (Z)
                        -- 1001 00-0d dddd 0101 - (iii) LPM Rd, (Z+)
                        -- 1001 00-0d dddd 0110 - ELPM Z        --- not mega8
                        -- 1001 00-0d dddd 0111 - ELPM Z+       --- not mega8
                        -- 1001 00-0d dddd 1001 - LD Rd, Y+
                        -- 1001 00-0d dddd 1010 - LD Rd, -Y
                        -- 1001 00-0d dddd 1100 - LD Rd, X
                        -- 1001 00-0d dddd 1101 - LD Rd, X+
                        -- 1001 00-0d dddd 1110 - LD Rd, -X
                        -- 1001 00-0d dddd 1111 - POP Rd
                        --
                        Q_ALU_OP <= ALU_R_MV_Q;
                        Q_RSEL <= RS_DIN;
                        Q_RD_M <= I_T0;
                        Q_WE_D <= '0' & not I_T0;
                        Q_WE_XYZS <= not I_T0;
                        Q_PMS <= (not I_OPC(3)) and I_OPC(2) and (not I_OPC(1));
                        case I_OPC(3 downto 0) is
                            when "0000" => Q_AMOD <= AMOD_ABS;  Q_WE_XYZS <= '0';
                            when "0001" => Q_AMOD <= AMOD_Zi;
                            when "0100" => Q_AMOD <= AMOD_Z;    Q_WE_XYZS <= '0';
                            when "0101" => Q_AMOD <= AMOD_Zi;
                            when "1001" => Q_AMOD <= AMOD_Yi;
                            when "1010" => Q_AMOD <= AMOD_dY;
                            when "1100" => Q_AMOD <= AMOD_X;    Q_WE_XYZS <= '0';
                            when "1101" => Q_AMOD <= AMOD_Xi;
                            when "1110" => Q_AMOD <= AMOD_dX;
                            when "1111" => Q_AMOD <= AMOD_SPi;
                            when others =>                      Q_WE_XYZS <= '0';
                        end case;
                    else                        -- STD / PUSH
                        --
                        -- 1001 00-1r rrrr 0000 - STS
                        -- 1001 00-1r rrrr 0001 - ST Z+. Rr
                        -- 1001 00-1r rrrr 0010 - ST -Z. Rr
                        -- 1001 00-1r rrrr 1000 - ST Y. Rr
                        -- 1001 00-1r rrrr 1001 - ST Y+. Rr
                        -- 1001 00-1r rrrr 1010 - ST -Y. Rr
                        -- 1001 00-1r rrrr 1100 - ST X. Rr
                        -- 1001 00-1r rrrr 1101 - ST X+. Rr
                        -- 1001 00-1r rrrr 1110 - ST -X. Rr
                        -- 1001 00-1r rrrr 1111 - PUSH Rr
                        --
                        Q_ALU_OP <= ALU_D_MV_Q;
                        Q_WE_M <= "01";
                        Q_WE_XYZS <= '1';
                        case I_OPC(3 downto 0) is
                            when "0000" => Q_AMOD <= AMOD_ABS;  Q_WE_XYZS <= '0';
                            when "0001" => Q_AMOD <= AMOD_Zi;
                            when "0010" => Q_AMOD <= AMOD_dZ;
                            when "1001" => Q_AMOD <= AMOD_Yi;
                            when "1010" => Q_AMOD <= AMOD_dY;
                            when "1100" => Q_AMOD <= AMOD_X;    Q_WE_XYZS <= '0';
                            when "1101" => Q_AMOD <= AMOD_Xi;
                            when "1110" => Q_AMOD <= AMOD_dX;
                            when "1111" => Q_AMOD <= AMOD_dSP;
                            when others =>
                        end case;
                    end if;
    
                when "100101" =>
                    if (I_OPC(9) = '0') then
                        if (I_OPC(3) = '0') then
                            --
                            --  1001 010d dddd 0000 - COM
                            --  1001 010d dddd 0001 - NEG
                            --  1001 010d dddd 0010 - SWAP
                            --  1001 010d dddd 0011 - INC
                            --  1001 010d dddd 0101 - ASR
                            --  1001 010d dddd 0110 - LSR
                            --  1001 010d dddd 0111 - ROR
                            --
                            case I_OPC(2 downto 0) is
                                when "000"  => Q_ALU_OP <= ALU_COM;
                                when "001"  => Q_ALU_OP <= ALU_NEG;
                                when "010"  => Q_ALU_OP <= ALU_SWAP;
                                when "011"  => Q_ALU_OP <= ALU_INC;
                                when "101"  => Q_ALU_OP <= ALU_ASR;
                                when "110"  => Q_ALU_OP <= ALU_LSR;
                                when "111"  => Q_ALU_OP <= ALU_ROR;
                                when others =>
                            end case;
                            Q_WE_D <= "01";
                            Q_WE_F <= '1';
                        else
                            case I_OPC(2 downto 0) is
                                when "000"  =>
                                    if (I_OPC(8)) = '0' then
                                        --
                                        --  1001 0100 0sss 1000 - BSET
                                        --  1001 0100 1sss 1000 - BCLR
                                        --
                                        Q_BIT(3 downto 0) <= I_OPC(7 downto 4);
                                        Q_ALU_OP <= ALU_SREG;
                                        Q_WE_F <= '1';
                                    else
                                        --
                                        --  1001 0101 0000 1000 - RET
                                        --  1001 0101 0001 1000 - RETI
                                        --  1001 0101 1000 1000 - SLEEP
                                        --  1001 0101 1001 1000 - BREAK
                                        --  1001 0101 1100 1000 - LPM     [ R0,(Z) ]
                                        --  1001 0101 1101 1000 - ELPM   not mega8
                                        --  1001 0101 1110 1000 - SPM
                                        --  1001 0101 1111 1000 - SPM #2
                                        --  1001 0101 1010 1000 - WDR
                                        --
                                        case I_OPC(7 downto 4) is
                                            when "0000" =>  -- RET
                                                Q_AMOD <= AMOD_SPii;
                                                if (I_T0 = '1') then
                                                    Q_RD_M <= '1';
                                                else
                                                    Q_PC_OP <= PC_LD_S;
                                                    Q_WE_XYZS <= not I_T0;
                                                end if;
                                                
                                            when "0001" =>  -- RETI
                                                Q_ALU_OP <= ALU_INTR;
                                                Q_IMM(6) <= '1';
                                                Q_AMOD <= AMOD_SPii;
                                                if (I_T0 = '1') then
                                                    Q_RD_M <= '1';
                                                else
                                                    Q_PC_OP <= PC_LD_S;
                                                    Q_WE_XYZS <= not I_T0;
                                                end if;
                                                
                                            when "1000" =>  -- (i) LPM R0, (Z)
                                                Q_DDDDD <= "00000";
                                                Q_AMOD <= AMOD_Z;
                                                Q_PMS <= '1';
                                                Q_WE_D <= '0' & not I_T0;
                                            
                                            when "1110" =>  -- SPM
                                                Q_DDDDD <= "00000";
                                                Q_AMOD <= AMOD_Z;
                                                Q_PMS <= '1';
                                                Q_WE_M <= "01";
                                                
                                            when "1111" =>  -- SPM #2
                                                -- page write: not su[pported
    
                                            when others =>
                                        end case;
                                    end if;
    
                                when "001"  =>
                                    --
                                    --  1001 0100 0000 1001 IJMP
                                    --  1001 0100 0001 1001 EIJMP   -- not mega8
                                    --  1001 0101 0000 1001 ICALL
                                    --  1001 0101 0001 1001 EICALL   -- not mega8
                                    --
                                    Q_PC_OP <= PC_LD_Z;
                                    if (I_OPC(8) = '1') then        -- ICALL
                                        Q_ALU_OP <= ALU_PC_1;
                                        Q_AMOD <= AMOD_ddSP;
                                        Q_WE_M <= "11";
                                        Q_WE_XYZS <= '1';
                                    end if;
                                
                                when "010"  =>
                                    --
                                    --  1001 010d dddd 1010 - DEC
                                    --
                                    Q_ALU_OP <= ALU_DEC;
                                    Q_WE_D <= "01";
                                    Q_WE_F <= '1';
    
                                when "011"  =>
                                    --
                                    --  1001 0100 KKKK 1011 - DES   -- not mega8
                                    --
                                    
                                when "100" | "101"  =>
                                    --
                                    --  1001 010k kkkk 110k - JMP (k = 0 for 16 bit)
                                    --  kkkk kkkk kkkk kkkk
                                    --
                                    Q_PC_OP <= PC_LD_I;
                         
                                when "110" | "111"  =>
                                    --
                                    --  1001 010k kkkk 111k - CALL (k = 0)
                                    --  kkkk kkkk kkkk kkkk
                                    --
                                    Q_ALU_OP <= ALU_PC_2;
                                    Q_AMOD <= AMOD_ddSP;
                                    Q_PC_OP <= PC_LD_I;
                                    Q_WE_M <= "11";     -- both PC bytes
                                    Q_WE_XYZS <= '1';
    
                                when others =>
                            end case;
                        end if;
                    else
                        --
                        --  1001 0110 KKdd KKKK - ADIW
                        --  1001 0111 KKdd KKKK - SBIW
                        --
                        if (I_OPC(8) = '0') then    Q_ALU_OP <= ALU_ADIW;
                        else                        Q_ALU_OP <= ALU_SBIW;
                        end if;
                        Q_IMM(5 downto 4) <= I_OPC(7 downto 6);
                        Q_IMM(3 downto 0) <= I_OPC(3 downto 0);
                        Q_RSEL <= RS_IMM;
                        Q_DDDDD <= "11" & I_OPC(5 downto 4) & "0";
                        
                        Q_WE_D <= "11";
                        Q_WE_F <= '1';
                    end if; -- I_OPC(9) = 0/1
    
                when "100110" =>
                    --
                    --  1001 1000 AAAA Abbb - CBI
                    --  1001 1001 AAAA Abbb - SBIC
                    --  1001 1010 AAAA Abbb - SBI
                    --  1001 1011 AAAA Abbb - SBIS
                    --
                    Q_ALU_OP <= ALU_BIT_CS;
                    Q_AMOD <= AMOD_ABS;
                    Q_BIT(3) <= I_OPC(9);   -- set/clear
    
                    -- IMM = AAAAAA + 0x20
                    --
                    Q_IMM(4 downto 0) <= I_OPC(7 downto 3);
                    Q_IMM(6 downto 5) <= "01";
    
                    Q_RD_M <= I_T0;
                    Q_WE_M <= "00";
                    if ((I_OPC(8) = '0') ) then     -- CBI or SBI
                        Q_WE_M(0) <= '1';
                    else                            -- SBIC or SBIS
                        if (I_T0 = '0') then
                            Q_PC_OP <= PC_SKIP_T;
                        end if;
                    end if;
    
                when "100111" => -- MUL
                    --
                    --  1001 11rd dddd rrrr - MUL
                    --
                     Q_ALU_OP <= ALU_MULT;
                     Q_IMM(7 downto 5) <= "000"; --  -MUL UU;
                     Q_WE_01 <= '1';
                     Q_WE_F <= '1';
    
                when "101100" | "101101" =>
                    --
                    -- 1011 0AAd dddd AAAA - IN
                    --
                    Q_ALU_OP <= ALU_R_MV_Q;
                    Q_RSEL <= RS_DIN;
                    Q_AMOD <= AMOD_ABS;
    
                    -- IMM = AAAAAA
                    --     + 010000 (0x20)
                    Q_IMM(3 downto 0) <= I_OPC(3 downto 0);
                    Q_IMM(4) <= I_OPC(9);
                    Q_IMM(6 downto 5) <= "01" + ('0' & I_OPC(10 downto 10));
    
                    Q_WE_D <= "01";
    
                when "101110" | "101111" =>
                    --
                    -- 1011 1AAr rrrr AAAA - OUT
                    --
                    Q_ALU_OP <= ALU_D_MV_Q;
                    Q_AMOD <= AMOD_ABS;
    
                    -- IMM = AAAAAA
                    --     + 010000 (0x20)
                    --
                    Q_IMM(3 downto 0) <= I_OPC(3 downto 0);
                    Q_IMM(4) <= I_OPC(9);
                    Q_IMM(6 downto 5) <= "01" + ('0' & I_OPC(10 downto 10));
                    Q_WE_M <= "01";
    
                when "110000" | "110001" | "110010" | "110011" =>
                    --
                    -- 1100 kkkk kkkk kkkk - RJMP
                    --
                    Q_JADR <= I_PC + (I_OPC(11) & I_OPC(11) & I_OPC(11) & I_OPC(11)
                                    & I_OPC(11 downto 0)) + X"0001";
                    Q_PC_OP <= PC_LD_I;
    
                when "110100" | "110101" | "110110" | "110111" =>
                    --
                    -- 1101 kkkk kkkk kkkk - RCALL
                    --
                    Q_JADR <= I_PC + (I_OPC(11) & I_OPC(11) & I_OPC(11) & I_OPC(11)
                                    & I_OPC(11 downto 0)) + X"0001";
                    Q_ALU_OP <= ALU_PC_1;
                    Q_AMOD <= AMOD_ddSP;
                    Q_PC_OP <= PC_LD_I;
                    Q_WE_M <= "11";     -- both PC bytes
                    Q_WE_XYZS <= '1';
    
                when "111000" | "111001" | "111010" | "111011" => -- LDI
                    --
                    -- 1110 KKKK dddd KKKK - LDI Rd, K
                    --
                    Q_ALU_OP <= ALU_R_MV_Q;
                    Q_DDDDD <= '1' & I_OPC(7 downto 4);     -- 16..31
                    Q_IMM(7 downto 0) <= I_OPC(11 downto 8) & I_OPC(3 downto 0);
                    Q_RSEL <= RS_IMM;
                    Q_WE_D <= "01";
    
                when "111100" | "111101" =>
                    --
                    -- 1111 00kk kkkk kbbb - BRBS
                    -- 1111 01kk kkkk kbbb - BRBC
                    --       v
                    -- bbb: status register bit
                    -- v: value (set/cleared) of status register bit
                    --
                    Q_JADR <= I_PC + (I_OPC(9) & I_OPC(9) & I_OPC(9) & I_OPC(9)
                                    & I_OPC(9) & I_OPC(9) & I_OPC(9) & I_OPC(9)
                                    & I_OPC(9) & I_OPC(9 downto 3)) + X"0001";
                    Q_PC_OP <= PC_BCC;
    
                when "111110" =>
                    --
                    -- 1111 100d dddd 0bbb - BLD
                    -- 1111 101d dddd 0bbb - BST
                    --
                    if I_OPC(9) = '0' then  -- BLD: T flag to register
                        Q_ALU_OP <= ALU_BLD;
                        Q_WE_D <= "01";
                    else                    -- BST: register to T flag
                        Q_AMOD <= AMOD_ABS;
                        Q_BIT(3) <= I_OPC(10);
                        Q_IMM(4 downto 0) <= I_OPC(8 downto 4);
                        Q_ALU_OP <= ALU_BIT_CS;
                        Q_WE_F <= '1';
                    end if;
    
                when "111111" =>
                    --
                    -- 1111 110r rrrr 0bbb - SBRC
                    -- 1111 111r rrrr 0bbb - SBRS
                    --
                    -- like SBIC, but and general purpose regs instead of I/O regs.
                    --
                    Q_ALU_OP <= ALU_BIT_CS;
                    Q_AMOD <= AMOD_ABS;
                    Q_BIT(3) <= I_OPC(9);   -- set/clear bit
                    Q_IMM(4 downto 0) <= I_OPC(8 downto 4);
                    if (I_T0 = '0') then
                        Q_PC_OP <= PC_SKIP_T;
                    end if;
    
                when others =>
            end case;
        end if;

    end process;


end behavioral;
