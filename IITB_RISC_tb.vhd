library ieee;
use ieee.std_logic_1164.all;

entity pipeline_tb is
end entity pipeline_tb;

architecture test of pipeline_tb is
	component pipeline is
	port(clock : in std_logic;
			reset: in std_logic
--			o_PC : out std_logic_vector(15 downto 0);
--			o_Instruction : out std_logic_vector(15 downto 0);
--			o_ALU_A : out std_logic_vector(15 downto 0);
--			o_ALU_B : out std_logic_vector(15 downto 0);
--			o_ALU_out : out std_logic_vector(15 downto 0);
--			o_RF_A1 : out std_logic_vector(2 downto 0);
--			o_RF_A2 : out std_logic_vector(2 downto 0);
--			o_RF_D1 : out std_logic_vector(15 downto 0);
--			o_RF_D2 :out std_logic_vector(15 downto 0)
--			o_R0 : out std_logic_vector(15 downto 0);
--			o_R1 : out std_logic_vector(15 downto 0);
--			o_R2 : out std_logic_vector(15 downto 0);
--			o_R3 : out std_logic_vector(15 downto 0);
--			o_R4 : out std_logic_vector(15 downto 0);
--			o_R5 : out std_logic_vector(15 downto 0);
--			o_R6 : out std_logic_vector(15 downto 0);
--			o_R7 : out std_logic_vector(15 downto 0)
			);
	end component pipeline;
	
	signal clk, rst :std_logic := '0';
	constant clk_period : time := 200 ns;
--	signal PC, Instruction,  RF_D1, RF_D2 
--	signal ALU_A, ALU_B, ALU_out: std_logic_vector(15 downto 0);
--	signal R0, R1, R2, R3, R4, R5, R6, R7 : std_logic_vector(15 downto 0);
--	signal RF_A1, RF_A2 : std_logic_vector(2 downto 0);
begin
	pipeline_instance : pipeline port map(clk ,rst);
--														, Instruction, ALU_A, ALU_B, ALU_out, 
--														RF_A1, RF_A2, RF_D1, RF_D2,
--														,R0, R1, R2, R3, R4, R5, R6, R7);
	clk <= not clk after clk_period/2 ;
	rst <= '0', '1' after 1200 ms;

end test;
