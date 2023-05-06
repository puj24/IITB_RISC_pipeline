library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

entity ALU is
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
end entity;

architecture ALU_design of ALU is 
	signal cpl_B, result : std_logic_vector(15 downto 0) := (others => '0');
	signal carry : std_logic;
	signal rf_wr : std_logic;
	signal branch, jump : std_logic;
begin
	process(ALU_opcode, zero_flag, carry_flag, cpl, cz, ALU_A, ALU_B, cpl_B, branch_inst, branch_type, jump_in, result)
	begin
		case ALU_opcode is
			when "00" =>
				if(cpl = '1') then
					cpl_B <= "1111111111111111" xor (ALU_B);
					result <= ALU_A + (not(ALU_B));
				else
					result <= ALU_A + ALU_B;
					cpl_B <= ALU_B;
				end if;
				
--				result <= ALU_A + cpl_B;		--  cout =  ~s(a+b)+ ab
				carry <= (not(result(15)) and (ALU_A(15) or cpl_B(15))) or (ALU_A(15) and cpl_B(15));
				
				if(cz = "01") then
					rf_wr <= zero_flag;
				elsif(cz = "10") then
					rf_wr <= carry_flag;
				else 
					rf_wr <= '1';
				end if;
				
				if(cz = "11") then
					result <= result + carry_flag;
				end if;
				branch <= '0';
				jump <= '0';
				
			when "01" =>
				if(cpl = '1') then
					result <= ALU_A nand (not(ALU_B));
				else
					result <= ALU_A nand ALU_B;
				end if;
				
				if(cz = "01") then
					rf_wr <= zero_flag;
				elsif(cz = "10") then
					rf_wr <= carry_flag;
				else 
					rf_wr <= '1';
				end if;
				branch <= '0';
				jump <= '0';
				
			when "10" =>	--load store
				result <= ALU_A + ALU_B;
				rf_wr <= '1';
				branch <= '0';
				if(jump_in = '1') then
					jump <= '1';
				else
					jump <= '0';
				end if;
				
			when others =>
				if(branch_inst ='1') then
					case branch_type is
						when "00" =>
							if(ALU_A = ALU_B) then
								branch <= '1';
							else
								branch <= '0';
							end if;
						when "01" =>
							if(ALU_A < ALU_B) then
								branch <= '1';
							else
								branch <= '0';
							end if;
						when others =>
							if(ALU_A <= ALU_B) then
								branch <= '1';
							else
								branch <= '0';
							end if;
					end case;
					rf_wr <= '0';
					jump <= '0';
					result <= "0000000000000000";
				else
					if(jump_in = '1') then
						jump <= '1';
					else
						jump <= '0';
					end if;
					branch <= '0';
					rf_wr <= '0';
					result <= "0000000000000000";
					carry <= carry_flag;
				end if;				
		end case;
	end  process;
	process(result)
	begin
		if(result = "0000000000000000") then
			zero_out <= '1';
		else
			zero_out <= '0';
		end if;
	end process;
	
	carry_out <= add and carry;
	branch_out <= branch;
--	jump_out <= jump;
	reg_wr_cz <= rf_wr;
	ALU_out <= result;
	
end ALU_design;