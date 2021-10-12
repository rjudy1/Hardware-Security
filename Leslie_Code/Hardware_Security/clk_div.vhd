library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
  
entity clk_div is
generic ( 
    divider : integer
    );
port ( 
    clk,reset: in std_logic;
    clock_output: out std_logic
    );
end clk_div;
  
architecture behavioral of clk_div is
  
signal count: integer:=0;
signal tmp : std_logic := '0';
  
begin
  
process(clk,reset)
begin
    if(reset='1') then
        count<=1;
        tmp<='0';
    elsif(clk'event and clk='1') then
        count <=count+1;
        if (count = divider) then
            tmp <= NOT tmp;
            count <= 1;
        end if;
    end if;
    clock_output <= tmp;
end process;
  
end behavioral;
