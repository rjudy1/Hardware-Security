library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
  
entity clk_div is
generic ( 
    divider : integer
    );
port ( 
    clk : in std_logic;
    --reset: in std_logic;
    clock_output: out std_logic
    );
end clk_div;
  
architecture behavioral of clk_div is
  
signal count: integer:=0;
signal tmp : std_logic := '0';
  
begin
  
process(clk)
begin
--    if(reset='1') then
--        count<=1;
--        tmp<='0';
    if(rising_edge(clk)) then
        count <=count+1;
        if (count = divider/2) then
            tmp <= NOT tmp;
            count <= 1;
        end if;
    end if;
    clock_output <= tmp;
end process;
  
end behavioral;
