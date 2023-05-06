library ieee;
use ieee.std_logic_1164.all;

entity Hazard_Detection is
	port(regC_wr : in std_logic;	
			regA_wr : in std_logic;
			regB_wr : in std_logic;
			regA_rd : in std_logic;	--incoming inst
			regB_rd : in std_logic;	--incoming inst
			IF_ID : in std_logic_vector(15 downto 0);
			ID_RR : in std_logic_vector(15 downto 0);
			hazard_type : out std_logic_vector(1 downto 0);
			hazard_detect : out std_logic);
end entity;

architecture detective of Hazard_Detection is
	signal hzd_type : std_logic_vector(1 downto 0):= (others => '0');
begin
	process(regC_wr, regA_wr, regB_wr, regA_rd, regB_rd, hzd_type, IF_ID, ID_RR)
	begin
		if(regC_wr = '1') then
			if(regA_rd = '1' or regB_rd = '1') then
				if(regA_rd = '1' and IF_ID(11 downto 9) = ID_RR(5 downto 3)) then
					hzd_type(0) <= '1';
				else
					hzd_type(0) <= '0';
				end if;
				
				if(regB_rd = '1' and IF_ID(8 downto 6) = ID_RR(5 downto 3)) then
					hzd_type(1) <= '1';
				else
					hzd_type(1) <= '0';
				end if;
			else
				hzd_type <= "00";
			end if;
		elsif(regA_wr = '1') then
			if(regA_rd = '1' or regB_rd = '1') then
				if(regA_rd = '1' and IF_ID(11 downto 9) = ID_RR(11 downto 9)) then
					hzd_type(0) <= '1';
				else
					hzd_type(0) <= '0';
				end if;
				
				if(regB_rd = '1' and IF_ID(8 downto 6) = ID_RR(11 downto 9)) then
					hzd_type(1) <= '1';
				else
					hzd_type(1) <= '0';
				end if;
			else
				hzd_type <= "00";
			end if;
		elsif(regB_wr = '1') then
			if(regA_rd = '1' or regB_rd = '1') then
				if(regA_rd = '1' and IF_ID(11 downto 9) = ID_RR(8 downto 6)) then
					hzd_type(0) <= '1';
				else
					hzd_type(0) <= '0';
				end if;
				
				if(regB_rd = '1' and IF_ID(8 downto 6) = ID_RR(8 downto 6)) then
					hzd_type(1) <= '1';
				else
					hzd_type(1) <= '0';
				end if;
			else
				hzd_type <= "00";
			end if;
		else
			hzd_type <= "00";
		end if;
	end process;
	hazard_detect <= hzd_type(0) or hzd_type(1);
	hazard_type <= hzd_type;
end detective;