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
	
--	component Register_Bank is
--		port(	RF_A1 : in std_logic_vector(2 downto 0);
--				RF_A2: in std_logic_vector(2 downto 0);
--				RF_A3: in std_logic_vector(2 downto 0);
--				RF_D1: out std_logic_vector(15 downto 0);
--				RF_D2: out std_logic_vector(15 downto 0);
--				RF_D3: in std_logic_vector(15 downto 0);
--				reg_wb: in std_logic);
--	end component Register_Bank;
	
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
			reg_wr_cz : out std_logic
			);
	end component ALU;
	
--	component RAM is
--		port(Mem_rd : in std_logic;
--				Mem_wr : in std_logic;
--				Address: in std_logic_vector(15 downto 0);
--				Data_in : in std_logic_vector(15 downto 0);
--				Data_out: out std_logic_vector(15 downto 0));
--	end component RAM;
--	
	--RF
	type Reg_array is array(0 to 7) of std_logic_vector(15 downto 0);
	signal RB: Reg_array:= (others=>"0000000000000000");
	
	type RAM_array is array (0 to (2**8)) of std_logic_vector(15 downto 0) ;
		signal RAM : RAM_array :=(others=> (others=>'0') );
	
	signal PC, Instruction: std_logic_vector(15 downto 0):= (others=>'0');
	signal pc_next : std_logic :='0';
	
	signal RF_A1, RF_A2, RF_A3 : std_logic_vector(2 downto 0):= (others=>'0');
	signal RF_D1, RF_D2, RF_D3 : std_logic_vector(15 downto 0):= (others=>'0');
	signal reg_wb : std_logic :='0';
	
	signal RF_A3_select, RF_D3_select : std_logic_vector(1 downto 0):= (others=>'0');
	
	signal ALU_A, ALU_B, ALU_out : std_logic_vector(15 downto 0) :=(others=>'0'); 
	signal ALU_opcode, ALU_B_select  : std_logic_vector(1 downto 0):= (others=>'0');
   signal ALU_A_select : std_logic := '0';             

	signal add, carry_flag, zero_flag : std_logic :='0';
	signal carry_out, zero_out : std_logic := '0';
	signal branch_inst, branch_out : std_logic:='0' ;
	signal branch_type, jump_type : std_logic_vector(1 downto 0) := (others=>'0');
	
	signal Imm_SE_6, Imm_SE_9, Imm_SE_9_wr : std_logic_vector(15 downto 0) := (others=>'0');
	
	signal branch, jump, reg_wr_cz: std_logic := '0';
	signal Data_in, Data_out : std_logic_vector(15 downto 0) := (others=>'0');
	
	signal mem_rd, mem_wr : std_logic:= '0';
	
	signal IF_ID : std_logic_vector(31 downto 0):= (others=>'0');
	signal ID_RR : std_logic_vector(51 downto 0):= (others=>'0');
	signal RR_EX : std_logic_vector(83 downto 0):= (others=>'0');
	signal EX_MEM : std_logic_vector(99 downto 0):= (others=>'0');
	signal MEM_WB : std_logic_vector(116 downto 0):= (others=>'0');
	
begin
	
	Code_Mem: ROM port map(PC, Instruction);
--	RF : Register_Bank port map(RF_A1, RF_A2, RF_A3, RF_D1, RF_D2, RF_D3, MEM_WB(116));
	
		RF_D1 <= RB(to_integer(unsigned(RF_A1)));
		RF_D2 <= RB(to_integer(unsigned(RF_A2)));
		
		process(clock, RF_D3, RF_A3, RB, MEM_WB) 
		begin
		if(MEM_WB(116) = '1') then
			RB(to_integer(unsigned(RF_A3))) <= RF_D3;
		end if;
		end process;
		
		process(clock, EX_MEM, RAM, Data_out) begin
			if(EX_MEM(33) = '1') then
				Data_out <= RAM(to_integer(unsigned(EX_MEM(99 downto 84))));
			
			elsif(EX_MEM(32) = '1') then
				RAM(to_integer(unsigned(EX_MEM(99 downto 84)))) <= EX_MEM(67 downto 52);
			end if;
		end process;
	
	
	ALU_unit: ALU port map(ALU_opcode => RR_EX(44 downto 43),
									ALU_A =>ALU_A, ALU_B => ALU_B, ALU_out => ALU_out,
									add => RR_EX(39),cpl => RR_EX(2), cz=> RR_EX(1 downto 0), 
									carry_flag => RR_EX(51), 
									zero_flag => RR_EX(50), carry_out => carry_out, zero_out => zero_out, 
									branch_inst => RR_EX(38), 
									branch_type => RR_EX(37 downto 36), branch_out => branch_out, 
									reg_wr_cz => reg_wr_cz);
									
	Control_Unit: Controller port map(IF_ID(15 downto 12), pc_next,
                RF_A3_select, RF_D3_select, ALU_opcode , ALU_A_select, ALU_B_select, add,
                branch_inst,  branch_type, jump, jump_type, reg_wb, mem_rd , mem_wr);
	
--	Data_Memory : RAM port map(Mem_rd => EX_MEM(33), Mem_wr => EX_MEM(32), 
--										Address => EX_MEM(99 downto 84), 
--										Data_in => EX_MEM(67 downto 52), 
--										Data_out => Data_out); --from EX_MEM
	
--	with ID_RR(42) select 
	RF_A1 <= ID_RR(11 downto 9) ;
--							when '1',	--load, store
--							ID_RR(11 downto 9) when others;
							
	RF_A2 <= ID_RR(8 downto 6);
	
	with MEM_WB(48 downto 47) select RF_A3<=
							MEM_WB(5 downto 3) when "00",
							MEM_WB(8 downto 6) when "01",
							MEM_WB(11 downto 9) when others;
							
	with MEM_WB(46 downto 45) select RF_D3 <=
							MEM_WB(99 downto 84) when "00", -- ALU_out
							MEM_WB(115 downto 100) when "01",	--Data_out
							Imm_SE_9_wr when "10", 	--Immediate
							MEM_WB(31 downto 16) +2 when others;	--PC +2
	
	Imm_SE_9_wr <= "0000000" & MEM_WB(8 downto 0);
	--ALU_A--
	with RR_EX(42) select ALU_A<=
							RR_EX( 83 downto 68) when '1',	--read from RR_EX register RF_D2
							RR_EX( 67 downto 52) when others;	--RF_D1

	--ALU_B--
	with RR_EX(41 downto 40) select ALU_B<=
							Imm_SE_6 when "01",
							Imm_SE_9 when "11",
							RR_EX( 83 downto 68) when others;	--RF_D2
	
	--PC select-- to be modified
	PC_next_select: process(clock, RR_EX(35), branch_out) begin	--jump
		if(clock = '1' and clock'event) then
			case	RR_EX(49) is	--pc_next
				when '0' => PC <= PC + '1';
				when others =>
					if(RR_EX(35) = '1') then	--jump
						if(jump_type = "00") then 		PC <= RR_EX(31 downto 16) + Imm_SE_6 + Imm_SE_6;
						elsif(jump_type = "01") then 	PC <= RR_EX(83 downto 68);
						else 									PC <= RR_EX(67 downto 52)+ Imm_SE_9 + Imm_SE_9;
						end if;
					elsif(branch_out = '1') then 		PC <= RR_EX(31 downto 16) + Imm_SE_6 + Imm_SE_6;
					else 										PC <= PC + '1';
					end if;
			end case;
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
	end process;
	
	---Register Read---
	RR_EX_reg: process(clock)
	begin
		if( clock = '1' and clock'event) then
			RR_EX(83 downto 68) <= RF_D2;
			RR_EX(67 downto 52) <= RF_D1;
		--control signals
			RR_EX(51 downto 32) <= ID_RR(51 downto 32);
			RR_EX(31 downto 16) <= ID_RR(31 downto 16);	--PC
			RR_EX(15 downto 0) <= ID_RR(15 downto 0);		--Instruction
		end if;	
	end process;
	
	---Execute---
	EX_MEM_reg: process(clock)
	begin
		if( clock = '1' and clock'event) then
			EX_MEM(99 downto 84) <= ALU_out;
			EX_MEM(83 downto 68) <= RR_EX(83 downto 68);	--RF_D2
			EX_MEM(67 downto 52) <= RR_EX(67 downto 52);	--RF_D1
		--control signals
			EX_MEM(51 downto 32) <= RR_EX(51 downto 32);
			EX_MEM(31 downto 16) <= RR_EX(31 downto 16);	--PC
			EX_MEM(15 downto 0) <= RR_EX(15 downto 0);		--Instruction
		end if;	
	end process;
	
	---Memory----
	MEM_WB_reg: process(clock)
	begin
		if( clock = '1' and clock'event) then
			MEM_WB(116) <= (reg_wr_cz or (EX_MEM(48) or EX_MEM(47))) and EX_MEM(34);
			MEM_WB(115 downto 100) <= Data_out;		--RF_D3
			MEM_WB(99 downto 84) <= EX_MEM(99 downto 84);	--ALU_out
			MEM_WB(83 downto 68) <= EX_MEM(83 downto 68);	--RF_D2
			MEM_WB(67 downto 52) <= EX_MEM(67 downto 52);	--RF_D1
		--control signals
			MEM_WB(51 downto 32) <= EX_MEM(51 downto 32);
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