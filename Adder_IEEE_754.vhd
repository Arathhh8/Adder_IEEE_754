LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;

ENTITY Adder_IEEE_754 IS

	PORT
	(
	clk, rx, reset, start_tx: IN STD_LOGIC;
	tx, end_rx, end_tx:out STD_LOGIC);
	--z : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));

END Adder_IEEE_754;
ARCHITECTURE Behavioral OF Adder_IEEE_754 IS
	
COMPONENT clock_generator IS
	PORT(
	clock_in: IN std_logic;
	clock_out: OUT std_logic);
END COMPONENT;
	
	
TYPE state IS (ready,b0,b1,b2,b3,b4,b5,b6,b7,b8);   ----FSM PARA RECEPCION
SIGNAL ps_rx, ps_tx : state := ready;
SIGNAL store : std_logic_vector(7 DOWNTO 0);  ----REGISTRO DE ALMACENAMIENTO
SIGNAL count_byte_rx: std_logic_vector(3 DOWNTO 0);
SIGNAL count_byte_tx: std_logic_vector(3 DOWNTO 0);
SIGNAL data_tx, producto: std_logic_vector(63 DOWNTO 0);
SIGNAL data_rx: std_logic_vector(63 DOWNTO 0);
SIGNAL s_baudclock: std_logic;
SIGNAL x : std_logic_vector(31 DOWNTO 0); --:= "01001101000000000011011101010111";
SIGNAL y : std_logic_vector(31 DOWNTO 0); --:= "01000000000000000000000000000000";
SIGNAL z_signal : std_logic_vector(31 DOWNTO 0);

BEGIN

BAUDRATE:clock_generator
PORT MAP(clk, s_baudclock);

--rx process
	PROCESS(s_baudclock, reset)
	BEGIN
	IF reset='1' THEN
		ps_rx<=ready;
		data_rx<=(OTHERS=>'0');
		count_byte_rx <= "0000";
	ELSIF s_baudclock'EVENT and s_baudclock = '1' THEN
		IF ps_rx = ready THEN     
			IF rx = '0' THEN
				IF count_byte_rx<8 THEN
					ps_rx <= b0;
				ELSE
					ps_rx <= ready;
				END IF;
			ELSE
				ps_rx <= ready;
			END IF;
		END IF;
		------------------------------------------1
		IF ps_rx = b0 THEN
			store(0) <= rx;        -----
			ps_rx <= b1;
		END IF;
	------------------------------------------2
		IF ps_rx = b1 THEN
			store(1) <= rx;        -----
			ps_rx <= b2;
		END IF;
	-----------------------------------------3
		IF ps_rx = b2 THEN
			store(2) <= rx;        -----
			ps_rx <= b3;
		END IF;
	----------------------------------------4
		IF ps_rx = b3 THEN
			store(3) <= rx;        -----
			ps_rx <= b4;
		END IF;
	---------------------------------------5
		IF ps_rx = b4 THEN
			store(4) <= rx;        -----
			ps_rx <= b5;
		END IF;
	---------------------------------------6
		IF ps_rx = b5 THEN
			store(5) <= rx;        -----
			ps_rx <= b6;
		END IF;
	---------------------------------------7
		IF ps_rx = b6 THEN
			store(6) <= rx;        -----
			ps_rx <= b7;
		END IF;	
	--------------------------------------8
		IF ps_rx = b7 THEN
			store(7) <= rx;        -----
			--count_byte_rx <= count_byte_rx + 1;
			--data_rx <= data_rx(55 downto 0) & store;
			ps_rx <= b8;
		END IF;
		
		IF ps_rx = b8 THEN
			count_byte_rx <= count_byte_rx + 1;
			data_rx <= data_rx(55 downto 0) & store;
			ps_rx <= ready;
		END IF;
		
		IF count_byte_rx = 8 THEN
			x <= data_rx(63 DOWNTO 32);
			y <= data_rx(31 DOWNTO 0);
		END IF;
	--------------------------------------9
	END IF;
	END PROCESS;
		
	end_rx <= 
		'1' WHEN count_byte_rx = 8 ELSE
		'0';
		
--tx process
	PROCESS(s_baudclock, reset)
	BEGIN
	IF reset='1' THEN
	   tx<='1';
		ps_tx<=ready;
		count_byte_tx <= "0000";	
	ELSIF s_baudclock'EVENT and s_baudclock = '1' THEN
		IF ps_tx = ready THEN  
			IF start_tx='1' THEN
				IF count_byte_tx<8 THEN
					tx<='0';
					IF count_byte_tx=0 THEN
						--data_tx <= producto; -- No funciona
						--data_tx <= data_rx(63 downto 32); -- Funciona
						--data_tx(31 downto 0) <= data_rx(31 downto 0); -- Funciona
						--data_tx(63 downto 32) <= x(31 downto 0);
						--data_tx(31 downto 0) <= y(31 downto 0);
						data_tx(63 DOWNTO 32) <= z_signal;
					END IF;
					ps_tx <= b0;
				ELSE
					tx<='1';
					ps_tx <= ready;
				END IF;
			ELSE
				tx<='1';
				ps_tx <= ready;
			END IF;
		END IF;
	------------------------------------------1
		IF ps_tx = b0 THEN
			tx <=data_tx(56);
			ps_tx <= b1;
		END IF;
	------------------------------------------2
		IF ps_tx = b1 THEN
			tx <=data_tx(57);
			ps_tx <= b2;
		END IF;
	-----------------------------------------3
		IF ps_tx = b2 THEN
			tx <=data_tx(58);
			ps_tx <= b3;
		END IF;
	----------------------------------------4
		IF ps_tx = b3 THEN
			tx <=data_tx(59);
			ps_tx <= b4;
		END IF;
	---------------------------------------5
		IF ps_tx = b4 THEN
			tx <=data_tx(60);
			ps_tx <= b5;
		END IF;
	---------------------------------------6
		IF ps_tx = b5 THEN
			tx <=data_tx(61);
			ps_tx <= b6;
		END IF;
	---------------------------------------7
		IF ps_tx = b6 THEN
			tx <=data_tx(62);
			ps_tx <= b7;
		END IF;	
	--------------------------------------8
		IF ps_tx = b7 THEN
			tx <=data_tx(63);
			ps_tx <= b8;
		END IF;
	--------------------------------------9
		IF ps_tx = b8 THEN
			tx <= '1';
			data_tx <= data_tx(55 DOWNTO 0) & "00000000";
			count_byte_tx <= count_byte_tx + 1;
			ps_tx <= ready;				
		END IF;
		
	-------------------------------------1
	END IF;
	END PROCESS;
	end_tx <= 
		'1' WHEN count_byte_tx = 8 ELSE
		'0';
	-----------------------------------------------------------------

	--x <= "01000100010001000011001100110011";
	--y <= "01000100010001000011001100110011";
	PROCESS(x, y, clk, reset)
		 VARIABLE x_mantissa : STD_LOGIC_VECTOR (22 DOWNTO 0);
		 VARIABLE x_exponent : STD_LOGIC_VECTOR (7 DOWNTO 0);
		 VARIABLE x_sign : STD_LOGIC;
		 VARIABLE y_mantissa : STD_LOGIC_VECTOR (22 DOWNTO 0);
		 VARIABLE y_exponent : STD_LOGIC_VECTOR (7 DOWNTO 0);
		 VARIABLE y_sign : STD_LOGIC;
		 VARIABLE z_mantissa : STD_LOGIC_VECTOR (22 DOWNTO 0);
		 VARIABLE z_exponent : STD_LOGIC_VECTOR (7 DOWNTO 0);
		 VARIABLE z_sign : STD_LOGIC;
		 VARIABLE aux : STD_LOGIC;
		 VARIABLE aux2 : STD_LOGIC_VECTOR (47 DOWNTO 0);
		 VARIABLE exponent_sum : STD_LOGIC_VECTOR (8 DOWNTO 0);
	BEGIN
		 -- Asignación de componentes de "x" y "y" a variables correspondientes
		 x_mantissa := x(22 DOWNTO 0);
		 x_exponent := x(30 DOWNTO 23);
		 x_sign := x(31);
		 y_mantissa := y(22 DOWNTO 0);
		 y_exponent := y(30 DOWNTO 23);
		 y_sign := y(31);
		 
		 -- Verificación de casos especiales: infinito o NaN
		 IF(x_exponent = 0 and y_exponent = 255) THEN
			  -- inf*x o x*inf
			  z_exponent := "11111111";
			  z_mantissa := (OTHERS => '1'); -- NaN 
			  z_sign := x_sign xor y_sign;
		 ELSIF(x_exponent = 255 and y_exponent = 0) THEN
			  -- inf*x o x*inf
			  z_exponent := "11111111";
			  z_mantissa := (OTHERS => '1'); -- NaN 
			  z_sign := x_sign xor y_sign;
		 ELSIF(x_exponent = 255 or y_exponent = 255) THEN
			  -- inf*x o x*inf
			  z_exponent := "11111111";
			  z_mantissa := (OTHERS => '0'); -- Infinito
			  z_sign := x_sign xor y_sign;
		 ELSIF (x_exponent = 0 or y_exponent = 0) THEN
			  -- 0*x o x*0
			  z_exponent := (OTHERS => '0');
			  z_mantissa := (OTHERS => '0');
			  z_sign := '0';
		 ELSE
			  -- Multiplicación de mantisas
			  aux2 := ('1' & x_mantissa) * ('1' & y_mantissa);
			  -- args in Q23 result in Q46
			  IF(aux2(47) = '1') THEN 
					-- y se agrega un 1 al exponente
					z_mantissa := aux2(46 DOWNTO 24); -- + aux2(23); -- con redondeo
					aux := '1';
			  ELSE
					z_mantissa := aux2(45 DOWNTO 23); --+ aux2(22); -- con redondeo
					aux := '0';
			  END IF;
			  
			  -- Cálculo del exponente
			  exponent_sum := ('0' & x_exponent) + ('0' & y_exponent) + aux - 127;
			  IF (exponent_sum(8) = '1') THEN 
					IF (exponent_sum(7) = '0') THEN -- Desbordamiento
						 z_exponent := "11111111";
						 z_mantissa := (OTHERS => '0');
						 z_sign := x_sign xor y_sign;
					ELSE  -- Subdesbordamiento
						 z_exponent := (OTHERS => '0');
						 z_mantissa := (OTHERS => '0');
						 z_sign := '0';
					END IF;
			  ELSE  -- Resultado válido
					z_exponent := exponent_sum(7 DOWNTO 0);
					z_sign := x_sign xor y_sign;
			  END IF;
		 END IF;

		 -- Asignación de los componentes del resultado a z (vista en leds) 
		 --z(22 DOWNTO 0) <= z_mantissa;
		 --z(30 DOWNTO 23) <= z_exponent;
		 --z(31) <= z_sign;
		 
		 -- Asignación de los componentes del resultado a la señal z_signal (dato a transmitir)
		 z_signal(22 DOWNTO 0) <= z_mantissa;
		 z_signal(30 DOWNTO 23) <= z_exponent;
		 z_signal(31) <= z_sign;
	END PROCESS;
END behavioral;