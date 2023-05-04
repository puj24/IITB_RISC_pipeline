library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

entity ROM is
	port(PC : in std_logic_vector(15 downto 0);
			Instruction: out std_logic_vector(15 downto 0));
end ROM;

architecture Fetch of ROM is
--	exceuting 50 instructions
	type Mem is array (0 to 19) of std_logic_vector(15 downto 0);
	signal ROM_Mem : Mem := (
	"0011"&"001"&"000000010",		--load Reg1
	"0011"&"010"&"000111110",		--load Reg0
--	"0100010000000000",		--load Reg2
--	"0100011000000000",		--load Reg3
--	"0100100000000000",		--load Reg4
--	"0100101000000000",		--load Reg5
--	"0100110000000000"		--load Reg6
--	"0011000000000110",
	"0011"&"011"&"010001110",
	"0011"&"100"&"010011110",
	"0011"&"101"&"010111110",
	"0011"&"110"&"011111110",
	"0011"&"111"&"000000000",
	
--	"0011001111000110",
	
	"0001"&"001"&"110"&"011"&"100",	--ex_mem
	"0011000000000000",	--rr_ex
	"0001"&"101"&"000"&"100"&"100",	--rr_ex

	"0011000000000001",
	"0011101000000010",
	"0001"&"001"&"110"&"011"&"100",
	
	"0010"&"110"&"001"&"110"&"000",
	"0011"&"110"&"101010110",
	"0101"&"010"&"000000010",	--store
	"0011000000000000",
	"0011000000000000",
	"0011000000000000",
--	"0011000000000000",
--	"0011000000000000",
	"1111011000000000"
--	"1111111000000000"
	);
begin
	Instruction <= ROM_Mem(to_integer(unsigned(PC)));
end Fetch;