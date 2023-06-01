library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
entity Adder_IEEE_754 is

	port 
	(
	clk, rx, reset, start_tx: in STD_LOGIC;
	tx, end_rx, end_tx:out std_logic;
	z : out std_logic_vector(31 downto 0));

end Adder_IEEE_754;
architecture Behavioral of Adder_IEEE_754 is
	
component clock_generator is
	port(
	clock_in: in std_logic;
	clock_out: out std_logic);
end component;
	
	
type state is (ready,b0,b1,b2,b3,b4,b5,b6,b7,b8);   ----fsm PARA RECEPCION
signal ps_rx, ps_tx : state := ready;
signal store : std_logic_vector(7 downto 0);  ----REGISTRO DE ALMACENAMIENTO
signal count_byte_rx: std_logic_vector(3 downto 0);
signal count_byte_tx: std_logic_vector(3 downto 0);
signal data_tx, producto: std_logic_vector(63 downto 0);
signal data_rx: std_logic_vector(63 downto 0);
signal s_baudclock: std_logic;
signal x : std_logic_vector(31 downto 0); --:= "01001101000000000011011101010111";
signal y : std_logic_vector(31 downto 0); --:= "01000000000000000000000000000000";
signal z_signal : std_logic_vector(31 downto 0);

begin

BAUDRATE:clock_generator
port map(clk, s_baudclock);
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
			--count_byte_rx <= count_byte_rx + 1;
			--data_rx <= data_rx(55 downto 0) & store;
			ps_rx <= b8;
			
		end if;
		
		if ps_rx = b8 then
			count_byte_rx <= count_byte_rx + 1;
			data_rx <= data_rx(55 downto 0) & store;
			ps_rx <= ready;
			
		end if;
		
		if count_byte_rx = 8 then
				x <= data_rx(63 downto 32);
				y <= data_rx(31 downto 0);
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
		count_byte_tx <= "0000";	
	elsif s_baudclock'event and s_baudclock = '1' then
		if ps_tx = ready then  
			if start_tx='1' then
				if count_byte_tx<8 then
					tx<='0';
					if count_byte_tx=0 then
						-- data_tx <= producto; -- No funciona
						-- data_tx <= data_rx(63 downto 32); -- Funciona
						--data_tx <= data_rx(31 downto 0); -- Funciona
						data_tx(63 downto 32) <= x(31 downto 0);
						data_tx(31 downto 0) <= y(31 downto 0);
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
			tx <=data_tx(63);
			ps_tx <= b1;
		end if;
	------------------------------------------2
		if ps_tx = b1 then
			tx <=data_tx(62);
			ps_tx <= b2;
		end if;
	-----------------------------------------3
		if ps_tx = b2 then
			tx <=data_tx(61);
			ps_tx <= b3;
		end if;
	----------------------------------------4
		if ps_tx = b3 then
			tx <=data_tx(60);
			ps_tx <= b4;
		end if;
	---------------------------------------5
		if ps_tx = b4 then
			tx <=data_tx(59);
			ps_tx <= b5;
		end if;
	---------------------------------------6
		if ps_tx = b5 then
			tx <=data_tx(58);
			ps_tx <= b6;
		end if;
	---------------------------------------7
		if ps_tx = b6 then
			tx <=data_tx(57);
			ps_tx <= b7;
		end if;	
	--------------------------------------8
		if ps_tx = b7 then
			tx <=data_tx(56);
			ps_tx <= b8;
		end if;
	--------------------------------------9
		if ps_tx = b8 then
			tx <= '1';
			data_tx <= data_tx(55 downto 0) & "00000000";
			count_byte_tx <= count_byte_tx + 1;
			ps_tx <= ready;				

		end if;
		

	-------------------------------------1
	end if;
	end process;
	end_tx <= 
		'1' when count_byte_tx = 8 else
		'0';
	-----------------------------------------------------------------

--x <= "01000100010001000011001100110011";
--y <= "01000100010001000011001100110011";
process(x,y)
    variable x_mantissa : STD_LOGIC_VECTOR (22 downto 0);
    variable x_exponent : STD_LOGIC_VECTOR (7 downto 0);
    variable x_sign : STD_LOGIC;
    variable y_mantissa : STD_LOGIC_VECTOR (22 downto 0);
    variable y_exponent : STD_LOGIC_VECTOR (7 downto 0);
    variable y_sign : STD_LOGIC;
    variable z_mantissa : STD_LOGIC_VECTOR (22 downto 0);
    variable z_exponent : STD_LOGIC_VECTOR (7 downto 0);
    variable z_sign : STD_LOGIC;
    variable aux : STD_LOGIC;
    variable aux2 : STD_LOGIC_VECTOR (47 downto 0);
    variable exponent_sum : STD_LOGIC_VECTOR (8 downto 0);
begin
    x_mantissa := x(22 downto 0);
    x_exponent := x(30 downto 23);
    x_sign := x(31);
    y_mantissa := y(22 downto 0);
    y_exponent := y(30 downto 23);
    y_sign := y(31);
    -- inf*0 is not tested (result would be NaN)
    if (x_exponent=255 or y_exponent=255) then 
        -- inf*x or x*inf
        z_exponent := "11111111";
        z_mantissa := (others => '0');
        z_sign := x_sign xor y_sign;
    elsif (x_exponent=0 or y_exponent=0) then 
        -- 0*x or x*0
        z_exponent := (others => '0');
        z_mantissa := (others => '0');
        z_sign := '0';
    else
        aux2 := ('1' & x_mantissa) * ('1' & y_mantissa);
        -- args in Q23 result in Q46
        if (aux2(47)='1') then 
            -- >=2, shift left and add one to exponent
            z_mantissa := aux2(46 downto 24) + aux2(23); -- with rounding
            aux := '1';
        else
            z_mantissa := aux2(45 downto 23) + aux2(22); -- with rounding
            aux := '0';
        end if;
        -- calculate exponent
        exponent_sum := ('0' & x_exponent) + ('0' & y_exponent) + aux - 127;
        if (exponent_sum(8)='1') then 
            if (exponent_sum(7)='0') then -- overflow
                z_exponent := "11111111";
                z_mantissa := (others => '0');
                z_sign := x_sign xor y_sign;
            else  -- underflow
                z_exponent := (others => '0');
                z_mantissa := (others => '0');
                z_sign := '0';
            end if;
        else  -- Ok
            z_exponent := exponent_sum(7 downto 0);
            z_sign := x_sign xor y_sign;
        end if;
    end if;
    z(22 downto 0) <= z_mantissa;
    z(30 downto 23) <= z_exponent;
    z(31) <= z_sign;
    
    -- Resto del código del proceso
end process;
	
end Behavioral;