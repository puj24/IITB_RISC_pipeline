library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

entity RAM is
	port(Mem_rd : in std_logic;
			Mem_wr : in std_logic;
			Address: in std_logic_vector(15 downto 0);
			Data_in : in std_logic_vector(15 downto 0);
			Data_out: out std_logic_vector(15 downto 0));
end RAM;

architecture RAM_interface of RAM is
		type RAM_array is array (0 to (2**16)) of std_logic_vector(15 downto 0) ;
		signal RAM : RAM_array :=(others=> (others=>'0') );
begin
	process(Mem_rd, Mem_wr) begin
		if(Mem_rd = '1') then
			Data_out <= RAM(to_integer(unsigned(Address)));
		end if;
		
		if(Mem_wr = '1') then
			RAM(to_integer(unsigned(Address))) <= Data_in;
		end if;
	end process;
end RAM_interface;