-- =============================================
-- DEMOSTRACIÓN: RESTAURACIÓN DE ROLES
-- =============================================

-- 1. ESTADO INICIAL - VER TODOS LOS ROLES
-- =============================================
SELECT '=== ESTADO INICIAL DE ROLES ===' AS 'INFORMACIÓN';
CALL sp_crud_roles('READ', NULL, NULL, NULL, NULL, NULL);

-- 2. CREAR ALGUNOS ROLES DE EJEMPLO PARA LA DEMOSTRACIÓN
-- =============================================
SELECT '=== CREANDO ROLES PARA DEMOSTRACIÓN ===' AS 'PASO 1';

-- Crear roles adicionales
CALL sp_crud_roles('CREATE', NULL, 'Coordinador', 'Coordina actividades del equipo', 'Activo', NULL);
CALL sp_crud_roles('CREATE', NULL, 'Supervisor', 'Supervisa operaciones diarias', 'Activo', NULL);
CALL sp_crud_roles('CREATE', NULL, 'Asistente', 'Brinda apoyo administrativo', 'Activo', NULL);

-- Verificar creación
SELECT '=== ROLES CREADOS ===' AS 'CONFIRMACIÓN';
CALL sp_crud_roles('READ_BY_STATUS', NULL, NULL, NULL, 'Activo', NULL);

-- 3. ELIMINAR ALGUNOS ROLES (ELIMINACIÓN LÓGICA)
-- =============================================
SELECT '=== ELIMINANDO ROLES ===' AS 'PASO 2';

-- Eliminar el rol "Asistente" (ID: 11)
CALL sp_crud_roles('DELETE', 11, NULL, NULL, NULL, NULL);

-- Eliminar el rol "Recursos Humanos" si existe (buscar primero)
SELECT '=== BUSCANDO ROL "Recursos Humanos" PARA ELIMINAR ===' AS 'BÚSQUEDA';
CALL sp_crud_roles('SEARCH', NULL, NULL, NULL, NULL, 'Recursos Humanos');

-- Si existe, eliminarlo (reemplaza X con el ID correcto)
-- CALL sp_crud_roles('DELETE', X, NULL, NULL, NULL, NULL);

-- 4. VER ESTADO DESPUÉS DE ELIMINACIONES
-- =============================================
SELECT '=== ROLES ACTIVOS DESPUÉS DE ELIMINACIONES ===' AS 'PASO 3';
CALL sp_crud_roles('READ_BY_STATUS', NULL, NULL, NULL, 'Activo', NULL);

SELECT '=== ROLES INACTIVOS (ELIMINADOS) ===' AS 'PASO 3';
CALL sp_crud_roles('READ_BY_STATUS', NULL, NULL, NULL, 'Inactivo', NULL);

-- 5. IDENTIFICAR ROLES PARA RESTAURAR
-- =============================================
SELECT '=== IDENTIFICANDO ROLES ELIMINADOS ===' AS 'PASO 4';

-- Ver todos los roles inactivos con sus detalles
SELECT 
    id_rol,
    nombre_rol,
    descripcion,
    fecha_creacion,
    fecha_actualizacion,
    'INACTIVO - PARA RESTAURAR' as estado
FROM roles 
WHERE status = 'Inactivo'
ORDER BY fecha_actualizacion DESC;

-- 6. RESTAURAR ROLES ELIMINADOS
-- =============================================
SELECT '=== RESTAURANDO ROLES ===' AS 'PASO 5';

-- Restaurar el rol "Asistente" (ID: 11)
SELECT '=== RESTAURANDO ASISTENTE (ID: 11) ===' AS 'RESTAURACIÓN 1';
CALL sp_crud_roles('REACTIVAR', 11, NULL, NULL, NULL, NULL);

-- Verificar restauración
CALL sp_crud_roles('READ_BY_ID', 11, NULL, NULL, NULL, NULL);

-- Intentar restaurar un rol que no existe (debe fallar)
SELECT '=== INTENTANDO RESTAURAR ROL INEXISTENTE ===' AS 'VALIDACIÓN';
CALL sp_crud_roles('REACTIVAR', 999, NULL, NULL, NULL, NULL);

-- 7. VERIFICAR RESTAURACIÓN MASIVA
-- =============================================
SELECT '=== VERIFICANDO RESTAURACIÓN INDIVIDUAL ===' AS 'PASO 6';

-- Ver el rol restaurado
CALL sp_crud_roles('READ_BY_ID', 11, NULL, NULL, NULL, NULL);

-- Ver todos los roles activos después de la restauración
SELECT '=== ROLES ACTIVOS DESPUÉS DE RESTAURACIÓN ===' AS 'CONFIRMACIÓN';
CALL sp_crud_roles('READ_BY_STATUS', NULL, NULL, NULL, 'Activo', NULL);

-- 8. EJEMPLO DE FLUJO COMPLETO: CREAR → ELIMINAR → RESTAURAR
-- =============================================
SELECT '=== FLUJO COMPLETO: CREAR → ELIMINAR → RESTAURAR ===' AS 'DEMOSTRACIÓN COMPLETA';

-- Paso 1: Crear un rol temporal
SELECT '--- CREANDO ROL TEMPORAL ---' AS 'PASO A';
CALL sp_crud_roles('CREATE', NULL, 'Rol Temporal', 'Rol para demostración de restauración', 'Activo', NULL);

-- Obtener el ID del rol recién creado (asumimos que es el último)
SET @nuevo_rol_id = LAST_INSERT_ID();
SELECT CONCAT('ID del nuevo rol: ', @nuevo_rol_id) AS 'INFORMACIÓN';

-- Paso 2: Verificar que está activo
SELECT '--- VERIFICANDO ROL ACTIVO ---' AS 'PASO B';
CALL sp_crud_roles('READ_BY_ID', @nuevo_rol_id, NULL, NULL, NULL, NULL);

-- Paso 3: Eliminar el rol
SELECT '--- ELIMINANDO ROL ---' AS 'PASO C';
CALL sp_crud_roles('DELETE', @nuevo_rol_id, NULL, NULL, NULL, NULL);

-- Paso 4: Verificar que está inactivo
SELECT '--- VERIFICANDO ROL INACTIVO ---' AS 'PASO D';
CALL sp_crud_roles('READ_BY_ID', @nuevo_rol_id, NULL, NULL, NULL, NULL);

-- Paso 5: Restaurar el rol
SELECT '--- RESTAURANDO ROL ---' AS 'PASO E';
CALL sp_crud_roles('REACTIVAR', @nuevo_rol_id, NULL, NULL, NULL, NULL);

-- Paso 6: Verificar restauración exitosa
SELECT '--- VERIFICANDO RESTAURACIÓN EXITOSA ---' AS 'PASO F';
CALL sp_crud_roles('READ_BY_ID', @nuevo_rol_id, NULL, NULL, NULL, NULL);

-- 9. ESTADO FINAL
-- =============================================
SELECT '=== ESTADO FINAL ===' AS 'RESUMEN';

-- Resumen de roles activos
SELECT 'Roles Activos:' AS 'RESUMEN';
CALL sp_crud_roles('READ_BY_STATUS', NULL, NULL, NULL, 'Activo', NULL);

-- Resumen de roles inactivos
SELECT 'Roles Inactivos:' AS 'RESUMEN';
CALL sp_crud_roles('READ_BY_STATUS', NULL, NULL, NULL, 'Inactivo', NULL);

-- Conteo total
SELECT 
    COUNT(*) as total_roles,
    SUM(CASE WHEN status = 'Activo' THEN 1 ELSE 0 END) as roles_activos,
    SUM(CASE WHEN status = 'Inactivo' THEN 1 ELSE 0 END) as roles_inactivos
FROM roles;