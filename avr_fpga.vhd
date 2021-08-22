 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
 entity avr_fpga is
 port ( 
	I_CLK_100 : in std_logic;
	I_SWITCH : in std_logic_vector(9 downto 0);
	I_RX : in std_logic;

	Q_7_SEGMENT : out std_logic_vector(6 downto 0);
	Q_LEDS : out std_logic_vector(3 downto 0);
	Q_TX : out std_logic
	);


architecture behavior of avr_fpga is
    component cpu_core
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
  	  Q_WE_IO : out std_logic);
     end component;
 
     signal C_PC : std_logic_vector(15 downto 0);
     signal C_OPC : std_logic_vector(15 downto 0);
     signal C_ADR_IO : std_logic_vector( 7 downto 0);
     signal C_DOUT : std_logic_vector( 7 downto 0);
     signal C_RD_IO : std_logic;
     signal C_WE_IO : std_logic;


    component io
	port ( 
	  I_CLK : in std_logic;
 	  I_CLR : in std_logic;
 	  I_ADR_IO : in std_logic_vector( 7 downto 0);
 	  I_DIN : in std_logic_vector( 7 downto 0);
	  I_RD_IO : in std_logic;
  	  I_WE_IO : in std_logic;
  	  I_SWITCH : in std_logic_vector( 7 downto 0);
 	  I_RX : in std_logic;

	  Q_7_SEGMENT : out std_logic_vector( 6 downto 0);
 	  Q_DOUT : out std_logic_vector( 7 downto 0);
 	  Q_INTVEC : out std_logic_vector(5 downto 0);
 	  Q_LEDS : out std_logic_vector( 1 downto 0);
 	  Q_TX : out std_logic);
    end component;
 
    signal N_INTVEC : std_logic_vector( 5 downto 0);
    signal N_DOUT : std_logic_vector( 7 downto 0);
    signal N_TX : std_logic;
    signal N_7_SEGMENT : std_logic_vector( 6 downto 0);

    component segment7
 	port ( 
  	  I_CLK : in std_logic;
       	  I_CLR : in std_logic;
 	  I_OPC : in std_logic_vector(15 downto 0);
 	  I_PC : in std_logic_vector(15 downto 0);
 
 	  Q_7_SEGMENT : out std_logic_vector( 6 downto 0));
    end component;
 
    signal S_7_SEGMENT : std_logic_vector( 6 downto 0);



begin

end behavior;