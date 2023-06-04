LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;

ENTITY Adder_IEEE_754 IS

	PORT (
		clk, rx, reset, start_tx : IN STD_LOGIC;
		tx, end_rx, end_tx : OUT STD_LOGIC;
		z : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));

END Adder_IEEE_754;
ARCHITECTURE Behavioral OF Adder_IEEE_754 IS

	COMPONENT clock_generator IS
		PORT (
			clock_in : IN STD_LOGIC;
			clock_out : OUT STD_LOGIC);
	END COMPONENT;

	TYPE state IS (ready, b0, b1, b2, b3, b4, b5, b6, b7, b8); ----fsm PARA RECEPCION
	SIGNAL ps_rx, ps_tx : state := ready; -- ESTADO INICIAL
	SIGNAL store : STD_LOGIC_VECTOR(7 DOWNTO 0); ---- REGISTRO DE ALMACENAMIENTO
	SIGNAL count_byte_rx : STD_LOGIC_VECTOR(3 DOWNTO 0); -- CONTADOR DE BYTES RECIBIDOS
	SIGNAL count_byte_tx : STD_LOGIC_VECTOR(3 DOWNTO 0); -- CONTADOR DE BYTES ENVIADOS
	SIGNAL data_tx, producto : STD_LOGIC_VECTOR(63 DOWNTO 0); -- DATOS A ENVIAR
	SIGNAL data_rx : STD_LOGIC_VECTOR(63 DOWNTO 0); -- DATOS RECIBIDOS
	SIGNAL s_baudclock : STD_LOGIC; -- SEÑAL DE RELOJ PARA BAUDRATE
	SIGNAL x : STD_LOGIC_VECTOR(31 DOWNTO 0); --:= "01001101000000000011011101010111";
	SIGNAL y : STD_LOGIC_VECTOR(31 DOWNTO 0); --:= "01000000000000000000000000000000";
	SIGNAL z_signal : STD_LOGIC_VECTOR(31 DOWNTO 0); -- SEÑAL DE SALIDA

BEGIN

	BAUDRATE : clock_generator
	PORT MAP(clk, s_baudclock);
	--rx process

	PROCESS (s_baudclock, reset)
	BEGIN
		IF reset = '1' THEN -- Reset
			ps_rx <= ready; -- Estado inicial
			data_rx <= (OTHERS => '0'); -- Limpia el registro de datos
			count_byte_rx <= "0000"; -- Limpia el contador de bytes
		ELSIF s_baudclock'event AND s_baudclock = '1' THEN -- Si hay flanco de subida en el reloj
			IF ps_rx = ready THEN -- Si el estado es ready
				IF rx = '0' THEN -- Si la señal rx es 0 (inicio de trama)
					IF count_byte_rx < 8 THEN
						ps_rx <= b0; -- Cambia de estado a b0 si el contador de bytes es menor a 8
					ELSE
						ps_rx <= ready; -- Si el contador de bytes es mayor a 8, se queda en ready
					END IF;
				ELSE
					ps_rx <= ready; -- Si la señal rx es 1, se queda en ready
				END IF;
			END IF;
			------------------------------------------1
			IF ps_rx = b0 THEN
				store(7) <= rx; -- Almacena el bit en el registro de almacenamiento
				ps_rx <= b1; -- Cambia de estado a b1
			END IF;
			------------------------------------------2
			IF ps_rx = b1 THEN
				store(6) <= rx; -----
				ps_rx <= b2;
			END IF;
			-----------------------------------------3
			IF ps_rx = b2 THEN
				store(5) <= rx; -----
				ps_rx <= b3;
			END IF;
			----------------------------------------4
			IF ps_rx = b3 THEN
				store(4) <= rx; -----
				ps_rx <= b4;
			END IF;
			---------------------------------------5
			IF ps_rx = b4 THEN
				store(3) <= rx; -----
				ps_rx <= b5;
			END IF;
			---------------------------------------6
			IF ps_rx = b5 THEN
				store(2) <= rx; -----
				ps_rx <= b6;
			END IF;
			---------------------------------------7
			IF ps_rx = b6 THEN
				store(1) <= rx; -----
				ps_rx <= b7;
			END IF;
			--------------------------------------8
			IF ps_rx = b7 THEN
				store(0) <= rx; -----
				--count_byte_rx <= count_byte_rx + 1;
				--data_rx <= data_rx(55 downto 0) & store;
				ps_rx <= b8;

			END IF;

			IF ps_rx = b8 THEN
				count_byte_rx <= count_byte_rx + 1; -- Incrementa el contador de bytes
				data_rx <= data_rx(55 DOWNTO 0) & store; -- Almacena el byte en el registro de datos
				ps_rx <= ready; -- Cambia de estado a ready

			END IF;

			IF count_byte_rx = 8 THEN
				x <= data_rx(63 DOWNTO 32); -- Almacena el primer operando
				y <= data_rx(31 DOWNTO 0); -- Almacena el segundo operando
			END IF;
			--------------------------------------9
		END IF;
	END PROCESS;

	-- end_rx es '1' cuando se recibieron 8 bytes
	end_rx <=
		'1' WHEN count_byte_rx = 8 ELSE
		'0';

	--tx process
	PROCESS (s_baudclock, reset)
	BEGIN
		IF reset = '1' THEN
			tx <= '1';
			ps_tx <= ready; -- Estado inicial
			count_byte_tx <= "0000"; -- Limpia el contador de bytes
		ELSIF s_baudclock'event AND s_baudclock = '1' THEN
			IF ps_tx = ready THEN
				IF start_tx = '1' THEN -- Si se presiona el botón de start
					IF count_byte_tx < 8 THEN
						tx <= '0'; -- Se pone en 0 la señal tx
						IF count_byte_tx = 0 THEN
							data_tx(63 DOWNTO 32) <= x(31 DOWNTO 0); -- Se almacena el primer operando
							data_tx(31 DOWNTO 0) <= y(31 DOWNTO 0); -- Se almacena el segundo operando
						END IF;
						ps_tx <= b0; -- Cambia de estado a b0
					ELSE
						tx <= '1'; -- Si el contador de bytes es mayor a 8, se pone en 1 la señal tx
						ps_tx <= ready; -- Se queda en ready
					END IF;
				ELSE
					tx <= '1'; -- Si no se presiona el botón de start, se pone en 1 la señal tx
					ps_tx <= ready; -- Se queda en ready
				END IF;
			END IF;
			------------------------------------------1
			IF ps_tx = b0 THEN
				tx <= data_tx(63); -- Se envía el bit más significativo del primer operando
				ps_tx <= b1; -- El estado cambia a b1
			END IF;
			------------------------------------------2
			IF ps_tx = b1 THEN
				tx <= data_tx(62);
				ps_tx <= b2;
			END IF;
			-----------------------------------------3
			IF ps_tx = b2 THEN
				tx <= data_tx(61);
				ps_tx <= b3;
			END IF;
			----------------------------------------4
			IF ps_tx = b3 THEN
				tx <= data_tx(60);
				ps_tx <= b4;
			END IF;
			---------------------------------------5
			IF ps_tx = b4 THEN
				tx <= data_tx(59);
				ps_tx <= b5;
			END IF;
			---------------------------------------6
			IF ps_tx = b5 THEN
				tx <= data_tx(58);
				ps_tx <= b6;
			END IF;
			---------------------------------------7
			IF ps_tx = b6 THEN
				tx <= data_tx(57);
				ps_tx <= b7;
			END IF;
			--------------------------------------8
			IF ps_tx = b7 THEN
				tx <= data_tx(56);
				ps_tx <= b8;
			END IF;
			--------------------------------------9
			IF ps_tx = b8 THEN
				tx <= '1'; -- Se pone en 1 la señal tx
				data_tx <= data_tx(55 DOWNTO 0) & "00000000"; -- Se limpia el registro de datos
				count_byte_tx <= count_byte_tx + 1; -- Se incrementa el contador de bytes
				ps_tx <= ready; -- Se cambia de estado a ready

			END IF;
			-------------------------------------1
		END IF;
	END PROCESS;

	-- end_tx es '1' cuando se enviaron 8 bytes
	end_tx <=
		'1' WHEN count_byte_tx = 8 ELSE
		'0';
	-----------------------------------------------------------------

	-- Multiplicación
	PROCESS (x, y)
		-- Variables locales para almacenar partes de los números
		VARIABLE x_mantissa : STD_LOGIC_VECTOR (22 DOWNTO 0); -- Mantisa de x
		VARIABLE x_exponent : STD_LOGIC_VECTOR (7 DOWNTO 0); -- Exponente de x
		VARIABLE x_sign : STD_LOGIC; -- Signo de x
		VARIABLE y_mantissa : STD_LOGIC_VECTOR (22 DOWNTO 0); -- Mantisa de y
		VARIABLE y_exponent : STD_LOGIC_VECTOR (7 DOWNTO 0); -- Exponente de y
		VARIABLE y_sign : STD_LOGIC; -- Signo de y
		VARIABLE z_mantissa : STD_LOGIC_VECTOR (22 DOWNTO 0); -- Mantisa del resultado
		VARIABLE z_exponent : STD_LOGIC_VECTOR (7 DOWNTO 0); -- Exponente del resultado
		VARIABLE z_sign : STD_LOGIC; -- Signo del resultado
		VARIABLE aux : STD_LOGIC; -- Variable auxiliar para el bit de acarreo
		VARIABLE aux2 : STD_LOGIC_VECTOR (47 DOWNTO 0); -- Variable auxiliar para cálculos intermedios
		VARIABLE exponent_sum : STD_LOGIC_VECTOR (8 DOWNTO 0); -- Suma de exponentes

	BEGIN
		-- Asignar partes de los números de entrada a las variables locales
		x_mantissa := x(22 DOWNTO 0); -- Extraer la mantisa de x
		x_exponent := x(30 DOWNTO 23); -- Extraer el exponente de x
		x_sign := x(31); -- Extraer el signo de x
		y_mantissa := y(22 DOWNTO 0); -- Extraer la mantisa de y
		y_exponent := y(30 DOWNTO 23); -- Extraer el exponente de y
		y_sign := y(31); -- Extraer el signo de y

		-- Comprobaciones para casos especiales
		IF (x_exponent = 255 OR y_exponent = 255) THEN
			-- Caso: inf*x o x*inf (resultado sería NaN)
			z_exponent := "11111111"; -- Establecer exponente del resultado a máximo
			z_mantissa := (OTHERS => '0'); -- Establecer mantisa del resultado a ceros
			z_sign := x_sign XOR y_sign; -- Calcular signo del resultado utilizando XOR
		ELSIF (x_exponent = 0 OR y_exponent = 0) THEN
			-- Caso: 0*x o x*0
			z_exponent := (OTHERS => '0'); -- Establecer exponente del resultado a ceros
			z_mantissa := (OTHERS => '0'); -- Establecer mantisa del resultado a ceros
			z_sign := '0'; -- Establecer signo del resultado a cero
		ELSE
			-- Realizar multiplicación de los números x e y
			aux2 := ('1' & x_mantissa) * ('1' & y_mantissa); -- Multiplicar las mantisas

			-- Verificar el bit más significativo de aux2 para determinar si el resultado es >= 2
			IF (aux2(47) = '1') THEN
				-- Resultado >= 2, realizar desplazamiento hacia la izquierda y sumar uno al exponente
				z_mantissa := aux2(46 DOWNTO 24) + aux2(23); -- Con redondeo
				aux := '1'; -- Establecer el bit de acarreo aux a uno
			ELSE
				-- Resultado < 2, realizar desplazamiento hacia la izquierda sin sumar uno al exponente
				z_mantissa := aux2(45 DOWNTO 23) + aux2(22); -- Con redondeo
				aux := '0'; -- Establecer el bit de acarreo aux a cero
			END IF;

			-- Calcular el exponente del resultado sumando los exponentes de x e y y restando 127
			exponent_sum := ('0' & x_exponent) + ('0' & y_exponent) + aux - 127;

			-- Verificar el bit más significativo de exponent_sum para determinar si hay desbordamiento
			IF (exponent_sum(8) = '1') THEN
				IF (exponent_sum(7) = '0') THEN
					-- Desbordamiento: establecer exponente del resultado a máximo y mantisa a ceros
					z_exponent := "11111111";
					z_mantissa := (OTHERS => '0');
					z_sign := x_sign XOR y_sign; -- Calcular signo del resultado utilizando XOR
				ELSE
					-- Subdesbordamiento: establecer exponente del resultado a ceros y mantisa a ceros
					z_exponent := (OTHERS => '0');
					z_mantissa := (OTHERS => '0');
					z_sign := '0'; -- Establecer signo del resultado a cero
				END IF;
			ELSE
				-- Resultado válido: asignar exponent_sum al exponente del resultado y calcular signo
				z_exponent := exponent_sum(7 DOWNTO 0);
				z_sign := x_sign XOR y_sign; -- Calcular signo del resultado utilizando XOR
			END IF;
		END IF;

		-- Asignar los valores de las variables locales a la señal de salida z
		z(22 DOWNTO 0) <= z_mantissa; -- Asignar la mantisa del resultado a la parte correspondiente de z
		z(30 DOWNTO 23) <= z_exponent; -- Asignar el exponente del resultado a la parte correspondiente de z
		z(31) <= z_sign; -- Asignar el signo del resultado a la parte correspondiente de z
	END PROCESS;

END Behavioral;