library ieee;
use ieee.std_logic_1164.all;

entity tb is
end entity;

architecture ftb of tb is
	component FullAdder is
	port( A: in std_logic_vector(15 downto 0);
			B: in std_logic_vector(15 downto 0);
			A_B: out std_logic_vector(15 downto 0);
			c_out: out std_logic);
	end component FullAdder;
	
	signal A, B, A_B : std_logic_vector(15 downto 0);
	signal clk, c_out :std_logic := '0';
	constant clk_period : time := 20 ns;
begin
	clk <= not clk after clk_period/2 ;
	A <= "0010101001111011";
	B <= "0010010111011101";
	ftb_instance : FullAdder port map(A, B, A_B, c_out);
end ftb;