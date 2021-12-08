--пакет с репозиторием докторов
create or replace package lazorenko_al.pkg_doctor_repository
as
    function repository(
    out_result out number
    )
    return clob;
end;

--его тело
create or replace package body lazorenko_al.pkg_doctor_repository
as
    function repository(
    out_result out number
    )
    return clob
    as

    v_success boolean;
    v_code number;
    v_clob clob;

    begin

    v_clob := lazorenko_al.HTTP_FETCH(
        p_url => 'http://virtserver.swaggerhub.com/AntonovAD/DoctorDB/1.0.0/doctors',
        p_debug => true,
        out_success => v_success,
        out_code => v_code
    );

    out_result := case when v_success
        then lazorenko_al.pkg_code.c_ok
        else lazorenko_al.pkg_code.c_error
    end;

    return v_clob;

    end;
end;


--пакет с репозиторием больниц
create or replace package lazorenko_al.pkg_hospital_repository
as
    function repository_hospitals(
    out_result out number
    )
    return clob;
end;

--его тело
create or replace package body lazorenko_al.pkg_hospital_repository
as
    function repository_hospitals(
    out_result out number
    )
    return clob
    as

    v_success boolean;
    v_code number;
    v_clob clob;

    begin

    v_clob := lazorenko_al.HTTP_FETCH(
        p_url => 'http://virtserver.swaggerhub.com/AntonovAD/DoctorDB/1.0.0/hospitals',
        p_debug => true,
        out_success => v_success,
        out_code => v_code
    );

    out_result := case when v_success
        then lazorenko_al.pkg_code.c_ok
        else lazorenko_al.pkg_code.c_error
    end;

    return v_clob;

    end;
end;


--пакет с репозиторием специальностей
create or replace package lazorenko_al.pkg_specs_repository
as
    function repository_specs(
    out_result out number
    )
    return clob;
end;

--его тело
create or replace package body lazorenko_al.pkg_specs_repository
as
    function repository_specs(
    out_result out number
    )
    return clob
    as

    v_success boolean;
    v_code number;
    v_clob clob;

    begin

    v_clob := lazorenko_al.HTTP_FETCH(
        p_url => 'http://virtserver.swaggerhub.com/AntonovAD/DoctorDB/1.0.0/specialties',
        p_debug => true,
        out_success => v_success,
        out_code => v_code
    );

    out_result := case when v_success
        then lazorenko_al.pkg_code.c_ok
        else lazorenko_al.pkg_code.c_error
    end;

    return v_clob;

    end;
end;


--пакет с репозиториями записи/отмены записи
create or replace package lazorenko_al.pkg_write_or_cancel_repository
as

    function repository_recording(
    p_ticket_id number,
    p_patient_id number
    )
    return lazorenko_al.t_result;

    function repository_cancel_record(
    p_ticket_id number
    )
    return lazorenko_al.t_result;

end;

--тело пакета
create or replace package body lazorenko_al.pkg_write_or_cancel_repository
as
    function repository_recording(
    p_ticket_id number,
    p_patient_id number
    )
    return lazorenko_al.t_result as
        v_result lazorenko_al.t_result;

    begin
        v_result:=lazorenko_al.pkg_write_or_cancel.write_to_records(
        p_patient_id => p_patient_id,
        p_ticket_id => p_ticket_id,
        p_need_handle => true
    );
    return v_result;

    end;

    function repository_cancel_record(
    p_ticket_id number
    )
    return lazorenko_al.t_result as
        v_result lazorenko_al.t_result;

    begin
        v_result:=lazorenko_al.pkg_write_or_cancel.cancel_record(
        p_ticket_id => p_ticket_id
        );
    return v_result;

    end;
end;

--пакет с проверками условий перед записью
create or replace package lazorenko_al.pkg_check_before_write_repository
as
    function repository_with_checks(
    p_ticket_id number,
    p_patient_id number,
    p_spec_id number,
    p_doctor_id number,
    p_hospital_id number,
    out_result out number
    )
    return number;
end;

--его тело
create or replace package body lazorenko_al.pkg_check_before_write_repository
as
    function repository_with_checks(
    p_ticket_id number,
    p_patient_id number,
    p_spec_id number,
    p_doctor_id number,
    p_hospital_id number,
    out_result out number
    )
    return number
    as v_result boolean;

    begin

    v_result:=lazorenko_al.check_for_accept_with_exceptions(
    p_ticket_id => p_ticket_id,
    p_patient_id => p_patient_id,
    p_spec_id => p_spec_id,
    p_doctor_id => p_doctor_id,
    p_hospital_id => p_hospital_id);

    out_result := case when sys.diutil.bool_to_int(v_result)>0
        then lazorenko_al.pkg_code.c_ok
        else lazorenko_al.pkg_code.c_error
    end;

    return out_result;

    end;

end;

--пакет с проверками условий перед отменой записи
create or replace package lazorenko_al.pkg_check_before_cancel_repository
as
    function repository_with_checks_before_cancel(
    p_hospital_id number,
    p_ticket_id number,
    p_patient_id number,
    out_result out number
    )
    return number;
end;

--его тело
create or replace package body lazorenko_al.pkg_check_before_cancel_repository
as
    function repository_with_checks_before_cancel(
    p_hospital_id number,
    p_ticket_id number,
    p_patient_id number,
    out_result out number
    )
    return number
    as v_result boolean;

    begin

    v_result:=lazorenko_al.check_cancel(
    p_hospital_id => p_hospital_id,
    p_ticket_id => p_ticket_id,
    p_patient_id => p_patient_id);

    out_result := case when sys.diutil.bool_to_int(v_result)>0
        then lazorenko_al.pkg_code.c_ok
        else lazorenko_al.pkg_code.c_error
    end;

    return out_result;

    end;
end;