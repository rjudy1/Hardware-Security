--This component is for debugging and can be changed as needed

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seg is
port (
	I_PC			:in std_logic_vector(15 downto 0);		--Program counter from CPU
	I_clk			:in std_logic;							--Used to time delays between showing each digit
	
	Q_decoder		:out std_logic_vector(3 downto 0);		--Output to decoder
	Q_decoder_blank	:out std_logic;							--When '1', 7 segment is off entirely
	);
	
architecture behavior of seg is
	signal L_digitBeingShown	:std_logic_vector(2 downto 0);	--This value determines which digit is being shown
begin
	process(I_clk)
	begin
		if(rising_edge(I_clk)) then
			L_digitBeingShown0 <= L_digitBeingShown + 1;
		end if;
	end process;
	
	if(L_digitBeingShown(2 downto 1) = "00") then			--When L_digitBeingShown is 0 or 1
		Q_decoder <= I_PC(15 downto 12);						--Show first digit
		Q_decoder_blank <= '0';
	elsif(L_digitBeingShown(2 downto 1) = "01") then		--When L_digitBeingShown is 2 or 3
		Q_decoder <= I_PC(11 downto 8);							--Show second digit
		Q_decoder_blank <= '0';
	elsif(L_digitBeingShown(2 downto 1) = "10") then		--When L_digitBeingShown is 4 or 5
		Q_decoder <= I_PC(7 downto 4);							--Show third digit
		Q_decoder_blank <= '0';
	elsif(L_digitBeingShown(0) = '0') then					--When L_digitBeingShown is 6
		Q_decoder <= I_PC(3 downto 0);							--Show fourth digit
		Q_decoder_blank <= '0';
	else													--When L_digitBeingShown is 7
		Q_decoder <= "----";									--Show blank
		Q_decoder_blank <= '1';
	end if;
end behavior;