DELIMITER //

CREATE PROCEDURE sp_crud_roles(
    IN p_operacion ENUM('CREATE', 'READ', 'READ_BY_ID', 'READ_BY_STATUS', 'SEARCH', 'UPDATE', 'DELETE', 'REACTIVAR', 'CHECK_EMPLOYEES'),
    IN p_id_rol INT,
    IN p_nombre_rol VARCHAR(50),
    IN p_descripcion TEXT,
    IN p_status ENUM('Activo','Inactivo'),
    IN p_busqueda VARCHAR(50)
)
BEGIN
    DECLARE v_rol_existe INT DEFAULT 0;
    DECLARE v_nombre_duplicado INT DEFAULT 0;
    DECLARE v_rol_en_uso INT DEFAULT 0;
    
    -- OPERACIÓN CREATE
    IF p_operacion = 'CREATE' THEN
        -- Verificar si el rol ya existe
        SELECT COUNT(*) INTO v_rol_existe 
        FROM roles 
        WHERE nombre_rol = p_nombre_rol AND status = 'Activo';
        
        IF v_rol_existe > 0 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Error: Ya existe un rol activo con ese nombre';
        ELSE
            INSERT INTO roles (nombre_rol, descripcion, status)
            VALUES (p_nombre_rol, p_descripcion, p_status);
            
            SELECT 
                'Rol creado exitosamente' AS mensaje, 
                LAST_INSERT_ID() AS id_rol,
                p_nombre_rol AS nombre_rol,
                p_status AS status;
        END IF;
    
    -- OPERACIÓN READ (Todos los roles)
    ELSEIF p_operacion = 'READ' THEN
        SELECT 
            id_rol,
            nombre_rol,
            descripcion,
            fecha_creacion,
            fecha_actualizacion,
            status
        FROM roles 
        ORDER BY status DESC, nombre_rol;
    
    -- OPERACIÓN READ_BY_ID (Rol específico)
    ELSEIF p_operacion = 'READ_BY_ID' THEN
        SELECT 
            id_rol,
            nombre_rol,
            descripcion,
            fecha_creacion,
            fecha_actualizacion,
            status
        FROM roles 
        WHERE id_rol = p_id_rol;
        
        IF FOUND_ROWS() = 0 THEN
            SELECT 'Rol no encontrado' AS mensaje;
        END IF;
    
    -- OPERACIÓN READ_BY_STATUS (Filtrar por status)
    ELSEIF p_operacion = 'READ_BY_STATUS' THEN
        SELECT 
            id_rol,
            nombre_rol,
            descripcion,
            fecha_creacion,
            fecha_actualizacion,
            status
        FROM roles 
        WHERE status = p_status
        ORDER BY nombre_rol;
    
    -- OPERACIÓN SEARCH (Búsqueda por nombre)
    ELSEIF p_operacion = 'SEARCH' THEN
        SELECT 
            id_rol,
            nombre_rol,
            descripcion,
            fecha_creacion,
            fecha_actualizacion,
            status
        FROM roles 
        WHERE nombre_rol LIKE CONCAT('%', p_busqueda, '%')
        ORDER BY status DESC, nombre_rol;
    
    -- OPERACIÓN UPDATE
    ELSEIF p_operacion = 'UPDATE' THEN
        -- Verificar si el rol existe
        SELECT COUNT(*) INTO v_rol_existe FROM roles WHERE id_rol = p_id_rol;
        
        IF v_rol_existe = 0 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Error: El rol no existe';
        ELSE
            -- Verificar si el nombre ya existe en otro rol activo
            SELECT COUNT(*) INTO v_nombre_duplicado 
            FROM roles 
            WHERE nombre_rol = p_nombre_rol 
            AND id_rol != p_id_rol 
            AND status = 'Activo';
            
            IF v_nombre_duplicado > 0 THEN
                SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Error: Ya existe otro rol activo con ese nombre';
            ELSE
                UPDATE roles 
                SET 
                    nombre_rol = p_nombre_rol,
                    descripcion = p_descripcion,
                    status = p_status,
                    fecha_actualizacion = CURRENT_TIMESTAMP
                WHERE id_rol = p_id_rol;
                
                SELECT 
                    'Rol actualizado exitosamente' AS mensaje,
                    p_id_rol AS id_rol,
                    p_nombre_rol AS nombre_rol,
                    p_status AS status;
            END IF;
        END IF;
    
    -- OPERACIÓN DELETE (Eliminación lógica)
    ELSEIF p_operacion = 'DELETE' THEN
        -- Verificar si el rol existe
        SELECT COUNT(*) INTO v_rol_existe FROM roles WHERE id_rol = p_id_rol;
        
        IF v_rol_existe = 0 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Error: El rol no existe';
        ELSE
            -- Verificar si el rol está siendo usado por empleados
            SELECT COUNT(*) INTO v_rol_en_uso 
            FROM empleados 
            WHERE rol_id = p_id_rol AND status = 'Activo';
            
            IF v_rol_en_uso > 0 THEN
                SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Error: No se puede eliminar el rol, está asignado a empleados activos';
            ELSE
                -- Eliminación lógica (cambiar status a Inactivo)
                UPDATE roles 
                SET status = 'Inactivo', 
                    fecha_actualizacion = CURRENT_TIMESTAMP 
                WHERE id_rol = p_id_rol;
                
                SELECT 
                    'Rol eliminado lógicamente (status cambiado a Inactivo)' AS mensaje,
                    p_id_rol AS id_rol;
            END IF;
        END IF;
    
    -- OPERACIÓN REACTIVAR
    ELSEIF p_operacion = 'REACTIVAR' THEN
        -- Verificar si el rol existe
        SELECT COUNT(*) INTO v_rol_existe FROM roles WHERE id_rol = p_id_rol;
        
        IF v_rol_existe = 0 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Error: El rol no existe';
        ELSE
            UPDATE roles 
            SET status = 'Activo', 
                fecha_actualizacion = CURRENT_TIMESTAMP 
            WHERE id_rol = p_id_rol;
            
            SELECT 
                'Rol reactivado exitosamente' AS mensaje,
                p_id_rol AS id_rol;
        END IF;
    
    -- OPERACIÓN CHECK_EMPLOYEES (Verificar empleados por rol)
    ELSEIF p_operacion = 'CHECK_EMPLOYEES' THEN
        SELECT 
            e.id_empleado,
            CONCAT(e.nombres, ' ', e.apellidos) AS nombre_completo,
            e.username,
            e.CURP,
            e.fecha_ingreso,
            e.status as status_empleado
        FROM empleados e
        WHERE e.rol_id = p_id_rol
        ORDER BY e.status DESC, e.apellidos, e.nombres;
        
        IF FOUND_ROWS() = 0 THEN
            SELECT 'No hay empleados asignados a este rol' AS mensaje;
        END IF;
    
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Operación no válida';
    END IF;
    
END //

DELIMITER ;