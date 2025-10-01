-- =============================================
-- DEMOSTRACIÓN COMPLETA DEL CRUD PARA ROLES
-- =============================================

-- 1. CREATE - CREAR NUEVOS ROLES
-- =============================================
SELECT '=== CREANDO NUEVOS ROLES ===' AS 'PASO 1: CREATE';

-- Crear rol de Desarrollador
CALL sp_crud_roles('CREATE', NULL, 'Desarrollador', 'Desarrollo de software y aplicaciones', 'Activo', NULL);

-- Crear rol de Diseñador
CALL sp_crud_roles('CREATE', NULL, 'Diseñador', 'Diseño gráfico y UX/UI', 'Activo', NULL);

-- Crear rol de Tester (inactivo inicialmente)
CALL sp_crud_roles('CREATE', NULL, 'Tester', 'Pruebas de calidad de software', 'Inactivo', NULL);

-- Intentar crear rol duplicado (debe fallar)
SELECT '=== INTENTANDO CREAR ROL DUPLICADO ===' AS 'VALIDACIÓN';
CALL sp_crud_roles('CREATE', NULL, 'Desarrollador', 'Otro desarrollador', 'Activo', NULL);

-- 2. READ - LEER ROLES
-- =============================================
SELECT '=== LEYENDO TODOS LOS ROLES ===' AS 'PASO 2: READ';
CALL sp_crud_roles('READ', NULL, NULL, NULL, NULL, NULL);

-- 3. READ_BY_ID - LEER ROL ESPECÍFICO
-- =============================================
SELECT '=== LEYENDO ROL ESPECÍFICO (ID: 1) ===' AS 'PASO 3: READ BY ID';
CALL sp_crud_roles('READ_BY_ID', 1, NULL, NULL, NULL, NULL);

-- 4. READ_BY_STATUS - FILTRAR POR ESTADO
-- =============================================
SELECT '=== ROLES ACTIVOS ===' AS 'PASO 4: READ BY STATUS';
CALL sp_crud_roles('READ_BY_STATUS', NULL, NULL, NULL, 'Activo', NULL);

SELECT '=== ROLES INACTIVOS ===' AS 'PASO 4: READ BY STATUS';
CALL sp_crud_roles('READ_BY_STATUS', NULL, NULL, NULL, 'Inactivo', NULL);

-- 5. SEARCH - BUSCAR ROLES
-- =============================================
SELECT '=== BUSCANDO ROLES CON "des" ===' AS 'PASO 5: SEARCH';
CALL sp_crud_roles('SEARCH', NULL, NULL, NULL, NULL, 'des');

-- 6. UPDATE - ACTUALIZAR ROL
-- =============================================
SELECT '=== ACTUALIZANDO ROL (ID: 7 - Tester) ===' AS 'PASO 6: UPDATE';

-- Primero vemos el rol actual
CALL sp_crud_roles('READ_BY_ID', 7, NULL, NULL, NULL, NULL);

-- Actualizamos el rol
CALL sp_crud_roles('UPDATE', 7, 'QA Engineer', 'Control de calidad y aseguramiento de software', 'Activo', NULL);

-- Verificamos la actualización
CALL sp_crud_roles('READ_BY_ID', 7, NULL, NULL, NULL, NULL);

-- Intentar actualizar con nombre duplicado (debe fallar)
SELECT '=== INTENTANDO ACTUALIZAR CON NOMBRE DUPLICADO ===' AS 'VALIDACIÓN';
CALL sp_crud_roles('UPDATE', 7, 'Desarrollador', 'Intentando usar nombre duplicado', 'Activo', NULL);

-- 7. DELETE - ELIMINACIÓN LÓGICA
-- =============================================
SELECT '=== ELIMINANDO ROL (ID: 8 - Diseñador) ===' AS 'PASO 7: DELETE';

-- Ver rol antes de eliminar
CALL sp_crud_roles('READ_BY_ID', 8, NULL, NULL, NULL, NULL);

-- Eliminar rol (cambia status a Inactivo)
CALL sp_crud_roles('DELETE', 8, NULL, NULL, NULL, NULL);

-- Verificar que el rol está inactivo
CALL sp_crud_roles('READ_BY_ID', 8, NULL, NULL, NULL, NULL);

-- 8. REACTIVAR - REACTIVAR ROL
-- =============================================
SELECT '=== REACTIVANDO ROL (ID: 8 - Diseñador) ===' AS 'PASO 8: REACTIVAR';

-- Reactivar el rol
CALL sp_crud_roles('REACTIVAR', 8, NULL, NULL, NULL, NULL);

-- Verificar que el rol está activo nuevamente
CALL sp_crud_roles('READ_BY_ID', 8, NULL, NULL, NULL, NULL);

-- 9. CHECK_EMPLOYEES - VERIFICAR EMPLEADOS POR ROL
-- =============================================
SELECT '=== VERIFICANDO EMPLEADOS POR ROL (ID: 1) ===' AS 'PASO 9: CHECK EMPLOYEES';
CALL sp_crud_roles('CHECK_EMPLOYEES', 1, NULL, NULL, NULL, NULL);

-- 10. ESTADO FINAL
-- =============================================
SELECT '=== ESTADO FINAL DE TODOS LOS ROLES ===' AS 'RESULTADO FINAL';
CALL sp_crud_roles('READ', NULL, NULL, NULL, NULL, NULL);_