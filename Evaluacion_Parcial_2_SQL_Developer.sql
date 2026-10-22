-- ============================================================================
-- PREPARACIÓN EVALUACIÓN PARCIAL 2
-- Taller de Bases de Datos - Oracle PL/SQL
-- Archivo compatible con Oracle SQL Developer
--
-- IMPORTANTE:
-- 1. Ejecutar el archivo completo con F5 (Run Script) en SQL Developer.
-- 2. Para ver los mensajes, revisar la pestaña "Salida de Script".
-- 3. Este script crea tablas y objetos. Si ya existen, Oracle informará errores
--    de objeto duplicado; en ese caso, usar un esquema limpio o eliminar los
--    objetos existentes antes de ejecutar nuevamente.
-- ============================================================================

SET SERVEROUTPUT ON;

-- ============================================================================
-- EJERCICIO A: Procedimiento que imprime un mensaje fijo
-- Enunciado: Crear un procedimiento que muestre un mensaje con DBMS_OUTPUT.
-- ============================================================================

CREATE OR REPLACE PROCEDURE HOLA AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('¡Hola, soy alumno de Duoc!');
END;
/

BEGIN
    HOLA;
END;
/

-- ============================================================================
-- EJERCICIO B: Mostrar nombre completo
-- Enunciado: Recibir nombre y apellido y mostrarlos en una sola línea.
-- ============================================================================

CREATE OR REPLACE PROCEDURE NOMBRE_COMPLETO (
    P_NOMBRE   IN VARCHAR2,
    P_APELLIDO IN VARCHAR2
) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE(P_NOMBRE || ' ' || P_APELLIDO);
END;
/

BEGIN
    NOMBRE_COMPLETO('Simon', 'Gonzalez');
END;
/

-- ============================================================================
-- EJERCICIO C: Cuadrado de un número
-- Enunciado: Recibir un número y mostrar su cuadrado.
-- ============================================================================

CREATE OR REPLACE PROCEDURE CUADRADO (
    P_NUMERO IN NUMBER
) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('El cuadrado es: ' || (P_NUMERO ** 2));
END;
/

BEGIN
    CUADRADO(3);
END;
/

-- ============================================================================
-- EJERCICIO D: Insertar un cliente
-- Enunciado: Insertar un cliente usando su ID y nombre.
-- ============================================================================

CREATE TABLE CLIENTES (
    ID_CLIENTE NUMBER PRIMARY KEY,
    NOMBRE     VARCHAR2(100)
);

CREATE OR REPLACE PROCEDURE INSERTAR_CLIENTE (
    P_ID_CLIENTE IN NUMBER,
    P_NOMBRE     IN VARCHAR2
) AS
BEGIN
    INSERT INTO CLIENTES (ID_CLIENTE, NOMBRE)
    VALUES (P_ID_CLIENTE, P_NOMBRE);

    COMMIT;
END;
/

BEGIN
    INSERTAR_CLIENTE(1, 'Pedro');
END;
/

SELECT * FROM CLIENTES;

-- ============================================================================
-- TABLAS AUXILIARES PARA LOS EJERCICIOS E, F, G, H, I Y J
-- ============================================================================

CREATE TABLE EMPLEADOS (
    ID_EMPLEADO NUMBER PRIMARY KEY,
    NOMBRE      VARCHAR2(100),
    SALARIO     NUMBER(10,2)
);

CREATE TABLE ORDENES (
    ID_ORDEN   NUMBER PRIMARY KEY,
    ID_CLIENTE NUMBER,
    FOREIGN KEY (ID_CLIENTE) REFERENCES CLIENTES(ID_CLIENTE)
);

CREATE TABLE DETALLE_ORDENES (
    ID_DETALLE      NUMBER PRIMARY KEY,
    ID_ORDEN        NUMBER,
    CANTIDAD        NUMBER,
    PRECIO_UNITARIO NUMBER(10,2),
    FOREIGN KEY (ID_ORDEN) REFERENCES ORDENES(ID_ORDEN)
);

-- ============================================================================
-- EJERCICIO E: Actualizar salario
-- Enunciado: Actualizar el salario de un empleado por ID.
-- ============================================================================

CREATE OR REPLACE PROCEDURE ACTUALIZAR_SALARIO (
    P_ID_EMPLEADO  IN NUMBER,
    P_NUEVO_SALARIO IN NUMBER
) AS
BEGIN
    UPDATE EMPLEADOS
    SET SALARIO = P_NUEVO_SALARIO
    WHERE ID_EMPLEADO = P_ID_EMPLEADO;

    COMMIT;
END;
/

INSERT INTO EMPLEADOS (ID_EMPLEADO, NOMBRE, SALARIO)
VALUES (1, 'Juan', 500000);

COMMIT;

BEGIN
    ACTUALIZAR_SALARIO(1, 800000);
END;
/

SELECT * FROM EMPLEADOS;

-- ============================================================================
-- EJERCICIO F: Eliminar una orden
-- Enunciado: Eliminar una orden específica usando su ID.
-- ============================================================================

CREATE OR REPLACE PROCEDURE ELIMINAR_ORDEN (
    P_ID_ORDEN IN NUMBER
) AS
BEGIN
    DELETE FROM ORDENES
    WHERE ID_ORDEN = P_ID_ORDEN;

    COMMIT;
END;
/

-- ============================================================================
-- EJERCICIO G: Contar órdenes de un cliente
-- Enunciado: Mostrar cuántas órdenes ha realizado un cliente.
-- ============================================================================

CREATE OR REPLACE PROCEDURE CONTAR_ORDENES (
    P_ID_CLIENTE IN NUMBER
) AS
    V_CANTIDAD NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO V_CANTIDAD
    FROM ORDENES
    WHERE ID_CLIENTE = P_ID_CLIENTE;

    DBMS_OUTPUT.PUT_LINE('Cantidad de ordenes: ' || V_CANTIDAD);
END;
/

-- ============================================================================
-- EJERCICIO H: Calcular el total de una orden
-- Enunciado: Sumar cantidad * precio unitario para una orden.
-- ============================================================================

CREATE OR REPLACE PROCEDURE TOTAL_ORDEN (
    P_ID_ORDEN IN NUMBER
) AS
    V_TOTAL NUMBER;
BEGIN
    SELECT NVL(SUM(CANTIDAD * PRECIO_UNITARIO), 0)
    INTO V_TOTAL
    FROM DETALLE_ORDENES
    WHERE ID_ORDEN = P_ID_ORDEN;

    DBMS_OUTPUT.PUT_LINE('Total: ' || V_TOTAL);
END;
/

-- ============================================================================
-- EJERCICIO I: Consultar salario actual
-- Enunciado: Mostrar el salario actual de un empleado por su ID.
-- ============================================================================

CREATE OR REPLACE PROCEDURE CONSULTAR_SALARIO (
    P_ID_EMPLEADO IN NUMBER
) AS
    V_SALARIO NUMBER;
BEGIN
    SELECT SALARIO
    INTO V_SALARIO
    FROM EMPLEADOS
    WHERE ID_EMPLEADO = P_ID_EMPLEADO;

    DBMS_OUTPUT.PUT_LINE('Salario actual: ' || V_SALARIO);
END;
/

-- ============================================================================
-- EJERCICIO J: Aumentar salarios por porcentaje
-- Enunciado: Aumentar el salario de todos los empleados en un porcentaje.
-- ============================================================================

CREATE OR REPLACE PROCEDURE AUMENTAR_SALARIOS (
    P_PORCENTAJE IN NUMBER
) AS
BEGIN
    UPDATE EMPLEADOS
    SET SALARIO = SALARIO * (1 + P_PORCENTAJE / 100);

    COMMIT;
END;
/

-- ============================================================================
-- EJERCICIO K: Paquete PKG_NOTAS
-- Enunciado: Calcular promedio de tres notas e indicar aprobado/reprobado.
-- Aprueba con promedio igual o superior a 4,0.
-- ============================================================================

CREATE OR REPLACE PACKAGE PKG_NOTAS AS
    PROCEDURE SP_CALCULAR_PROMEDIO (
        P_NOTA1   IN NUMBER,
        P_NOTA2   IN NUMBER,
        P_NOTA3   IN NUMBER,
        P_PROMEDIO OUT NUMBER
    );

    FUNCTION FN_ESTADO_ALUMNO (
        P_PROMEDIO IN NUMBER
    ) RETURN VARCHAR2;
END PKG_NOTAS;
/

CREATE OR REPLACE PACKAGE BODY PKG_NOTAS AS
    PROCEDURE SP_CALCULAR_PROMEDIO (
        P_NOTA1   IN NUMBER,
        P_NOTA2   IN NUMBER,
        P_NOTA3   IN NUMBER,
        P_PROMEDIO OUT NUMBER
    ) AS
    BEGIN
        P_PROMEDIO := (P_NOTA1 + P_NOTA2 + P_NOTA3) / 3;
    END SP_CALCULAR_PROMEDIO;

    FUNCTION FN_ESTADO_ALUMNO (
        P_PROMEDIO IN NUMBER
    ) RETURN VARCHAR2 AS
    BEGIN
        IF P_PROMEDIO >= 4.0 THEN
            RETURN 'APROBADO';
        ELSE
            RETURN 'REPROBADO';
        END IF;
    END FN_ESTADO_ALUMNO;
END PKG_NOTAS;
/

DECLARE
    V_PROMEDIO NUMBER;
    V_ESTADO   VARCHAR2(20);
BEGIN
    PKG_NOTAS.SP_CALCULAR_PROMEDIO(
        5.0, 6.0, 4.0, V_PROMEDIO
    );

    V_ESTADO := PKG_NOTAS.FN_ESTADO_ALUMNO(V_PROMEDIO);

    DBMS_OUTPUT.PUT_LINE('Promedio: ' || ROUND(V_PROMEDIO, 2));
    DBMS_OUTPUT.PUT_LINE('Estado: ' || V_ESTADO);
END;
/

-- ============================================================================
-- FIN DEL ARCHIVO
-- Nota: Los ejercicios F, G y H requieren registros de prueba en ORDENES y
-- DETALLE_ORDENES si deseas probar resultados distintos de cero.
-- ============================================================================
