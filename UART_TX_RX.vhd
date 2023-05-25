
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity Adder_IEEE_754 is

	port 
	(
	clk, rx, reset, start_tx: in STD_LOGIC;
	tx, end_rx, end_tx:out std_logic
	);


end Adder_IEEE_754;

architecture Behavioral of Adder_IEEE_754 is
	

component clock_generator is
	port(
	clock_in: in std_logic;
	clock_out: out std_logic);
end component;

component IEEE754_PROD is
    Port ( x : in  STD_LOGIC_VECTOR (31 downto 0);
           y : in  STD_LOGIC_VECTOR (31 downto 0);
           z : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

	
	
type state is (ready,b0,b1,b2,b3,b4,b5,b6,b7,b8);   ----fsm PARA RECEPCION
signal ps_rx, ps_tx : state := ready;
signal store : std_logic_vector(7 downto 0);  ----REGISTRO DE ALMACENAMIENTO
signal s_baudclock: std_logic;
signal count_byte_rx: std_logic_vector(3 downto 0);
signal count_byte_tx: std_logic_vector(2 downto 0);

signal data_tx, producto: std_logic_vector(31 downto 0);
signal data_rx: std_logic_vector(63 downto 0);

begin

BAUDRATE: clock_generator
port map(clock_in=>clk, clock_out=>s_baudclock);

MULTIPLIER:IEEE754_PROD
port map(data_rx(63 downto 32),data_rx(31 downto 0), producto);


--rx process
	
	process(s_baudclock, reset)
	begin
	if reset='1' then
		ps_rx<=ready;
		data_rx<=(others=>'0');
		count_byte_rx <= "0000";
	elsif s_baudclock'event and s_baudclock = '1' then
		if ps_rx = ready then     
			if rx = '0' then
				if count_byte_rx<8 then
					ps_rx <= b0;
				else
					ps_rx <= ready;
				end if;
			else
				ps_rx <= ready;
			end if;
		end if;
		------------------------------------------1
		if ps_rx = b0 then
			store(7) <= rx;        -----
			ps_rx <= b1;
		end if;
	------------------------------------------2
		if ps_rx = b1 then
			store(6) <= rx;        -----
			ps_rx <= b2;
		end if;
	-----------------------------------------3
		if ps_rx = b2 then
			store(5) <= rx;        -----
			ps_rx <= b3;
		end if;
	----------------------------------------4
		if ps_rx = b3 then
			store(4) <= rx;        -----
			ps_rx <= b4;
		end if;
	---------------------------------------5
		if ps_rx = b4 then
			store(3) <= rx;        -----
			ps_rx <= b5;
		end if;
	---------------------------------------6
		if ps_rx = b5 then
			store(2) <= rx;        -----
			ps_rx <= b6;
		end if;
	---------------------------------------7
		if ps_rx = b6 then
			store(1) <= rx;        -----
			ps_rx <= b7;
		end if;	
	--------------------------------------8
		if ps_rx = b7 then
			store(0) <= rx;        -----
			count_byte_rx <= count_byte_rx + 1;
			data_rx <= data_rx(55 downto 0) & store;
			ps_rx <= ready;
			
		end if;
	--------------------------------------9

	end if;

	end process;
		
	end_rx <= 
		'1' when count_byte_rx = 8 else
		'0';

--tx process

	process(s_baudclock, reset)
	begin
	if reset='1' then
	   tx<='1';
		ps_tx<=ready;
		count_byte_tx <= "000";	
	elsif s_baudclock'event and s_baudclock = '1' then
		if ps_tx = ready then  
			if start_tx='1' then
				if count_byte_tx<4 then
					tx<='0';
					if count_byte_tx=0 then
						data_tx <= producto;
					end if;
					ps_tx <= b0;
				else
					tx<='1';
					ps_tx <= ready;
				end if;
			else
				tx<='1';
				ps_tx <= ready;
			end if;
		end if;
	------------------------------------------1
		if ps_tx = b0 then
			tx <=data_tx(31);
			ps_tx <= b1;
		end if;
	------------------------------------------2
		if ps_tx = b1 then
			tx <=data_tx(30);
			ps_tx <= b2;
		end if;
	-----------------------------------------3
		if ps_tx = b2 then
			tx <=data_tx(29);
			ps_tx <= b3;
		end if;
	----------------------------------------4
		if ps_tx = b3 then
			tx <=data_tx(28);
			ps_tx <= b4;
		end if;
	---------------------------------------5
		if ps_tx = b4 then
			tx <=data_tx(27);
			ps_tx <= b5;
		end if;
	---------------------------------------6
		if ps_tx = b5 then
			tx <=data_tx(26);
			ps_tx <= b6;
		end if;
	---------------------------------------7
		if ps_tx = b6 then
			tx <=data_tx(25);
			ps_tx <= b7;
		end if;	
	--------------------------------------8
		if ps_tx = b7 then
			tx <=data_tx(24);
			ps_tx <= b8;
		end if;
	--------------------------------------9
		if ps_tx = b8 then
			tx <= '1';
			data_tx <= data_tx(23 downto 0) & "00000000";
			count_byte_tx <= count_byte_tx + 1;
			ps_tx <= ready;				

		end if;

	-------------------------------------1
	end if;

	end process;

	end_tx <= 
		'1' when count_byte_tx = 4 else
		'0';

	
end Behavioral;

