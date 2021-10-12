----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/29/2021 02:10:37 PM
-- Design Name: 
-- Module Name: BasicLEDController - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BasicLEDController is
    Port ( BTN : in STD_LOGIC_VECTOR (3 downto 0);
           LD : out STD_LOGIC_VECTOR (3 downto 0));
end BasicLEDController;

architecture Behavioral of BasicLEDController is
   
begin
     LD <= BTN;

end Behavioral;
