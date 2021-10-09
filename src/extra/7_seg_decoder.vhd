

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity 7_seg_decoder is
port (
    I_decoder           :in std_logic_vector(3 downto 0);       --decoder input
    I_decoder_blank     :in std_logic;                          --When '1', 7 segment is off entirely
    
    Q_7_SEGMENT         :out std_logic_vector(6 downto 0);      --Output to the seven segement display
    );

architecture behavior of 7_seg_decoder is
    signal decodeInput  :std_logic_vector(4 downto 0);          --Combination of the blank bit and signal to decode
begin
    decodeInput <= I_decoder_blank & I_decoder;
    with decodeInput select
    Q_7_SEGMENT <=  "1111110" when "00000",                     --Display '0'
                    "0110000" when "00001",                     --Display '1'
                    "1101101" when "00010",                     --Display '2'
                    "1111001" when "00011",                     --Display '3'
                    "0110011" when "00100",                     --Display '4'
                    "1011011" when "00101",                     --Display '5'
                    "1011111" when "00110",                     --Display '6'
                    "1110000" when "00111",                     --Display '7'
                    "1111111" when "01000",                     --Display '8'
                    "1111011" when "01001",                     --Display '9'
                    "1110111" when "01010",                     --Display 'A'
                    "0011111" when "01011",                     --Display 'b'
                    "1001110" when "01100",                     --Display 'C'
                    "0111101" when "01101",                     --Display 'd'
                    "1001111" when "01110",                     --Display 'E'
                    "1000111" when "01111",                     --Display 'F'
                    "0000000" when others;                      --Any combination with I_decoder_blank = '1' is blank/reserved
end behavior;