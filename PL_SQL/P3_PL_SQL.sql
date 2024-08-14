CREATE OR REPLACE PACKAGE PKG_CONSUMOS IS

    FUNCTION fn_total_consumos (p_id_cliente NUMBER) RETURN NUMBER;

    total_consumos NUMBER;

END PKG_CONSUMOS;

CREATE OR REPLACE PACKAGE BODY PKG_CONSUMOS IS

    FUNCTION fn_total_consumos (p_id_cliente NUMBER) RETURN NUMBER IS
    consumo_huesped NUMBER;
    
    BEGIN

        consumo_huesped := 0;
        SELECT SUM(MONTO) INTO consumo_huesped
        FROM CONSUMO
        WHERE id_huesped = p_id_cliente;

        RETURN consumo_huesped;
    END fn_total_consumos;

END PKG_CONSUMOS;

CREATE OR REPLACE FUNCTION fn_procedencia_huesped(p_id_huesped NUMBER) RETURN VARCHAR2 IS
    id_procedencia_h NUMBER;
    procedencia VARCHAR2(50);

    error_oracle ERRORES_PROCESO.MSG_ERROR%TYPE;
    msge_error ERRORES_PROCESO.NOMSUBPROGRAMA%TYPE;

    BEGIN
        SELECT id_procedencia INTO id_procedencia_h 
        FROM HUESPED
        WHERE id_huesped = p_id_huesped;

        SELECT nom_procedencia INTO procedencia
        FROM PROCEDENCIA
        WHERE id_procedencia = id_procedencia_h;

        RETURN procedencia;

        EXCEPTION WHEN OTHERS THEN  
            error_oracle := SQLERRM;
            msge_error := 'fn_procedencia_huesped';
            INSERT INTO ERRORES_PROCESO
            VALUES (SEQ_ERROR.NEXTVAL,'Error en la funcion: ' || ' ' || MSGE_ERROR, ERROR_ORACLE);
            RETURN 'NO REGISTRA PROCEDENCIA';
            
END fn_procedencia_huesped;

CREATE OR REPLACE FUNCTION fn_total_tours (p_id_huesped NUMBER) RETURN NUMBER IS
    id_tour NUMBER;
    num_personas NUMBER;
    total_tours NUMBER;
    valor_tour NUMBER;

    CURSOR cur_tour IS 
        SELECT id_tour, num_personas FROM HUESPED_TOUR WHERE id_huesped = p_id_huesped;
BEGIN
    total_tours := 0;
    FOR reg_tour IN cur_tour LOOP
        id_tour := reg_tour.id_tour;
        num_personas := reg_tour.num_personas;


        SELECT valor_tour INTO valor_tour FROM TOUR WHERE id_tour = reg_tour.id_tour;

        total_tours := total_tours + valor_tour * num_personas;
    END LOOP;

    RETURN total_tours;
END fn_total_tours;

CREATE OR REPLACE FUNCTION fn_nombre_huesped (p_id_huesped NUMBER) RETURN VARCHAR2 IS
    nombre VARCHAR2(50);
    apellidopat VARCHAR2(50);
    apellidomat VARCHAR2(50);
    nombre_completo VARCHAR2(100);

    BEGIN
        SELECT nom_huesped INTO nombre FROM HUESPED WHERE id_huesped = p_id_huesped;
        SELECT appat_huesped INTO apellidopat FROM HUESPED WHERE id_huesped = p_id_huesped;
        SELECT apmat_huesped INTO apellidomat FROM HUESPED WHERE id_huesped = p_id_huesped;

        nombre_completo := nombre || ' ' || apellidopat || ' ' || apellidomat;

        RETURN nombre_completo;
    END fn_nombre_huesped;

CREATE OR REPLACE TRIGGER trg_actualizar_huespedes_por_region
AFTER INSERT ON SALIDAS_DIARIAS_HUESPEDES
FOR EACH ROW
DECLARE
    f_id_region NUMBER;
    f_id_region_proc NUMBER;
    f_nom_region VARCHAR2(50);
    error_oracle ERRORES_PROCESO.MSG_ERROR%TYPE;
    msge_error ERRORES_PROCESO.NOMSUBPROGRAMA%TYPE;
BEGIN
    BEGIN
        -- Primer SELECT
        SELECT ID_PROCEDENCIA INTO f_id_region
        FROM HUESPED
        WHERE ID_HUESPED = :NEW.ID_HUESPED;
        
        -- Segundo SELECT
        SELECT id_region INTO f_id_region_proc
        FROM PROCEDENCIA
        WHERE ID_PROCEDENCIA = f_id_region;
        
        -- Tercer SELECT
        SELECT nom_region INTO f_nom_region
        FROM REGION
        WHERE ID_REGION = f_id_region_proc;

        -- Actualización
        UPDATE HUESPEDES_POR_REGION
        SET cantidad = cantidad + 1
        WHERE HUESPEDES_POR_REGION.nombre_region = f_nom_region;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            error_oracle := SQLERRM;
            msge_error := 'fn_procedencia_huesped';
            INSERT INTO ERRORES_PROCESO
            VALUES (SEQ_ERROR.NEXTVAL,'Error en el trigger para id ' || :NEW.ID_HUESPED || MSGE_ERROR, ERROR_ORACLE);
            DBMS_OUTPUT.PUT_LINE('No se encontraron datos para huesped ' || :NEW.ID_HUESPED);
    END;
END trg_actualizar_huespedes_por_region;


CREATE OR REPLACE PROCEDURE SP_SALIDAS_DIARIAS_HUESPED (fecha_salida DATE, valor_dolar NUMBER)
IS
    error_oracle ERRORES_PROCESO.MSG_ERROR%TYPE;
    msge_error ERRORES_PROCESO.NOMSUBPROGRAMA%TYPE;
    CURSOR CUR_SALIDAS IS SELECT * FROM RESERVA WHERE fecha_salida = (RESERVA.ingreso + RESERVA.estadia);
    id_alojamiento NUMBER;
    id_habitacion_alojamiento NUMBER;
    p_id_habitacion NUMBER;
    p_valor_habitacion NUMBER;
    p_valor_minibar NUMBER;
    dias_alojado NUMBER;
    total_alojamiento NUMBER;
    descuento NUMBER;
    DESCUENTO_PAIS NUMBER;
    consumo_huesped NUMBER;
    total_tours NUMBER;
    subtotal NUMBER;
    dscto_consumo NUMBER;
    total_dscto_consumo NUMBER;
    dscto_pais NUMBER;
    descto_total_pais NUMBER;
    total_final NUMBER;

BEGIN 
    EXECUTE IMMEDIATE 'TRUNCATE TABLE SALIDAS_DIARIAS_HUESPEDES';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ERRORES_PROCESO';

    FOR reg_salidas IN CUR_SALIDAS LOOP

      
        BEGIN
            
            dias_alojado := reg_salidas.estadia;

            BEGIN
                SELECT id_habitacion INTO id_habitacion_alojamiento 
                FROM detalle_reserva 
                WHERE id_reserva = reg_salidas.id_reserva;
            EXCEPTION
                WHEN OTHERS THEN
                    error_oracle := SQLERRM;
                    msge_error := 'fn_procedencia_huesped';
                    INSERT INTO ERRORES_PROCESO
                    VALUES (SEQ_ERROR.NEXTVAL,'Error, se encontro id de reserva duplicado: ' || reg_salidas.id_reserva || MSGE_ERROR, ERROR_ORACLE);
                    p_id_habitacion := 0;
                
            END;

            
                SELECT valor_habitacion INTO p_valor_habitacion FROM HABITACION WHERE id_habitacion = id_habitacion_alojamiento;
          
            
                SELECT valor_minibar INTO p_valor_minibar FROM HABITACION WHERE id_habitacion = id_habitacion_alojamiento;
        
            

            total_alojamiento := (p_valor_habitacion * reg_salidas.estadia) + (p_valor_minibar * reg_salidas.estadia);
            consumo_huesped := pkg_consumos.fn_total_consumos(reg_salidas.id_huesped);
            total_tours := fn_total_tours(reg_salidas.id_huesped);
            subtotal := total_alojamiento + consumo_huesped + total_tours;

            BEGIN
                SELECT pct INTO dscto_consumo
                FROM RANGOS_CONSUMOS
                WHERE consumo_huesped BETWEEN vmin_tramo AND vmax_tramo;
            EXCEPTION
                WHEN TOO_MANY_ROWS THEN
                    DBMS_OUTPUT.PUT_LINE('Too many rows for dscto_consumo');
                    dscto_consumo := 0;
                WHEN NO_DATA_FOUND THEN
                    DBMS_OUTPUT.PUT_LINE('No data found for dscto_consumo');
                    dscto_consumo := 0;
            END;

            total_dscto_consumo := consumo_huesped * dscto_consumo;

            IF fn_procedencia_huesped(reg_salidas.id_huesped) = 'ISLA DE MAN' THEN
                dscto_pais := subtotal * 0.10;
            ELSIF fn_procedencia_huesped(reg_salidas.id_huesped) = 'LIECHTENSTEIN' THEN
                descto_total_pais := subtotal * 0.20;
            ELSIF fn_procedencia_huesped(reg_salidas.id_huesped) = 'PAISES BAJOS' THEN
                descto_total_pais := subtotal * 0.20;
            ELSE
                descto_total_pais := 0;
            END IF;

            total_final := subtotal - total_dscto_consumo - descto_total_pais;

            INSERT INTO SALIDAS_DIARIAS_HUESPEDES
            VALUES(reg_salidas.id_huesped, fn_nombre_huesped(reg_salidas.id_huesped), fn_procedencia_huesped(reg_salidas.id_huesped),
                   total_alojamiento * valor_dolar, consumo_huesped * valor_dolar, total_tours * valor_dolar, subtotal * valor_dolar, total_dscto_consumo * valor_dolar, descto_total_pais * valor_dolar, total_final * valor_dolar); 

        END;

    END LOOP;

END SP_SALIDAS_DIARIAS_HUESPED;

SET SERVEROUTPUT ON;


EXEC SP_SALIDAS_DIARIAS_HUESPED(TO_DATE('16/10/2020', 'DD/MM/YYYY'), 890);

SELECT * FROM SALIDAS_DIARIAS_HUESPEDES;

SELECT * FROM HUESPEDES_POR_REGION;

SELECT * FROM ERRORES_PROCESO;