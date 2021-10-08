library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
	
entity RAMB4_S4_S4 is
    generic(INIT_00 : bit_vector := X"00000000000000000000000000000000"
                                  &  "00000000000000000000000000000000";
            INIT_01 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_02 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_03 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_04 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_05 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_06 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_07 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_08 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_09 : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_0A : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_0B : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_0C : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_0D : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_0E : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000";
            INIT_0F : bit_vector := X"00000000000000000000000000000000"
                                  & X"00000000000000000000000000000000");
	
    port(   ADDRA   : in  std_logic_vector(9 downto 0);
            ADDRB   : in  std_logic_vector(9 downto 0);
            CLKA    : in  std_ulogic;
            CLKB    : in  std_ulogic;
            DIA     : in  std_logic_vector(3 downto 0);
            DIB     : in  std_logic_vector(3 downto 0);
            ENA     : in  std_ulogic;
            ENB     : in  std_ulogic;
            RSTA    : in  std_ulogic;
            RSTB    : in  std_ulogic;
            WEA     : in  std_ulogic;
            WEB     : in  std_ulogic;

            DOA     : out std_logic_vector(3 downto 0);
            DOB     : out std_logic_vector(3 downto 0));
end RAMB4_S4_S4;

architecture Behavioral of RAMB4_S4_S4 is
	
	function cv(A : bit) return std_logic is
	begin
 	   if (A = '1') then return '1';
 	   else              return '0';
 	   end if;
 	end;
 	
 	function cv1(A : std_logic) return bit is
 	begin
 	   if (A = '1') then return '1';
 	   else              return '0';
	   end if;
	end;
 	
	signal DATA : bit_vector(4095 downto 0) :=
	    INIT_0F & INIT_0E & INIT_0D & INIT_0C & INIT_0B & INIT_0A & INIT_09 & INIT_08 & 
    	INIT_07 & INIT_06 & INIT_05 & INIT_04 & INIT_03 & INIT_02 & INIT_01 & INIT_00;
	
begin
    process(CLKA, CLKB)
    begin
        -- drive clock A and B on the same clock
        if (rising_edge(CLKA)) then
            if (ENA = '1') then
                DOA <= cv(DATA(conv_integer(ADDRA & "11"))) &
                 cv(DATA(conv_integer(ADDRA & "10"))) & 
                 cv(DATA(conv_integer(ADDRA & "01"))) &
                 cv(DATA(conv_integer(ADDRA & "00")));
           end if;
--        end if;
	
--        if (rising_edge(CLKB)) then
            if (ENB = '1') then
                DOB(3) <= cv(DATA(conv_integer(ADDRB & "11")));
                DOB(2) <= cv(DATA(conv_integer(ADDRB & "10")));
                DOB(1) <= cv(DATA(conv_integer(ADDRB & "01")));
                DOB(0) <= cv(DATA(conv_integer(ADDRB & "00")));
                if (WEB = '1') then
                    DATA(conv_integer(ADDRB & "11")) <= cv1(DIB(3));
                    DATA(conv_integer(ADDRB & "10")) <= cv1(DIB(2));
                    DATA(conv_integer(ADDRB & "01")) <= cv1(DIB(1));
                    DATA(conv_integer(ADDRB & "00")) <= cv1(DIB(0));
                end if;
            end if;
            
            if (ENA = '1') then
                if (WEA = '1') then
                    DATA(conv_integer(ADDRA & "11")) <= cv1(DIA(3));
                    DATA(conv_integer(ADDRA & "10")) <= cv1(DIA(2));
                    DATA(conv_integer(ADDRA & "01")) <= cv1(DIA(1));
                    DATA(conv_integer(ADDRA & "00")) <= cv1(DIA(0));
                end if;
           end if;
            
        end if;
    end process;
	
end Behavioral;