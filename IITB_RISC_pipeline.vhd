library ieee;
use ieee.std_logic_1164.all;

use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity pipeline is
	port(clock : in std_logic;
			reset: in std_logic
--			o_PC : out std_logic_vector(15 downto 0);
--			o_Instruction : out std_logic_vector(15 downto 0);
--			o_ALU_A : out std_logic_vector(15 downto 0);
--			o_ALU_B : out std_logic_vector(15 downto 0);
--			o_ALU_out : out std_logic_vector(15 downto 0)
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
			ALU_A : in std_logic_vector(15 downto 0);
			ALU_B : in std_logic_vector(15 downto 0);
			ALU_out : out std_logic_vector(15 downto 0);
			add : in std_logic;
			cpl : in std_logic;
			cz : in std_logic_vector(1 downto 0);
			carry_flag : in std_logic;
			zero_flag: in std_logic;
			carry_out : out std_logic;
			zero_out: out std_logic;
			branch_inst : in std_logic;
			branch_type : in std_logic_vector(1 downto 0);
			branch_out : out std_logic;
			jump_in : in std_logic;
--			jump_out : out std_logic;
			reg_wr_cz : out std_logic
			);
	end component ALU;
	
	component Hazard_Detection is
			port(regC_wr : in std_logic;	
				regA_wr : in std_logic;
				regB_wr : in std_logic;
				regA_rd : in std_logic;	--incoming inst
				regB_rd : in std_logic;	--incoming inst
				IF_ID : in std_logic_vector(15 downto 0);
				ID_RR : in std_logic_vector(15 downto 0);
				hazard_type : out std_logic_vector(1 downto 0);
				hazard_detect : out std_logic);
	end component Hazard_Detection;
	
	component RAM is
		port(Mem_rd : in std_logic;
				Mem_wr : in std_logic;
				Address: in std_logic_vector(15 downto 0);
				Data_in : in std_logic_vector(15 downto 0);
				Data_out: out std_logic_vector(15 downto 0));
	end component RAM;
--	
	
	signal PC, Instruction: std_logic_vector(15 downto 0):= (others=>'0');
	signal pc_next : std_logic :='0';
	
	signal regC_wr, regA_wr, regB_wr : std_logic;
	signal regA_rd, regB_rd : std_logic;
	
	signal RF_A1, RF_A2, RF_A3 : std_logic_vector(2 downto 0):= (others=>'0');
	signal RF_D1, RF_D2, RF_D3 : std_logic_vector(15 downto 0):= (others=>'0');
	signal reg_wb : std_logic :='0';
	
	signal RF_A3_select, RF_D3_select : std_logic_vector(1 downto 0):= (others=>'0');
	
	signal ALU_A, ALU_B, ALU_out : std_logic_vector(15 downto 0) :=(others=>'0'); 
	signal ALU_opcode, ALU_B_select  : std_logic_vector(1 downto 0):= (others=>'0');
   signal ALU_A_select : std_logic := '0';             

	signal carry_flag, zero_flag : std_logic :='0';
	signal carry_out, zero_out : std_logic := '0';
	signal branch_inst, branch_out : std_logic:='0' ;
	signal branch_type, jump_type : std_logic_vector(1 downto 0) := (others=>'0');
	
	signal Imm_SE_6, Imm_SE_9, Imm_SE_9_wr : std_logic_vector(15 downto 0) := (others=>'0');
	
	signal add, branch, jump, reg_wr_cz: std_logic := '0';
	signal jump_in, jump_out : std_logic := '0';
	signal Data_in, Data_out : std_logic_vector(15 downto 0) := (others=>'0');
	
	signal mem_rd, mem_wr : std_logic:= '0';
	
	signal hazard_detect, hazard_detect_2 : std_logic := '0';
	signal hazard_type, hazard_type_2 : std_logic_vector(1 downto 0);
	
	signal stall, stall_2 : std_logic := '0';
	
	signal IF_ID : std_logic_vector(31 downto 0):= (others=>'0');
	signal ID_RR : std_logic_vector(58 downto 0):= (others=>'0');
	signal RR_EX : std_logic_vector(90 downto 0):= (others=>'0');
	signal EX_MEM : std_logic_vector(106 downto 0):= (others=>'0');
	signal MEM_WB : std_logic_vector(123 downto 0):= (others=>'0');
	
begin
	
	Code_Mem: ROM port map(PC, Instruction);
	
	RF : Register_Bank port map(RF_A1, RF_A2, RF_A3, RF_D1, RF_D2, RF_D3, MEM_WB(123));
	
	
	ALU_unit: ALU port map(ALU_opcode => RR_EX(44 downto 43),
									ALU_A =>ALU_A, ALU_B => ALU_B, ALU_out => ALU_out,
									add => RR_EX(39),cpl => RR_EX(2), cz=> RR_EX(1 downto 0), 
									carry_flag => RR_EX(51), 
									zero_flag => RR_EX(50), carry_out => carry_out, zero_out => zero_out, 
									branch_inst => RR_EX(38), 
									branch_type => RR_EX(37 downto 36), branch_out => branch_out, 
									jump_in => RR_EX(35),
--									jump_out => jump_out, 
									reg_wr_cz => reg_wr_cz);
									
	Control_Unit : Controller port map(IF_ID(15 downto 12), pc_next, 
									regC_wr, regA_wr, regB_wr, regA_rd, regB_rd,
									RF_A3_select, RF_D3_select, ALU_opcode , ALU_A_select, ALU_B_select,
									add, branch_inst,  branch_type, jump, jump_type, reg_wb, mem_rd , mem_wr);
	
	Data_Memory : RAM port map(Mem_rd => EX_MEM(33), Mem_wr => EX_MEM(32), 
										Address => EX_MEM(106 downto 91), 
										Data_in => EX_MEM(74 downto 59), 
										Data_out => Data_out); --from EX_MEM
										
	Hazard_unit : Hazard_Detection port map
				(regC_wr => RR_EX(58),
				regA_wr => RR_EX(56),
				regB_wr => RR_EX(57),
				regA_rd => ID_RR(54),	--incoming 
				regB_rd => ID_RR(55),	-- instruction
				IF_ID => ID_RR(15 downto 0),
				ID_RR => RR_EX(15 downto 0),
				hazard_type => hazard_type,
				hazard_detect => hazard_detect);
				
	-- Data Dependency of length 2
	Hazard_2_dependency : Hazard_Detection port map
				(regC_wr => EX_MEM(58),
				regA_wr => EX_MEM(56),
				regB_wr => EX_MEM(57),
				regA_rd => ID_RR(54),
				regB_rd => ID_RR(55),
				IF_ID => ID_RR(15 downto 0),
				ID_RR => EX_MEM(15 downto 0),
				hazard_type => hazard_type_2,
				hazard_detect => hazard_detect_2);
	
	STALL_process : process(stall, clock, hazard_detect, RR_EX)
	begin
		if(stall = '1' and clock = '0') then
			stall <= '0';
		else
			stall <= hazard_detect and RR_EX(33);	--hazard in load instruction
		end if;
	end process;
	
	stall_2 <= hazard_detect_2 and EX_MEM(33);
	
	JUMP_Process : process(RR_EX, clock)
	begin
		if(jump_out = '1' and clock = '0') then
			jump_out <= '0';
		else
			jump_out <= RR_EX(35);
		end if;
	end process;
	
--	with ID_RR(42) select 
	RF_A1 <= ID_RR(11 downto 9) ;
							
	RF_A2 <= ID_RR(8 downto 6);
	
	with MEM_WB(48 downto 47) select RF_A3<=
							MEM_WB(5 downto 3) when "00",
							MEM_WB(8 downto 6) when "01",
							MEM_WB(11 downto 9) when others;
							
	with MEM_WB(46 downto 45) select RF_D3 <=
							MEM_WB(106 downto 91) when "00", 	-- ALU_out
							MEM_WB(122 downto 107) when "01",	--Data_out
							Imm_SE_9_wr when "10", 					--Immediate
							MEM_WB(31 downto 16) +2 when others;--PC +2
	
	Imm_SE_9_wr <= "0000000" & MEM_WB(8 downto 0);
	--ALU_A--
	with RR_EX(42) & RR_EX(41 downto 40) select ALU_A<=
							RR_EX( 90 downto 75) when "101",	--read from RR_EX register RF_D2
							"0000000000000010" when "010",	--JAL, JLR
							RR_EX( 74 downto 59) when others;	--RF_D1

	--ALU_B--
	with RR_EX(41 downto 40) select ALU_B<=
							Imm_SE_6 when "01",
							Imm_SE_9 when "11",
							RR_EX(31 downto 16) when "10",	--PC
							RR_EX(90 downto 75) when others;	--RF_D2
	
	--PC select-- to be modified
	PC_next_select: process(clock, RR_EX(35), branch_out, stall) begin	--jump
		if(clock = '1' and clock'event) then
			if(stall = '0') then
				case	RR_EX(49) is	--pc_next
					when '0' => 
						PC <= PC + '1';
					when others =>
						if(RR_EX(35) = '1') then	--jump
							if(RR_EX(53 downto 52) = "00") then 
								PC <= RR_EX(31 downto 16) + Imm_SE_6 + Imm_SE_6;
							elsif(RR_EX(53 downto 52) = "01") then
								PC <= RR_EX(90 downto 75);
							else 
								PC <= RR_EX(74 downto 59)+ Imm_SE_9 + Imm_SE_9;
							end if;
						elsif(RR_EX(38) = '1' and branch_out = '1') then 
							PC <= RR_EX(31 downto 16) + Imm_SE_6 + Imm_SE_6;
						else	
							PC <= PC + '1';
						end if;
				end case;
			end if;
		end if;
	end process;
	
	
	Imm_SE_6 <= "0000000000" & RR_EX(5 downto 0);
	Imm_SE_9 <= "0000000" & RR_EX(8 downto 0);
--	
	update_Flags: process(clock)
	begin
		if(clock = '1' and clock'event) then
			carry_flag <= carry_out; 
			zero_flag <= zero_out;
		end if;
	end process;
	
	---Instruction Fetch---
	IF_ID_reg: process(clock, stall)
	begin
		if( clock = '1' and clock'event) then
			if (stall = '0') then
				if (RR_EX(35) = '1' or branch_out = '1') then
					IF_ID(31 downto 0) <= (others => '0');
				else
					IF_ID(31 downto 16) <= PC;
					IF_ID(15 downto 0) <= Instruction;
				end if;
			end if;
		end if;
	end process;
	
	---Instruction Decode----
	ID_RR_reg: process(clock, stall)
	begin
		if( clock = '1' and clock'event) then
			if(stall = '0') then
				if (RR_EX(35) = '1' or branch_out = '1') then
					ID_RR(58 downto 0) <= (others => '0');
				else
	--			regC_wr, regA_wr, regB_wr, regA_rd, regB_rd
					ID_RR(58) <= regC_wr;
					ID_RR(57) <= regB_wr;
					ID_RR(56) <= regA_wr;
					ID_RR(55) <= regB_rd;
					ID_RR(54) <= regA_rd;
					ID_RR(53 downto 52) <= jump_type;
					ID_RR(51) <= carry_flag;
					ID_RR(50) <= zero_flag;
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
			end if;
		end if;	
	end process;
	
	---Register Read---
	RR_EX_reg: process(clock, hazard_detect, hazard_type, jump_out,branch_out, stall)
	begin
		if( clock = '1' and clock'event) then
			if (jump_out = '1' or branch_out = '1') then
				RR_EX(90 downto 75) <= (others => '0');
			else
				if(hazard_detect = '1') then
					if(hazard_type(0) = '1') then
						if(stall = '1') then
							RR_EX(74 downto 59) <= Data_out;
						else
							RR_EX(74 downto 59) <= ALU_out;
						end if;
					else
						RR_EX(74 downto 59) <= RF_D1;
					end if;
					
					if(hazard_type(1) = '1') then
						if(stall = '1') then
							RR_EX(90 downto 75) <= Data_out;
						else
							RR_EX(90 downto 75) <= ALU_out;
						end if;
					else
						RR_EX(90 downto 75) <= RF_D2;	--RF_D2
					end if;
				elsif(hazard_detect_2 = '1') then
					if(hazard_type_2(0) = '1') then
						if(stall_2 = '1') then
							RR_EX(74 downto 59) <= Data_out;
						else
							RR_EX(74 downto 59) <= EX_MEM(106 downto 91);
						end if;
					else
						RR_EX(74 downto 59) <= RF_D1;
					end if;
					
					if(hazard_type_2(1) = '1') then
						if(stall_2 = '1') then
							RR_EX(90 downto 75) <= Data_out;
						else
							RR_EX(90 downto 75) <= EX_MEM(106 downto 91);
						end if;
					else
						RR_EX(90 downto 75) <= RF_D2;	--RF_D2
					end if;
				else
					RR_EX(90 downto 75) <= RF_D2;
					RR_EX(74 downto 59) <= RF_D1;
				end if;
			--control signals
				RR_EX(58 downto 32) <= ID_RR(58 downto 32);
				RR_EX(31 downto 16) <= ID_RR(31 downto 16);	--PC
				RR_EX(15 downto 0) <= ID_RR(15 downto 0);		--Instruction
			end if;
		end if;	
	end process;
	
	---Execute---
	EX_MEM_reg: process(clock)
	begin
		if( clock = '1' and clock'event) then
			EX_MEM(106 downto 91) <= ALU_out;
			EX_MEM(90 downto 75) <= RR_EX(90 downto 75);	--RF_D2
			EX_MEM(74 downto 59) <= RR_EX(74 downto 59);	--RF_D1
		--control signals
			EX_MEM(58 downto 32) <= RR_EX(58 downto 32);
			EX_MEM(31 downto 16) <= RR_EX(31 downto 16);	--PC
			EX_MEM(15 downto 0) <= RR_EX(15 downto 0);		--Instruction
		end if;	
	end process;
	
	---Memory----
	MEM_WB_reg: process(clock)
	begin
		if( clock = '1' and clock'event) then
			MEM_WB(123) <= (reg_wr_cz or (EX_MEM(48) or EX_MEM(47))) and EX_MEM(34);
			MEM_WB(122 downto 107) <= Data_out;		--RF_D3
			MEM_WB(106 downto 91) <= EX_MEM(106 downto 91);	--ALU_out
			MEM_WB(90 downto 75) <= EX_MEM(90 downto 75);	--RF_D2
			MEM_WB(74 downto 59) <= EX_MEM(74 downto 59);	--RF_D1
		--control signals
			MEM_WB(58 downto 32) <= EX_MEM(58 downto 32);
			MEM_WB(31 downto 16) <= EX_MEM(31 downto 16);	--PC
			MEM_WB(15 downto 0) <= EX_MEM(15 downto 0);		--Instruction
		end if;	
	end process;
	
--	o_PC <= PC;
--	o_Instruction <= Instruction;
--	o_ALU_A <= ALU_A;
--	o_ALU_B <= ALU_B;
--	o_ALU_out <= EX_MEM(99 downto 84);
--	o_RF_A1 <= RF_A1;
--	o_RF_A2 <= RF_A2;
--	o_RF_D1 <= RF_D1;
--	o_RF_D2 <= RF_D2;
--	o_R0 <= RB(0);
--	o_R1 <= RB(1);
--	o_R2 <= RB(2);
--	o_R3 <= RB(3);
--	o_R4 <= RB(4);
--	o_R5 <= RB(5);
--	o_R6 <= RB(6);
--	o_R7 <= RB(7);
	
	
end pipeline_design;