--alu.vhd
--Leslie Wallace
--19 Sept, 2021: Create code based on tutorial

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.common.ALL;

entity alu is
  port(    I_ALU_OP  : in std_logic_vector(4 downto 0);
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
end alu;
  
architecture Behavioral of alu is
  
    function ze(A: std_logic_vector(7 downto 0)) return std_logic is
    begin
        return not (A(0) or A(1) or A(2) or A(3) or
                    A(4) or A(5) or A(6) or A(7));
    end;
    
    function cy(D, R, S: std_logic) return std_logic is
    begin
        return (D and R) or (D and not S) or (R and not S);
    end;
      
    function ov(D, R, S: std_logic) return std_logic is
    begin
        return (D and R and (not S)) or ((not D) and (not R) and S);
    end;

    function si(D, R, S: std_logic) return std_logic is
    begin
        return S xor ov(D, R, S);
    end;    
   
    signal L_ADC_DR  : std_logic_vector( 7 downto 0);   --D+R+Carry
    signal L_ADD_DR  : std_logic_vector( 7 downto 0);   --D+R
    signal L_ADIW_D  : std_logic_vector(15 downto 0);   --D+IMM
    signal L_AND_DR  : std_logic_vector( 7 downto 0);   --D and R
    signal L_ASR_D   : std_logic_vector( 7 downto 0);   --(signed D) >> 1
    signal L_D8      : std_logic_vector( 7 downto 0);   --D(7 downto 0)
    signal L_DEC_D   : std_logic_vector( 7 downto 0);   --D-1
    signal L_DOUT    : std_logic_vector(15 downto 0);   
    signal L_INC_D   : std_logic_vector( 7 downto 0);   --D+1
    signal L_LSR_D   : std_logic_vector( 7 downto 0);   --(unsigned) D >> 1
    signal L_MASK_I  : std_logic_vector( 7 downto 0);   --1 << IMM
    signal L_NEG_D   : std_logic_vector( 7 downto 0);   --0-D
    signal L_NOT_D   : std_logic_vector( 7 downto 0);   --0 not D
    signal L_OR_DR   : std_logic_vector( 7 downto 0);   --D or R
    signal L_PROD    : std_logic_vector(17 downto 0);   --D*R
    signal L_R8      : std_logic_vector( 7 downto 0);   --odd or even R
    signal L_RI8     : std_logic_vector( 7 downto 0);   --R8 or IMM
    signal L_RBIT    : std_logic;
    signal L_SBIW_D  : std_logic_vector(15 downto 0);   --D-IMM
    signal L_ROR_D   : std_logic_vector( 7 downto 0);   --D rotated right
    signal L_SBC_DR  : std_logic_vector( 7 downto 0);   --D-R-Carry
    signal L_SIGN_D  : std_logic;
    signal L_SIGN_R  : std_logic;
    signal L_SUB_DR  : std_logic_vector( 7 downto 0);   --D-R
    signal L_SWAP_D  : std_logic_vector( 7 downto 0);   --D swapped
    signal L_XOR_DR  : std_logic_vector( 7 downto 0);   --D xor R

    begin
        
        dinbit: process(I_DIN, I_BIT(2 downto 0))
        begin
            case I_BIT(2 downto 0) is
                when "000" => L_RBIT <= I_DIN(0); L_MASK <= "00000001";
                when "001" => L_RBIT <= I_DIN(1); L_MASK <= "00000010";
                when "010" => L_RBIT <= I_DIN(2); L_MASK <= "00000100";
                when "011" => L_RBIT <= I_DIN(3); L_MASK <= "00001000";
                when "100" => L_RBIT <= I_DIN(4); L_MASK <= "00010000";
                when "101" => L_RBIT <= I_DIN(5); L_MASK <= "00100000";
                when "110" => L_RBIT <= I_DIN(6); L_MASK <= "01000000";
                when others => L_RBIT <= I_DIN(7); L_MASK <= "1000000";
            end case;
        end process;

        process(L_ADC_DR, L_ADD_DR, L_ADIW_D, I_ALU_OP, L_AND_DR, L_ASR_D,
                I_BIT, I_D, L_D8, L_DEC_D, I_DIN, I_FLAGS, I_IMM, L_MASK_I,
                L_INC_D, L_LSR_D, L_NEG_D, L_NOT_D, L_OR_DR, I_PC, L_PROD,
                I_R, L_RI8, L_RBIT, L_ROR_D, L_SBIW_D, L_SUB_DR, L_SBC_DR
                L_SIGN_D, L_SIGN_R, L_SWAP_D, L_XOR_DR)
        begin 
            Q_FLAGS(9) <= L_RBIT xor not I_BIT(3)        --DIN[BIT]=BIT[3]
            Q_FLAGS(8) <= ze(L_SUB_DR);                  --D == R for CPSE 
            Q_FLAGS(7 downto 0) <= I_FLAGS;
            L_DOUT     <= X"0000";

            case I_ALU_OP is
                when ALU_ADC =>
                    L_DOUT  <= L_ADC_DR & L_ADC_DR;
                    Q_FLAGS(0) <= cy(L_D8(7), L_RI8(7), L_ADC_DR(7));  --carry
                    Q_FLAGS(1) <= ze(L_ADC_DR);                        --zero
                    Q_FLAGS(2) <= L_ADC_DR(7);                         --negative
                    Q_FLAGS(3) <= ov(L_D8(7), L_RI8(7), L_ADC_DR(7));  --overflow
                    Q_FLAGS(4) <= si(L_D8(7), L_RI8(7), L_ADC_DR(7));  --signed
                    Q_FLAGS(5) <= cy(L_D8(3), L_RI8(3), L_ADC_DR(3));  --halfcarry

                when ALU_ADD =>
                    L_DOUT  <= L_ADD_DR & L_ADD_DR;
                    Q_FLAGS(0) <= cy(L_D8(7), L_RI8(7), L_ADD_DR(7));  --carry
                    Q_FLAGS(1) <= ze(L_ADD_DR);                        --zero
                    Q_FLAGS(2) <= L_ADD_DR(7);                         --negative
                    Q_FLAGS(3) <= ov(L_D8(7), L_RI8(7), L_ADD_DR(7));  --overflow
                    Q_FLAGS(4) <= si(L_D8(7), L_RI8(7), L_ADD_DR(7));  --signed
                    Q_FLAGS(5) <= cy(L_D8(3), L_RI8(3), L_ADD_DR(3));  --halfcarry

                when ALU_ADIW =>
                    L_DOUT  <= L_ADIW_D;                               
                    Q_FLAGS(0) <= L_ADIW_D(15) and not I_D(15);        --carry
                    Q_FLAGS(1) <= ze(L_ADIW_D(15 downto 8)) and
                                  ze(L_ADIW_D(7 downto 0));            --zero
                    Q_FLAGS(2) <= L_ADIW_D(15);                        --negative
                    Q_FLAGS(3) <= I_D(15) and not L_ADIW_D(15);        --overflow
                    Q_FLAGS(4) <= (L_ADIW_D(15)  and not I_D(15))
                                   xor (I_D(15) and not L_ADIW_D(15));   --signed

                when ALU_AND =>
                    L_DOUT  <= L_AND_DR & L_AND_DR;
                    Q_FLAGS(1) <= ze(L_AND_DR);                        --zero
                    Q_FLAGS(2) <= L_AND_DR(7);                         --negative
                    Q_FLAGS(3) <= '0';                                 --overflow
                    Q_FLAGS(4) <= L_AND_DR(7);                         --signed

                when ALU_ASR =>
                    L_DOUT  <= L_ASR_D & L_ASR_D;
                    Q_FLAGS(0) <= L_D8(0);                             --carry
                    Q_FLAGS(1) <= ze(L_ASR_D);                         --zero
                    Q_FLAGS(2) <= L_D8(7);                             --negative
                    Q_FLAGS(3) <= L_D8(0) xor L_D8(7);                 --overflow
                    Q_FLAGS(4) <= L_D8(0);                             --signed
                    
                when ALU_BLD =>      --copy T flag to DOUT
                        case I_BIT(2 downto 0) is
                            when "000"  => L_DOUT( 0)  <= I_FLAGS(6);
                                           L_DOUT( 8)  <= I_FLAGS(6);
                            when "001"  => L_DOUT( 1)  <= I_FLAGS(6);
                                           L_DOUT( 9)  <= I_FLAGS(6);
                            when "010"  => L_DOUT( 2)  <= I_FLAGS(6);
                                           L_DOUT(10)  <= I_FLAGS(6);
                            when "011"  => L_DOUT( 3)  <= I_FLAGS(6);
                                           L_DOUT(11)  <= I_FLAGS(6);
                            when "100"  => L_DOUT( 4)  <= I_FLAGS(6);
                                           L_DOUT(12)  <= I_FLAGS(6);
                            when "101"  => L_DOUT( 5)  <= I_FLAGS(6);
                                           L_DOUT(13)  <= I_FLAGS(6);
                            when "110"  => L_DOUT( 6)  <= I_FLAGS(6);
                                           L_DOUT(14)  <= I_FLAGS(6);
                            when others => L_DOUT( 7)  <= I_FLAGS(6);
                                           L_DOUT(15)  <= I_FLAGS(6);
                        end case;
                                   
                when ALU_COM =>
                    L_DOUT  <= L_NOT_D & L_NOT_D;
                    Q_FLAGS(0) <= '1';                                 --carry
                    Q_FLAGS(1) <= ze(L_DEC_D);                         --zero
                    Q_FLAGS(2) <= L_DEC_D(7);                          --negative
                    if (L_D8 = X"80") then
                        Q_FLAGS(3) <= '1';                             --overflow
                        Q_FLAGS(4) <= not L_DEC_D(7);                  --signed  
                    else
                        Q_FLAGS(3) <= '0';                             --overflow
                        Q_FLAGS(4) <= L_DEC_D(7);                       --signed  
                    end if;
                       
                when ALU_EOR =>
                    L_DOUT  <= L_XOR_DR & L_XOR_DR;
                    Q_FLAGS(1) <= ze(L_XOR_DR);                        --zero
                    Q_FLAGS(2) <= L_XOR_DR(7);                         --negative
                    Q_FLAGS(3) <= '0';                                 --overflow
                    Q_FLAGS(4) <= L_XOR_DR(7);                         --signed

                when ALU_INC =>
                    L_DOUT  <= L_INC_D & L_INC_D;
                    Q_FLAGS(1) <= ze(L_INC_D);                         --zero
                    Q_FLAGS(2) <= L_INC_D(7);                          --negative
                    if (L_D8 = X"7F") then
                        Q_FLAGS(3) <= '1';                             --overflow
                        Q_FLAGS(4) <= not L_INC_D(7);                  --signed  
                    else
                        Q_FLAGS(3) <= '0';                             --overflow
                        Q_FLAGS(4) <= L_INC_D(7);                       --signed  
                    end if;

                when ALU_INTR =>
                    L_DOUT <= I_PC;
                    Q_FLAGS(7) <= I_IMM(6);  --ena/disable interrupts

                when ALU_LSR =>
                    L_DOUT  <= L_LSR_D & L_LSR_D;
                    Q_FLAGS(0) <= L_D8(0);                             --carry
                    Q_FLAGS(1) <= ze(L_LSR_D);                         --zero
                    Q_FLAGS(2) <= '0';                                 --negative
                    Q_FLAGS(3) <= L_D8(0);                             --overflow
                    Q_FLAGS(4) <= L_D8(0);                             --signed

                when ALU_D_MV_Q =>
                    L_DOUT <= L_D8 & L_D8;

                when ALU_R_MV_Q =>
                    L_DOUT <= L_RI8 & L_RI8;

                when ALU_MV_16 =>
                    L_DOUT <= L_R(15 downto 0) & L_RI8;

                when ALU_MULT =>
                    Q_FLAGS(0) <= L_PROD(15);                         --carry
                    if I_IMM(7) = '0' then                            --mult
                        L_DOUT <= L_PROD(15 downto 0);
                        Q_FLAGS(1) <= ze(L_PROD(15 downto 8))          --zero
                                  and ze(L_PROD(7 downto 0));
                    else 
                        L_DOUT <= L_PROD(14 downto 0) & "0";
                        Q_FLAGS(1) <= ze(L_PROD(14 downto 7))          --zero
                                  and ze(L_PROD(6 downto 9)&"0");
                    end if;
                      
                when ALU_NEG =>
                    L_DOUT  <= L_NEG_D & L_NEG_D;
                    Q_FLAGS(0) <= not ze(L_D8);                        --carry
                    Q_FLAGS(1) <= ze(L_NEG_D);                         --zero
                    Q_FLAGS(2) <= L_NEG_D(7);                          --negative
                    if (L_D8 = X"80") then
                        Q_FLAGS(3) <= '1';                             --overflow
                        Q_FLAGS(4) <= not L_NEG_D(7);                  --signed  
                    else
                        Q_FLAGS(3) <= '0';                             --overflow
                        Q_FLAGS(4) <= L_NEG_D(7);                      --signed  
                    end if;    
                    Q_FLAGS(5) <= L_D8(3) or L_NEG_D(3);               --halfcarry

                when ALU_OR =>
                    L_DOUT  <= L_OR_DR & L_OR_DR;
                    Q_FLAGS(1) <= ze(L_OR_DR);                        --zero
                    Q_FLAGS(2) <= L_OR_DR(7);                         --negative
                    Q_FLAGS(3) <= '0';                                --overflow
                    Q_FLAGS(4) <= L_OR_DR(7);                         --signed

                when ALU_PC_1 =>  --ICALL, RCALL
                    L_DOUT <= I_PC + X"0001";

                when ALU_PC_2 =>  --CALL
                    L_DOUT <= I_PC + X"0002";

                when ALU_ROR =>
                    L_DOUT  <= L_ROR_DR & L_ROR_DR;
                    Q_FLAGS(1) <= ze(L_ROR_DR);                        --zero
                    Q_FLAGS(2) <= I_FLAGS(0);                         --negative
                    Q_FLAGS(3) <= I_FLAGS(0) xor L_D8(0);             --overflow
                    Q_FLAGS(4) <= I_FLAGS(0);                         --signed
       
                when ALU_SBC =>
                    L_DOUT  <= L_SBC_DR & L_SBC_DR;
                    Q_FLAGS(0) <= cy(L_SBC_DR(7), L_RI8(7), L_D8(7));  --carry
                    Q_FLAGS(1) <= ze(L_SBC_DR) and I_FLAGS(1);         --zero
                    Q_FLAGS(2) <= L_SBC_DR(7);                         --negative
                    Q_FLAGS(3) <= ov(L_SBC_DR(7), L_RI8(7), L_D8(7));  --overflow
                    Q_FLAGS(4) <= si(L_ADC_DR(7), L_RI8(7), L_D8(7));  --signed
                    Q_FLAGS(5) <= cy(L_ADC_DR(3), L_RI8(3), L_D8(3));  --halfcarry
      
                when ALU_SBIW =>
                    L_DOUT  <= L_SBIW_D;                               
                    Q_FLAGS(0) <= L_SBIW_D(15) and not I_D(15);        --carry
                    Q_FLAGS(1) <= ze(L_SBIW_D(15 downto 8)) and
                                  ze(L_SBIW_D(7 downto 0));            --zero
                    Q_FLAGS(2) <= L_SBIW_D(15);                        --negative
                    Q_FLAGS(3) <= I_D(15) and not L_SBIW_D(15);        --overflow
                    Q_FLAGS(4) <= (L_SBIW_D(15)  and not I_D(15))
                                   xor (I_D(15) and not L_SBIW_D(15));   --signed

                when ALU_SREG =>
                    case I_BIT(2 downto 0) is
                        when "000" => Q_FLAGS(0) <= I_BIT(3);
                        when "001" => Q_FLAGS(1) <= I_BIT(3);
                        when "010" => Q_FLAGS(2) <= I_BIT(3);
                        when "011" => Q_FLAGS(3) <= I_BIT(3);
                        when "100" => Q_FLAGS(4) <= I_BIT(3);
                        when "101" => Q_FLAGS(5) <= I_BIT(3);
                        when "110" => Q_FLAGS(6) <= I_BIT(3);
                        when others => Q_FLAGS(7) <= I_BIT(3);
                    end case;
                      
                when ALU_SUB =>
                    L_DOUT  <= L_SUB_DR & L_SUB_DR;
                    Q_FLAGS(0) <= cy(L_SUB_DR(7), L_RI8(7), L_D8(7));  --carry
                    Q_FLAGS(1) <= ze(L_SUB_DR);                        --zero
                    Q_FLAGS(2) <= L_SUB_DR(7);                         --negative
                    Q_FLAGS(3) <= ov(L_SUB_DR(7), L_RI8(7), L_D8(7));  --overflow
                    Q_FLAGS(4) <= si(L_SUB_DR(7), L_RI8(7), L_D8(7));  --signed
                    Q_FLAGS(5) <= cy(L_SUB_DR(3), L_RI8(3), L_D8(3));  --halfcarry

                when ALU_SWAP =>
                    L_DOUT <= L_SWAP_D & L_SWAP_D;

                when others =>
            end case;
        end process;
              
        L_D8 <= I_D(15 downto 8) when (I_D0 = '1') else I_D(7 downto 0);
        L_D8 <= I_R(15 downto 8) when (I_R0 = '1') else I_R(7 downto 0);
        L_RI8 <= I_IMM           when (I_RSEL = RS_IMM) else L_R8;
              
        L_ADIW_D <= I_D + ("0000000000" & I_IMM(5 downto 0));
        L_SBIW_D <= I_D - ("0000000000" & I_IMM(5 downto 0));
        L_ADD_DR <= L_D8 + L_RI8;
        L_ADC_DR <= L_ADD_DR + ("0000000" & I_FLAGS(0));
        L_ASR_D  <= L_D8(7) + L_D8(7 downto 0);    --sign extend
        L_AND_DR <= L_D8 + L_RI8;
        L_DEC_D  <= L_D8 - X"01";
        L_INC_D  <= L_D8 + X"01";
        L_LSR_D  <= '0' & L_D8(7 downto 1);
        L_NEG_D  <= X"00" - L_D8;
        L_NOT_D  <= not L_D8;
        L_OR_DR  <= L_D8 or L_RI8;
        L_PROD   <= (L_SIGN_D & L_D8) * (L_SIGN_R & L_R8);
        L_ROR_D  <= I_FLAGS(0) & L_D8(7 downto 1);
        L_SUB_DR <= L_D8 - L_RI8;
        L_SBC_DR <= L_SUB_DR - ("0000000" & I_FLAGS(0));
        L_SIGN_D <= L_D8(7) and I_IMM(6);
        L_SIGN_R <= L_R8(7) and I_IMM(5);
        L_SWAP_D <= L_D8(3 downto 0) & L_D8(7 downto 4);
        L_XOR_DR <= L_D8 xor L_R8;

        Q_DOUT   <= (I_DIN & I_DIN) when (I_RSEL = RS_DIN) else L_DOUT;
          
end Behavioral;
      
      
