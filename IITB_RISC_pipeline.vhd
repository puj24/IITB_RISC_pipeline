library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

entity pipeline is
	port(clock : in std_logic;
			reset: in std_logic);
end pipeline;

architecture pipeline_design of pipeline is
	
	--------------------COMPONENTS-----------------------
	
	component ROM is
		port(PC : in std_logic_vector(15 downto 0);
			Instruction: out std_logic_vector(15 downto 0));
	end component ROM;
	
	component Controller is
	    port(opcode : in std_logic_vector(3 downto 0);
                pc_next : out std_logic;
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
	end component Controller;
	
	component Register_Bank is
		port(	RF_A1 : in std_logic_vector(2 downto 0);
				RF_A2: in std_logic_vector(2 downto 0);
				RF_A3: in std_logic_vector(2 downto 0);
				RF_D1: out std_logic_vector(15 downto 0);
				RF_D2: out std_logic_vector(15 downto 0);
				RF_D3: in std_logic_vector(15 downto 0);
				reg_wb: in std_logic);
	end component Register_Bank;
	
	component ALU is
		port(ALU_opcode : in std_logic_vector(1 downto 0);
				add : in std_logic;
			   cpl : in std_logic;
            cz : in std_logic_vector(1 downto 0);
            carry_flag	: in std_logic;
            zero_flag : in std_logic;
            carry_out : out std_logic;
            zero_out : out std_logic;
            branch_inst : in std_logic;
            branch_type : in std_logic_vector(1 downto 0);
            branch_out : out std_logic;
            ALU_A : in std_logic_vector(15 downto 0);
            ALU_B : in std_logic_vector(15 downto 0);
            ALU_out: out std_logic_vector(15 downto 0);
            reg_wr_cz : out std_logic);
	end component ALU;
	
	component RAM is
		port(Mem_rd : in std_logic;
				Mem_wr : in std_logic;
				Address: in std_logic_vector(15 downto 0);
				Data_in : in std_logic_vector(15 downto 0);
				Data_out: out std_logic_vector(15 downto 0));
	end component RAM;
	
	signal PC, Instruction: std_logic_vector(15 downto 0):= (others=>'0');
	signal pc_next : std_logic :='0';
	
	signal RF_A1, RF_A2, RF_A3 : std_logic_vector(2 downto 0);
	signal RF_D1, RF_D2, RF_D3 : std_logic_vector(15 downto 0);
	signal reg_wb : std_logic;
	
	signal RF_A3_select, RF_D3_select : std_logic_vector(1 downto 0);
	
	signal ALU_A, ALU_B, ALU_out : std_logic_vector(15 downto 0); 
	signal ALU_opcode, ALU_B_select  : std_logic_vector(1 downto 0);
   signal ALU_A_select : std_logic;             

	signal add, carry_flag, zero_flag : std_logic :='0';
	signal carry_out, zero_out : std_logic;
	signal branch_inst, branch_out : std_logic;
	signal branch_type, jump_type : std_logic_vector(1 downto 0);
	
	signal Imm_SE_6, Imm_SE_9 : std_logic_vector(15 downto 0);
	
	signal load_store, branch, jump, reg_wr_cz: std_logic;
	signal Data_in, Data_out : std_logic_vector(15 downto 0);
	
	signal mem_rd, mem_wr : std_logic;
	
	signal IF_ID : std_logic_vector(50 downto 0);
	signal ID_RR : std_logic_vector(50 downto 0);
	signal RR_EX : std_logic_vector(82 downto 0);
	signal EX_MEM : std_logic_vector(98 downto 0);
	signal MEM_WB : std_logic_vector(120 downto 0);
	
begin
	
	Code_Mem: ROM port map(PC, Instruction);
	RF : Register_Bank port map(RF_A1, RF_A2, RF_A3, RF_D1, RF_D2, RF_D3, MEM_WB(98));
	
	
	ALU_unit: ALU port map(ALU_opcode, add, RR_EX(2), RR_EX(1 downto 0), 
									carry_flag, zero_flag, carry_out, zero_out, branch_inst, branch_type, branch_out, 
									ALU_A, ALU_B, ALU_out, reg_wr_cz);
									
	Control_Unit: Controller port map(IF_ID(15 downto 12), pc_next,
                RF_A3_select, RF_D3_select, ALU_opcode , ALU_A_select, ALU_B_select, add,
                branch_inst,  branch_type, jump, jump_type, reg_wb, mem_rd , mem_wr);
	
	Data_Memory : RAM port map(mem_rd, mem_wr, ALU_out, Data_in, Data_out); --from EX_MEM
	
	with ALU_A_select select RF_A1<=
							ID_RR(8 downto 6) when '1',	--load, store
							ID_RR(12 downto 9) when others;
							
	RF_A2	<= ID_RR(8 downto 6);
	
	with RF_A3_select select RF_A3<=
							MEM_WB(5 downto 3) when "00",
							MEM_WB(8 downto 6) when "01",
							MEM_WB(12 downto 9) when others;
							
	with RF_D3_select select RF_D3 <=
							ALU_out when "00", -- from MEM_WB register
							Data_out when "01",
							PC+2 when others;	--from MEM_WB register
	
	--ALU_A--
	with ALU_A_select select ALU_A<=
							RF_D2 when '1',	--read from RR_EX register
							RF_D1 when others;
	
	--ALU_B--
	with ALU_B_select select ALU_B<=
							Imm_SE_6 when "01",
							Imm_SE_9 when "11",
							RF_D2 when others;
	
	--PC select--
	PC_next_select: process(pc_next, jump, branch_out) begin
		case	pc_next is
			when '0' => PC <= PC + '1';
			when others =>
				if(jump = '1') then
					if(jump_type = "00") then 		PC <= PC + Imm_SE_6 + Imm_SE_6;
					elsif(jump_type = "01") then 	PC <= RF_D2;
					else 										PC <= RF_D1 + Imm_SE_9 + IMM_SE_9;
					end if;
				elsif(branch_out = '1') then 		PC <= PC + Imm_SE_6 + Imm_SE_6;
				else 											PC <= PC + '1';
				end if;
		end case;
	end process;
	
	
	Imm_SE_6 <= "000000000" & RR_EX(5 downto 0);
	Imm_SE_9 <= "000000" & RR_EX(9 downto 0);
	
	---Instruction Fetch---
	IF_ID_reg: process(clock)
	begin
		if( clock = '1' and clock'event) then
			IF_ID(31 downto 16) <= PC;
			IF_ID(15 downto 0) <= Instruction; 
		end if;
	end process;
	
	---Instruction Decode----
	ID_RR_reg: process(clock)
	begin
		if( clock = '1' and clock'event) then
			--control signals			
			ID_RR(49) <= pc_next;
			ID_RR(48 downto 47) <= RF_A3_select;
			ID_RR(46 downto 45) <= RF_D3_select;
			ID_RR(44 downto 43) <= ALU_opcode;
			ID_RR(42) <= ALU_A_select;
			ID_RR(41 downto 40) <= ALU_B_select;
			ID_RR(39) <= add;
			ID_RR(38) <= branch_inst;
			ID_RR(37 downto 36) <= branch_type;
			ID_RR(35) <= jump;
			ID_RR(34) <= reg_wb;
			ID_RR(33) <= mem_rd;
			ID_RR(32) <= mem_wr;
			ID_RR(31 downto 16) <= IF_ID(31 downto 16);	--PC
			ID_RR(15 downto 0) <= IF_ID(15 downto 0);		--Instruction
		end if;	
	end process;
	
	---Register Read---
	RR_EX_reg: process(clock)
	begin
		if( clock = '1' and clock'event) then
			RR_EX(81 downto 66) <= RF_D2;
			RR_EX(65 downto 50) <= RF_D1;
		--control signals
			RR_EX(49 downto 32) <= ID_RR(49 downto 32);
			RR_EX(31 downto 16) <= ID_RR(31 downto 16);	--PC
			RR_EX(15 downto 0) <= ID_RR(15 downto 0);		--Instruction
		end if;	
	end process;
	
	---Execute---
	EX_MEM_reg: process(clock)
	begin
		if( clock = '1' and clock'event) then
			EX_MEM(97 downto 82) <= ALU_out;
			EX_MEM(81 downto 66) <= RR_EX(81 downto 66);	--RF_D2
			EX_MEM(65 downto 50) <= RR_EX(65 downto 50);	--RF_D1
		--control signals
			EX_MEM(49 downto 32) <= RR_EX(49 downto 32);
			EX_MEM(31 downto 16) <= RR_EX(31 downto 16);	--PC
			EX_MEM(15 downto 0) <= RR_EX(15 downto 0);		--Instruction
		end if;	
	end process;
	
	---Memory----
	MEM_WB_reg: process(clock)
	begin
		if( clock = '1' and clock'event) then
			MEM_WB(98) <= reg_wr_cz and reg_wb;
			MEM_WB(97 downto 82) <= EX_MEM(97 downto 82);	--ALU_out
			MEM_WB(81 downto 66) <= EX_MEM(81 downto 66);	--RF_D2
			MEM_WB(65 downto 50) <= EX_MEM(65 downto 50);	--RF_D1
		--control signals
			MEM_WB(49 downto 32) <= EX_MEM(49 downto 32);
			MEM_WB(31 downto 16) <= EX_MEM(31 downto 16);	--PC
			MEM_WB(15 downto 0) <= EX_MEM(15 downto 0);		--Instruction
		end if;	
	end process;
	
	
	
end pipeline_design;