# Proceso en VHDL para la multiplicación de dos números en formato de punto flotante

El siguiente código VHDL muestra un proceso para multiplicar dos números en formato de punto flotante utilizando una arquitectura basada en IEEE 754 de precisión simple.

```
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
```

## Explicación del código:

1. Se define un proceso que se ejecutará cada vez que cambien las señales de entrada `x` y `y`.

2. Se declaran las variables locales que se utilizarán para almacenar las partes de los números de entrada (`x` e `y`) y del resultado (`z`).

3. Se extraen la mantisa, el exponente y el signo de `x` e `y` y se asignan a las variables locales correspondientes.

4. Se realizan comprobaciones para casos especiales, como multiplicar por infinito (`inf`) o por cero (`0`), y se establecen los valores del exponente y la mantisa del resultado en consecuencia.

5. En caso de no ser un caso especial, se realiza la multiplicación de las mantisas de `x` e `y` y se almacena el resultado en la variable `aux2`.

6. Se verifica si el resultado es mayor o igual a 2 mediante la comprobación del bit más significativo de aux2. En caso afirmativo, se realiza un desplazamiento hacia la izquierda de la mantisa del resultado y se suma uno al exponente.

7. Si el resultado es menor a 2, se realiza un desplazamiento hacia la izquierda de la mantisa del resultado sin sumar uno al exponente.

8. Se calcula el exponente del resultado sumando los exponentes de `x` e y `y` restando 127.

9. Se verifica si hay desbordamiento mediante la comprobación del bit más significativo de `exponent_sum`. En caso afirmativo, se establecen los valores del exponente y la mantisa del resultado en consecuencia (máximo exponente y mantisa en ceros para desbordamiento, exponente y mantisa en ceros para subdesbordamiento).

10. Si no hay desbordamiento, se asigna el valor de `exponent_sum` al exponente del resultado y se calcula el signo utilizando la operación `XOR` entre los signos de `x` e `y`.

11. Por último, se asignan los valores de las variables locales a la señal de salida `z`, correspondiendo la mantisa, el exponente y el signo del resultado a las partes correspondientes de `z`.

Este proceso en VHDL implementa la multiplicación de dos números en formato de punto flotante, siguiendo la especificación del estándar IEEE 754 de precisión simple.