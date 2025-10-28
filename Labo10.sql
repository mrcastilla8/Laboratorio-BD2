-- 1
DECLARE
BEGIN
  UPDATE hr.employees SET salary = salary * 1.10 WHERE department_id = 90;
  SAVEPOINT punto1;
  UPDATE hr.employees SET salary = salary * 1.05 WHERE department_id = 60;
  ROLLBACK TO punto1;
  COMMIT;
END;
/

-- a) 90
-- b) Revirtió el 5% del dpto 60; se mantuvo el 10% del dpto 90
-- c) Revierte toda la transacción no confirmada

-- 2


-- a) La fila estaba bloqueada por la transacción activa de la sesión 1
-- b) COMMIT o ROLLBACK de la sesión que posee el bloqueo
-- c) V$SESSION, V$LOCK, V$LOCKED_OBJECT, DBA_BLOCKERS, DBA_WAITERS

-- 3
SET SERVEROUTPUT ON;
DECLARE
  v_job_id     hr.employees.job_id%TYPE;
  v_old_dept   hr.employees.department_id%TYPE;
BEGIN
  SELECT job_id, department_id
    INTO v_job_id, v_old_dept
    FROM hr.employees
   WHERE employee_id = 104
   FOR UPDATE;

  UPDATE hr.employees
     SET department_id = 110
   WHERE employee_id = 104;

  INSERT INTO hr.job_history (employee_id, start_date, end_date, job_id, department_id)
  VALUES (104, TRUNC(SYSDATE) - 1, TRUNC(SYSDATE), v_job_id, v_old_dept);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
-- a) Para que ambas operaciones se confirmen o se deshagan juntas (atomicidad)
-- b) Se revierten ambos cambios antes del COMMIT
-- c) Mediante FKs y reglas entre EMPLOYEES/JOB_HISTORY; Oracle valida claves y referencias

-- 4
BEGIN
  UPDATE hr.employees SET salary = salary * 1.08 WHERE department_id = 100;
  SAVEPOINT a;
  UPDATE hr.employees SET salary = salary * 1.05 WHERE department_id = 80;
  SAVEPOINT b;
  DELETE FROM hr.employees WHERE department_id = 50;
  ROLLBACK TO b;
  COMMIT;
END;
/
-- a) Persiste el 8% del dpto 100
-- b) Las filas eliminadas se restauran al hacer ROLLBACK TO b
-- c) Consultas SELECT antes/después en la misma y otra sesión; tras COMMIT, verificación definitiva
