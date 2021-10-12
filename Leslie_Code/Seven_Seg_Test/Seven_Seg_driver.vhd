--****** VHDL Design file for a Binary to Seven Segment Driver ***
library IEEE;
use IEEE.std_logic_1164.all;

Entity Seven_Seg_Driver is 
	port(Data_in: in  STD_LOGIC_VECTOR (3 downto 0);
	     LED: out STD_LOGIC_VECTOR (6 downto 0));
End Seven_Seg_Driver;

--****** This Case statement is very close to a truth table ***

Architecture Structure of Seven_Seg_Driver is
Begin
	Process(Data_in)
	Begin
		Case Data_in is
		--  A one turns that Segment 0n and a 0 turns it off
		--                         ABCDEFG
			
			when "0000" => LED <= "0000001";  
			when "0001" => LED <= "1001111";
			when "0010" => LED <= "0010010";
			when "0011" => LED <= "0000110";
			
			when "0100" => LED <= "1001100";
			when "0101" => LED <= "0100100";
			when "0110" => LED <= "0100000";
			when "0111" => LED <= "0001111";
			
			when "1000" => LED <= "0000000";
			when "1001" => LED <= "0000100";
			when "1010" => LED <= "0001000";
			when "1011" => LED <= "1100000";
			
			when "1100" => LED <= "0110001";
			when "1101" => LED <= "1000010";
			when "1110" => LED <= "0110000";
			when "1111" => LED <= "0111000";
			
			when others => LED <= "1111110";--this should never occur
		End Case;
	End process;
End Structure;

