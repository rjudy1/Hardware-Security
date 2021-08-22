

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