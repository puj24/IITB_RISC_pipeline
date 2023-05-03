library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

entity ALU is
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
end ALU;

architecture ALU_design of ALU is
	signal result : std_logic_vector(16 downto 0) := (others => '0');
	signal alu_b_cpl : std_logic_vector(15 downto 0);
	signal branch, rf_wr: std_logic := '0';
	
begin    
	process(ALU_opcode, cz, cpl, branch_inst, result) begin
        branch <= '0';
        
        if(ALU_opcode <= "01") then	--add / nand ALU_opcode
            if(cpl = '1') then
                alu_b_cpl <= not(ALU_B);
            else 
                alu_b_cpl <= ALU_B;
            end if;
            
            if(ALU_opcode = "00") then 
                result <= ALU_A + alu_b_cpl;
            else
                result <= not(ALU_A and alu_b_cpl);
            end if;
            
				if (cz = "00") then	--ADA
					rf_wr <= '1';
				elsif(cz = "01" and zero_flag = '1') then		--ADZ
                    rf_wr <= '1';
            elsif(cz = "10" and carry_flag = '1') then		--ADC			
                    rf_wr <= '1';
            elsif(cz = "11") then		--AWC
                result <= result + carry_flag;
					 rf_wr <= '1';
            end if;
            
        elsif(branch_inst = '1') then
            if((branch_type = "00") and (ALU_A = ALU_B)) then			--BEQ
                        branch <= '1';
            elsif(branch_type = "01") then					--BLT
                    if(ALU_A < ALU_B) then
                        branch <= '1';
                    end if;
            else			--BLE
                    if(ALU_A <= ALU_B) then
                        branch <= '1';
                    end if;
            end if;
            
        elsif(ALU_opcode = "10") then	--load/ store/ adi
            result <= ALU_A + ALU_B;		
        end if;
--        
        if(ALU_opcode < "11") then	--add, nand, load, store, adi
            carry_out <= (add and result(16)) or carry_flag;
            if(result( 15 downto 0) = "00000000" & "00000000") then
                zero_out <= '1';
            else
                zero_out <= zero_flag;
            end if;	

        else
            carry_out <= carry_flag;
            zero_out <= zero_flag;
        end if;
    end process;
	
	reg_wr_cz <= rf_wr;
	ALU_out <= result( 15 downto 0);
	branch_out <= branch;
	
end ALU_design;
