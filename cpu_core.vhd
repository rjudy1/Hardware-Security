

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity cpu_core is
port ( 
	I_CLK : in std_logic;
	I_CLR : in std_logic;
	I_INTVEC : in std_logic_vector( 5 downto 0);
	I_DIN : in std_logic_vector( 7 downto 0);
 
	Q_OPC : out std_logic_vector(15 downto 0);
	Q_PC : out std_logic_vector(15 downto 0);
	Q_DOUT : out std_logic_vector( 7 downto 0);
	Q_ADR_IO : out std_logic_vector( 7 downto 0);
	Q_RD_IO : out std_logic;
	Q_WE_IO : out std_logic
	
);
end cpu_core;

architecture behavior of cpu_core is


begin


  L_DIN <= F_PM_DOUT when (D_PMS = '1') else I_DIN(7 downto 0);
  L_INTVEC_5 <= I_INTVEC(5) and R_INT_ENA;

end behavior;