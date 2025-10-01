-- VISTA PARA VER ROLES CON INFORMACIÓN COMPLETA
CREATE VIEW vw_roles_completo AS
SELECT 
    id_rol,
    nombre_rol,
    descripcion,
    fecha_creacion,
    fecha_actualizacion,
    status,
    CASE 
        WHEN status = 'Activo' THEN '🟢 ACTIVO'
        ELSE '🔴 INACTIVO'
    END as status_icono,
    DATEDIFF(NOW(), fecha_creacion) as dias_desde_creacion,
    CASE 
        WHEN DATEDIFF(NOW(), fecha_actualizacion) = 0 THEN 'Hoy'
        WHEN DATEDIFF(NOW(), fecha_actualizacion) = 1 THEN 'Ayer'
        ELSE CONCAT(DATEDIFF(NOW(), fecha_actualizacion), ' días')
    END as ultima_actualizacion
FROM roles
ORDER BY status DESC, nombre_rol;

-- USAR LA VISTA
SELECT * FROM vw_roles_completo;

-- FILTRAR SOLO ROLES ACTIVOS
SELECT * FROM vw_roles_completo WHERE status = 'Activo';

-- FILTRAR SOLO ROLES INACTIVOS (ELIMINADOS)
SELECT * FROM vw_roles_completo WHERE status = 'Inactivo';