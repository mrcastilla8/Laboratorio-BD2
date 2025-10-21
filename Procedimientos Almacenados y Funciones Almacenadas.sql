SET SERVEROUTPUT ON;

--4.1.1
CREATE OR REPLACE PROCEDURE part_colors IS
BEGIN
  FOR rec IN (
    SELECT color, city 
    FROM p
    WHERE city <> 'Paris' AND weight > 10
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Color de parte: ' || rec.color || ', ' || 'Ciudad: ' || rec.city);
  END LOOP;
END;
/
EXEC part_colors;

--4.1.2
CREATE OR REPLACE PROCEDURE parte_peso IS
BEGIN
  FOR rec IN (
    SELECT p#, weight * 1000 AS peso 
    FROM p
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Número de parte: ' || rec.p# || ', ' || 'Peso en gramos: ' || rec.peso);
  END LOOP;
END;
/
EXEC parte_peso;

--4.1.3
CREATE OR REPLACE PROCEDURE proveedor_detalle IS
BEGIN
  FOR rec IN (
    SELECT * FROM s
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Número de proveedor: ' || rec.s# || ', ' || 
                         'Nombre: ' || rec.sname || ', ' ||
                         'Estado: ' || rec.status || ', ' ||
                         'Ciudad: ' || rec.city);
  END LOOP;
END;
/
EXEC proveedor_detalle;

--4.1.4
CREATE OR REPLACE PROCEDURE proveedores_partes IS
BEGIN
  FOR rec IN (
    SELECT s.sname, p.pname, s.city 
    FROM s 
    JOIN p ON p.city = s.city
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor: ' || rec.sname || ', ' || 
                         'Parte: ' || rec.pname || ', ' ||
                         'Ciudad: ' || rec.city);
  END LOOP;
END;
/
EXEC proveedores_partes;

--4.1.5
CREATE OR REPLACE PROCEDURE ciudad_pares IS
BEGIN
  FOR rec IN (
    SELECT DISTINCT s.city AS ciudad_s, p.city AS ciudad_p
    FROM s 
    JOIN sp ON sp.s# = s.s# 
    JOIN p ON sp.p# = p.p#
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Ciudad proveedor: ' || rec.ciudad_s || ', ' ||
                         'Ciudad parte: ' || rec.ciudad_p);
  END LOOP;
END;
/
EXEC ciudad_pares;

--4.1.6
CREATE OR REPLACE PROCEDURE proveedor_pares IS
BEGIN
  FOR rec IN (
    SELECT s1.sname AS nombre1, s2.sname AS nombre2
    FROM s s1 
    JOIN s s2 ON s1.city = s2.city
    WHERE s1.sname <> s2.sname
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Par de proveedores co-localizados: ' || rec.nombre1 || ', ' || rec.nombre2);
  END LOOP;
END;
/
EXEC proveedor_pares;

--4.1.7
CREATE OR REPLACE PROCEDURE total_proveedores IS
  v_total NUMBER(6);
BEGIN
  SELECT COUNT(s#) INTO v_total FROM s;
  DBMS_OUTPUT.PUT_LINE('Total de proveedores: ' || v_total);
END;
/
EXEC total_proveedores;

--4.1.8
CREATE OR REPLACE PROCEDURE p2_stats IS
  v_min NUMBER(6);
  v_max NUMBER(6);
BEGIN
  SELECT MIN(sp.qty), MAX(sp.qty)
  INTO v_min, v_max
  FROM sp
  WHERE p# = 'P2';
  
  DBMS_OUTPUT.PUT_LINE('Cantidad mínima de P2: ' || v_min || 
                       ', Cantidad máxima de P2: ' || v_max);
END;
/
EXEC p2_stats;

--4.1.9
CREATE OR REPLACE PROCEDURE parte_cantidad IS
BEGIN
  FOR rec IN (
    SELECT sp.p#, SUM(sp.qty) AS total  
    FROM sp 
    GROUP BY sp.p#
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Número de parte: ' || rec.p# || ', ' || 'Total abastecido: ' || rec.total);
  END LOOP;
END;
/
EXEC parte_cantidad;

--4.1.10
CREATE OR REPLACE PROCEDURE partes_varios_proveedores IS
BEGIN
  FOR rec IN (
    SELECT p#
    FROM sp
    GROUP BY p#
    HAVING COUNT(DISTINCT s#) > 1
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Parte abastecida por más de un proveedor: ' || rec.p#);
  END LOOP;
END;
/
EXEC partes_varios_proveedores;

--4.1.11
CREATE OR REPLACE PROCEDURE proveedores_p2 IS
BEGIN
  FOR rec IN (
    SELECT DISTINCT s.sname
    FROM s
    JOIN sp ON sp.s# = s.s#
    WHERE sp.p# = 'P2'
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor que abastece P2: ' || rec.sname);
  END LOOP;
END;
/
EXEC proveedores_p2;

--4.1.12
CREATE OR REPLACE PROCEDURE proveedores_con_partes IS
BEGIN
  FOR rec IN (
    SELECT s.sname
    FROM s
    WHERE EXISTS (SELECT 1 FROM sp WHERE sp.s# = s.s#)
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor con al menos una parte: ' || rec.sname);
  END LOOP;
END;
/
EXEC proveedores_con_partes;

--4.1.13
CREATE OR REPLACE PROCEDURE proveedores_estado_menor_max IS
BEGIN
  FOR rec IN (
    SELECT s#
    FROM s
    WHERE status < (SELECT MAX(status) FROM s)
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor con estado menor al máximo: ' || rec.s#);
  END LOOP;
END;
/
EXEC proveedores_estado_menor_max;

--4.1.14
CREATE OR REPLACE PROCEDURE proveedores_p2_exists IS
BEGIN
  FOR rec IN (
    SELECT s.sname
    FROM s
    WHERE EXISTS (
      SELECT 1 FROM sp WHERE sp.s# = s.s# AND sp.p# = 'P2'
    )
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor (EXISTS) que abastece P2: ' || rec.sname);
  END LOOP;
END;
/
EXEC proveedores_p2_exists;

--4.1.15
CREATE OR REPLACE PROCEDURE proveedores_no_p2 IS
BEGIN
  FOR rec IN (
    SELECT s.sname
    FROM s
    WHERE NOT EXISTS (
      SELECT 1 FROM sp WHERE sp.s# = s.s# AND sp.p# = 'P2'
    )
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor que NO abastece P2: ' || rec.sname);
  END LOOP;
END;
/
EXEC proveedores_no_p2;

--4.1.16
CREATE OR REPLACE PROCEDURE proveedores_todas_partes IS
BEGIN
  FOR rec IN (
    SELECT s.sname
    FROM s
    WHERE NOT EXISTS (
      SELECT 1
      FROM p pp
      WHERE NOT EXISTS (
        SELECT 1
        FROM sp
        WHERE sp.s# = s.s#
          AND sp.p# = pp.p#
      )
    )
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor que abastece TODAS las partes: ' || rec.sname);
  END LOOP;
END;
/
EXEC proveedores_todas_partes;

--4.1.17
CREATE OR REPLACE PROCEDURE partes_criterios IS
BEGIN
  FOR rec IN (
    SELECT DISTINCT p.p#
    FROM p
    WHERE p.weight > 16
       OR EXISTS (
         SELECT 1
         FROM sp
         WHERE sp.p# = p.p# AND sp.s# = 'S2'
       )
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Parte que cumple (peso >16 o abastecida por S2): ' || rec.p#);
  END LOOP;
END;
/
EXEC partes_criterios;
