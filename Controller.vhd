library ieee;
use ieee.std_logic_1164.all;

entity Controller is
	port(opcode : in std_logic_vector(3 downto 0);
			pc_next : out std_logic;
			regC_wr : out std_logic;
			regA_wr : out std_logic;
			regB_wr : out std_logic;
			regA_rd : out std_logic;
			regB_rd : out std_logic;
			RF_A3_select : out std_logic_vector(1 downto 0);
			RF_D3_select : out std_logic_vector(1 downto 0);
			ALU_opcode : out std_logic_vector(1 downto 0);
			ALU_A_select : out std_logic;
			ALU_B_select : out std_logic_vector(1 downto 0);
			add : out std_logic;
			branch_inst : out std_logic;
			branch_type : out std_logic_vector(1 downto 0);
			jump : out std_logic;
			jump_type : out std_logic_vector(1 downto 0);
			reg_wb: out std_logic;
			mem_rd : out std_logic;
			mem_wr: out std_logic);
end Controller;

architecture control_signals of Controller is
begin
		with opcode select regC_wr <=
								'1' when "0001",	--ADD
								'1' when "0010",	--NAND
								'0' when others;
		
		with opcode select regA_wr <=
								'1' when "0011",	--LLI
								'1' when "0100",	--LOAD
								'1' when "1100",	--JAL
								'1' when "1101",	--JLR
								'0' when others;							
		
		with opcode select regB_wr <=
								'1' when "0000",	--ADI
								'0' when others;
								
								
		with opcode select regA_rd <=
								'1' when "0001",	--ADD
								'1' when "0010",	--NAND
								'1' when "0000",	--ADI
								'1' when "0101", 	--store
								'1' when "1000",	--BEQ
								'1' when "1001",	--BLT
								'1' when "1010",	--BLE
								'1' when "1111",	--JRI
								'0' when others;
								
		with opcode select regB_rd <=
								'1' when "0001",	--ADD
								'1' when "0010",	--NAND
								'1' when "0100",	--LOAD
								'1' when "0101",	--store
								'1' when "1000",	--BEQ
								'1' when "1001",	--BLT
								'1' when "1010",	--BLE
								'1' when "1101",	--JLR
								'0' when others;
		
		with opcode select ALU_A_select<=
								'1' when "0100",	--load
								'1' when "0101",	--store
								'0' when others;
								
		with opcode select ALU_B_select<=
								"01" when "0000",	--ADI
								"01" when "0100",	--LW
								"01" when "0101",	--SW
								"11" when "1111",	--JRI
								"00" when others;
		
		with opcode select RF_A3_select <=
								"00" when "0001",	--add
								"00" when "0010",	--nand
								"01" when "0000",	--ADI
								"10" when "0011",	--LLI
								"10" when "0100",	--LW
								"10" when "1100",	--JAL
								"10" when "1101",	--JLR
								"11" when others;
								
		with opcode select RF_D3_select <=
								"01" when "0100",	--LW
								"10" when "0011",	--LLI
								"11" when "1100",	--JAL
								"11" when "1101",	--JLR
								"00" when others;
		
		with opcode select reg_wb <=
									'0' when "0101",	--SW
									'0' when "1000",	--BEQ
									'0' when "1001",	--BLT
									'0' when "1010",	--BLE
									'0' when "1111",	--JRI
									'1' when others;	--ADD, ADI, NAND, LW, LLI, JAL, JLR
		
	--ADD, NAND, LOAD, STORE
		with opcode select pc_next<=
								'1' when "1000",
								'1' when "1001",
								'1' when "1010",
								'1' when "1100",
								'1' when "1101",
								'1' when "1111",
								'0' when others;
	
	--ADD, ADI
		with opcode select add <=
								'1' when "0001",
								'1' when "0000",
								'0' when others;
	--ALU_OPCODE
		with opcode select ALU_opcode <=
								"00" when "0001",	--add
								"01" when "0010",	--nand
								"10" when "0100",	--load
								"10" when "0101",	--store
								"10" when "0000",	--adi
								"11" when others;
	
	--BEQ, BLT, BLE 
		with opcode select branch_inst<=
								'1' when "1000",
								'1' when "1001",
								'1' when "1010",
								'0' when others;
		with opcode select branch_type <=
								"00" when "1000",
								"01" when "1001",
								"10" when "1010",
								"11" when others;
								
		with opcode select jump <=
								'1' when "1100",
								'1' when "1101",
								'1' when "1111",
								'0' when others;
		
		with opcode select jump_type <=
								"00" when "1100",	--JAL
								"01" when "1101",	--JLR
								"11" when others;	--JRI
								
		with opcode select mem_rd<=
								'1' when "0100",
								'0' when others;
								
		with opcode select mem_wr<=
									'1' when "0101",
									'0' when others;
		
end control_signals;