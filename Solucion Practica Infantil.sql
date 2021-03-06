--Ejercicio 1
--Haz una función llamada DevolverCodDept que reciba el nombre de un departamento y devuelva su código.

create or replace function DevolverCodDept (p_nombre dept.dname%type)
return dept.deptno%type
is
	v_codigo	dept.deptno%type;
begin
	select deptno into v_codigo
	from dept
	where dname=p_nombre;
	return v_codigo;
exception
	when NO_DATA_FOUND then
		dbms_output.put_line('Departamento '||p_nombre||' no existe');
		return -1;
	when TOO_MANY_ROWS then
		dbms_output.put_line('Departamento '||p_nombre||' repetido');
		return -2;
end DevolverCodDept;

--Ejercicio 2
--Realiza un procedimiento llamado HallarNumEmp que recibiendo un nombre de departamento,
--muestre en pantalla el número de empleados de dicho departamento. Puedes utilizar la función creada en el ejercicio 1.
--Si el departamento no tiene empleados deberá mostrar un mensaje informando de ello.
--Si el departamento no existe se tratará la excepción correspondiente.

create or replace procedure HallarNumEmp (p_nombre dept.dname%type)
is
	v_codigo 		dept.deptno%type;
	v_numempleados	number(4);
begin
	v_codigo:=DevolverCodDept(p_nombre);
	if v_codigo>=0 then
		select count(*) into v_numempleados
		from emp
		where deptno=v_codigo;
		dbms_output.put_line('El departamento '||p_nombre||' tiene '||	v_numempleados||' empleados');
	end if;
end HallarNumEmp;

--Ejercicio 3
--Realiza una función llamada CalcularCosteSalarial que reciba un nombre de departamento y devuelva la suma de los 
--salarios y comisiones de los empleados de dicho departamento. Trata las excepciones que consideres necesarias.

create or replace function CalcularCosteSalarial (p_nombre dept.dname%type)
return NUMBER
is
	v_codigo 		dept.deptno%type;
	v_costetotal		number(8);
begin
	v_codigo:=DevolverCodDept(p_nombre);
	if v_codigo>=0 then
		select sum(sal+nvl(comm,0)) into v_costetotal
		from emp
		where deptno=v_codigo;
		return v_costetotal;
	else
		return v_codigo; -- devuelvo el error de DevolverCodDept
	end if;
end CalcularCosteSalarial;


--Ejercicio 4
--Realiza un procedimiento MostrarCostesSalariales que muestre los nombres de todos los departamentos y el coste salarial
--de cada uno de ellos. Puedes usar la función del ejercicio 3.

create or replace procedure MostrarCostesSalariales
is
	cursor c_dept
	is
	select dname
	from dept;

	v_coste number(9);
begin
	for v_nombres in c_dept loop
		v_coste:=CalcularCosteSalarial(v_nombres.dname);
		if v_coste>=0 then
			dbms_output.put_line(v_nombres.dname||'  '||v_coste);
		end if;
	end loop;
end MostrarCostesSalariales;

--Ejercicio 5
--Realiza un procedimiento MostrarAbreviaturas que muestre las tres primeras letras del nombre de cada empleado.

create or replace procedure MostrarAbreviaturas
is
	cursor c_emp is
	select substr(ename, 1, 3) as abreviatura
	from emp;
begin
	for v_emp in c_emp loop
		dbms_output.put_line(v_emp.abreviatura);		
	end loop;	
end MostrarAbreviaturas;

--Ejercicio 6
--Realiza un procedimiento MostrarMasAntiguos que muestre el nombre del empleado más antiguo de cada departamento
--junto con el nombre del departamento. Trata las excepciones que consideres necesarias.

create or replace procedure MostrarMasAntiguos
is
	cursor c_dept 
	is
	select deptno, dname
	from dept;
	
	v_nomemp	emp.ename%type;
begin
	for v_dept in c_dept loop
		v_nomemp:=BuscarMasAntiguo(v_dept.deptno);
		dbms_output.put_line('Departamento: '||v_dept.dname||' Emp: '||v_nomemp);
	end loop;
end MostrarMasAntiguos;

create or replace function BuscarMasAntiguo (p_dept dept.deptno%type)
return emp.ename%type
is
	v_nombre emp.ename%type;
begin
	select ename into v_nombre
	from emp
	where deptno=p_dept
	and hiredate=(select min(hiredate)
			from emp
			where deptno=p_dept);
	return v_nombre;
exception
	when NO_DATA_FOUND then
		return 'No tiene empleados';
	when TOO_MANY_ROWS then
		return 'VARIOS';
end BuscarMasAntiguo;


--Ejercicio 7
--Realiza un procedimiento MostrarJefes que reciba el nombre de un departamento y muestre los nombres de los empleados
--de ese departamento que son jefes de otros empleados.Trata las excepciones que consideres necesarias.

create or replace procedure MostrarJefes (p_nombre dept.dname%type)
is
	cursor c_emp
	is
	select ename
	from emp
	where deptno = (select deptno
			from dept
			where dname=p_nombre)
	and empno in (select mgr
		          from emp);
	v_ind	number:=0;
begin
	for v_emp in c_emp loop
		dbms_output.put_line(v_emp.ename);
		v_ind:=1;
	end loop;
	if v_ind=0 then
		 dbms_output.put_line('Ningún empleado de '||p_nombre||' es jefe');
	end if;
end MostrarJefes;

--Ejercicio 8
--Realiza un procedimiento MostrarMejoresVendedores que muestre los nombres de los dos vendedores con más comisiones.
--Trata las excepciones que consideres necesarias.

create or replace procedure MostrarMejoresVendedores
is
	cursor  c_vend 
	is
	select ename
	from emp
	order by comm desc;

	v_vend c_vend%rowtype;
begin
	open c_vend;
	fetch c_vend into v_vend;
	while c_vend%FOUND and c_vend%ROWCOUNT<=3  loop
		dbms_output.put_line(v_vend.ename);
	end loop;
	if c_vend%ROWCOUNT<2 then
		raise_application_error(-20001,'Hay menos de dos vendedores con comisión');
	end if;
	close c_vend;
end MostrarMejoresVendedores;

--Ejercicio 9
--Realiza un procedimiento MostrarsodaelpmE que reciba el nombre de un departamento al revés y muestre los nombres 
--de los empleados de ese departamento. Trata las excepciones que consideres necesarias.

Create or replace procedure MostrarsodaelpmE (p_nombre dept.dname%type)
is
	v_nombredept	dept.dname%type;
begin
	v_nombredept:=DevolverCadalReves(p_nombre);
	MostrarEmpleados(v_nombredept);
end MostrarsodaelpmE;

create or replace procedure MostrarEmpleados(p_nombre dept.dname%type)
is
	cursor c_emp
	is
	select ename
	from emp
	where deptno = (select deptno
			    from dept
			    where dname=p_nombre);
begin
	for v_emp in c_emp loop
		dbms_output.put_line(v_emp.ename);
	end loop;
end MostrarEmpleados;

create or replace function DevolverCadAlReves( p_cad VARCHAR2)
return VARCHAR2
is
	v_aux VARCHAR2(30):='';
begin
	for i in reverse 1..length(p_cad) loop
		v_aux:=v_aux||substr(p_cad,i,1);
	end loop;
	return v_aux;
end  DevolverCadAlReves;


--Ejercicio 10
--Realiza un procedimiento RecortarSueldos que recorte el sueldo un 20% a los empleados cuyo nombre empiece por la letra
--que recibe como parámetro. Trata las excepciones que consideres necesarias.

create or replace procedure RecortarSueldos (p_letra VARCHAR2)
is
begin
	update emp
	set sal = sal – 0.2*sal
	where substr(ename, 1, 1)=p_letra;
	if SQL%NOTFOUND then
		dbms_output.put_line('Ningun empleado actualizado');
	else 
		dbms_output.put_line(SQL%ROWCOUNT||'empleados actualizados');
	end if;
end RecortarSueldos;



--Ejercicio 11
--Realiza un procedimiento BorrarBecarios que borre a los dos empleados más nuevos de cada departamento.
--Trata las excepciones que consideres necesarias.

Create or replace procedure BorrarBecarios
is
	cursor c_dept
	is
	select deptno
	from dept;
begin
	for v_dept in c_dept loop
		BorrarDosMasNuevos(v_dept.deptno);
	end loop;
end BorrarBecarios;

create or replace procedure BorrarDosMasNuevos(p_deptno dept.deptno%type)
is
	cursor c_emp
	is
	select empno
	from emp
	where deptno= p_deptno
	order by hiredate desc;

	v_emp c_emp%rowtype;
begin
	open c_emp;
	fetch c_emp into v_emp;
	while c_emp%found and c_emp%rowcount<=2 loop
		delete emp
		where empno=v_emp.empno;
		fetch c_emp into v_emp;
	end loop;
	close c_emp;
end BorrarDosMasNuevos;
