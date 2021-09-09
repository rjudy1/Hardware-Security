library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity opc_fetch is
port(
	I_CLK		:	in 	std_logic;							--Clock input
	I_CLR		:	in 	std_logic;							--When 1, clear program counter to 0
	I_INTVEC	:	in 	std_logic_vector(5 downto 0);		--Interrupt vector to take (if MSB is 1)
	I_NEW_PC	:	in 	std_logic_vector(15 downto 0);
	I_LOAD_PC	:	in 	std_logic;
	I_SKIP		:	in 	std_logic;
	I_PM_ADR	:	in 	std_logic_vector(x downto 0);
	
	Q_PM_DOUT	:	out	std_logic_vector(x downto 0);
	Q_PC		:	out std_logic_vector(x downto 0);
	Q_OPC		:	out std_logic_vector(x downto 0);
	Q_T0		:	out std_logic
	);

architecture behavior of opc_fetch is