library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

entity Register_Bank is
	port(	RF_A1 : in std_logic_vector(2 downto 0);
			RF_A2: in std_logic_vector(2 downto 0);
			RF_A3: in std_logic_vector(2 downto 0);
			RF_D1: out std_logic_vector(15 downto 0);
			RF_D2: out std_logic_vector(15 downto 0);
			RF_D3: in std_logic_vector(15 downto 0);
			reg_wb: in std_logic);
end Register_Bank;

architecture RF_design of Register_Bank is
	type Reg_array is array(0 to 8) of std_logic_vector(15 downto 0);
	signal RB: Reg_array:= (others =>"0000000000000000");
begin
		RF_D1 <= RB(to_integer(unsigned(RF_A1)));
		RF_D2 <= RB(to_integer(unsigned(RF_A2)));
		
		process(reg_wb) begin
		if(reg_wb = '1') then
			RB(to_integer(unsigned(RF_A3))) <= RF_D3;
		end if;
		end process;
end RF_design;