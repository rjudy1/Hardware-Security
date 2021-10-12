--reg_16.vhd
--Leslie Wallace
--23 Sept, 2021: Add comments
--18 Sept, 2021: Create code based on tutorial

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg_16 is 
    port( I_CLK : in std_logic;
         
         I_D    : in std_logic_vector(15 downto 0);   --data
         I_WE   : in std_logic_vector(1 downto 0);    --write enable (odd_reg  even_reg)
         
         Q      : out std_logic_vector(15 downto 0)); --current value of register
  end reg_16;
  
  architecture Behavioral of reg_16 is
    
    signal L   : std_logic_vector(15 downto 0) := X"7777"; 

    begin
      process(I_CLK)
      begin
          if (rising_edge(I_CLK)) then
              --Write enable Odd/High Byte
              if (I_WE(1) = '1') then 
                  L(15 downto 8)  <= I_D(15 downto 8);
              end if;
              --Write enable Even/Low Byte
              if (I_WE(0) = '1') then 
                  L(7 downto 0)  <= I_D(7 downto 0);
              end if;
          end if;
      end process;
      
      --Output internal signal
      Q <= L;

  end Behavioral;          

