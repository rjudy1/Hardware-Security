--status_reg.vhd
--Leslie Wallace
--18 Sept, 2021: Create code based on tutorial

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity status_reg is 
    port(I_CLK   : in std_logic;
         I_COND  : in std_logic_vector(3 downto 0);
         I_DIN   : in std_logic_vector(7 downto 0);
         I_FLAGS : in std_logic_vector(7 downto 0);
         I_WE_F  : in std_logic;
         I_WE_SR : in std_logic;
         
         Q       : out std_logic_vector(7 downto 0);
         Q_CC    : out std_logic);
  end status_reg;
  
  architecture Behavioral of status_reg is
      
     signal L : std_logic_vector(7 downto 0);

  begin  
      process(I_CLK)
      begin
          if (rising_edge(I_CLK)) then
             if (I_WE_F(1) = '1') then 
                L  <= I_FLAGS;        --write flags (from ALU)
             end if;
             if (I_WE(0) = '1') then 
                L <= I_DIN;           --write I/O
             end if;
         end if;
      end process;
            
      cond: process(I_COND, L)
      begin
          case I_COND(2 downto 0) is
              when "000" => Q_CC <= L(0) xor I_COND(3);
              when "001" => Q_CC <= L(1) xor I_COND(3);
              when "010" => Q_CC <= L(2) xor I_COND(3);
              when "011" => Q_CC <= L(3) xor I_COND(3);
              when "100" => Q_CC <= L(4) xor I_COND(3);
              when "101" => Q_CC <= L(5) xor I_COND(3);
              when "110" => Q_CC <= L(6) xor I_COND(3);
              when "111" => Q_CC <= L(7) xor I_COND(3);
          end case;
      end process;
            
      Q <= L;
  end Behavioral;
                
  
