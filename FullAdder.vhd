library ieee;
use ieee.std_logic_1164.all;

entity FullAdder is
	port( A: in std_logic_vector(15 downto 0);
			B: in std_logic_vector(15 downto 0);
			A_B: out std_logic_vector(15 downto 0);
			c_out: out std_logic);
end entity;

architecture adder of FullAdder is

		function ADD(A: in std_logic_vector(15 downto 0);
					 B: in std_logic_vector(15 downto 0))
	return std_logic_vector is	
		variable sum : std_logic_vector(15 downto 0);
		variable carry : std_logic_vector(15 downto 0);
	begin
			summer: for i in 0 to 15 loop
						if i=0 then
							sum(i) := B(i) xor A(i) xor'0' ;
							carry(i) := B(i) and A(i);
						else
							sum(i) := B(i) xor A(i) xor carry(i-1);
							carry(i) := (B(i) and A(i)) or (carry(i-1) and (B(i) or A(i)));
						end if;						
					end loop summer;
		return carry(15) & sum;
	end ADD;
	
	signal result: std_logic_vector(16 downto 0);
begin
	result <= ADD(A, B);
	c_out <= result(16);
	A_B <= result(15 downto 0);
	
end adder;