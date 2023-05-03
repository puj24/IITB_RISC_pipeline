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
	type Mem is array (0 to 50) of std_logic_vector(15 downto 0);
	signal ROM_Mem : Mem := (
	"0100"&"001" & "000" &"000000",		--load Reg1
	"0100000000000000",		--load Reg0
	"0100010000000000",		--load Reg2
	"0100011000000000",		--load Reg3
	"0100100000000000",		--load Reg4
	"0100101000000000",		--load Reg5
	"0100110000000000",		--load Reg6
	"1111111000000000");
begin
	Instruction <= ROM_Mem(to_integer(unsigned(PC)));
end Fetch;