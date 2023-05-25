library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity clock_generator is
port(
clock_in: in std_logic;
clock_out: out std_logic);
end clock_generator;

architecture Behavioral of clock_generator is
signal counter: std_logic_vector(12 downto 0);--5209, 2604
signal clock_signal: std_logic;
begin
process(clock_in)
begin
	if clock_in'event and clock_in = '1' then
		if counter = 5209 - 1 then
			counter <= (others=>'0');
			clock_signal <= '0';
		else
			counter <= counter + 1;	
			if counter = 2604 then			
				clock_signal <= '1';
			end if;
		end if;
	end if;
end process;

clock_out <= clock_signal;
end Behavioral;