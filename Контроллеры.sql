--контроллер - запись

create or replace function lazorenko_al.json_record(
    p_ticket_id number,
    p_patient_id number,
    p_spec_id number,
    p_doctor_id number,
    p_hospital_id number,
    p_need_handle boolean
)
return clob
as

    v_result integer;
    v_response lazorenko_al.t_record;
    v_json json_object_t := json_object_t();
    v_json_response json_array_t := json_array_t();
    v_return_clob clob;

begin

    v_response := lazorenko_al.service_for_records(
        p_ticket_id => p_ticket_id,
        p_patient_id => p_patient_id,
        p_spec_id => p_spec_id,
        p_doctor_id => p_doctor_id,
        p_hospital_id => p_hospital_id,
        p_need_handle => p_need_handle,
        out_fail => v_result
    );

    v_json.put('code', v_result);

    if v_response.patient_id is not null then
    declare

        v_object json_object_t := json_object_t();
    begin
        v_object.put('record_id', v_response.record_id);
        v_object.put('record_stat_id', v_response.record_stat_id);
        v_object.put('ticket_id', v_response.ticket_id);
        v_object.put('patient_id', v_response.patient_id);

        v_json_response.append(v_object);
    end;
    end if;

    v_json.put('response', v_json_response);
    v_return_clob := v_json.to_Clob();

    return v_return_clob;

end;



--его применение

declare

    v_clob clob;

begin

    v_clob := lazorenko_al.json_record(33, 3, 3, 3, 4, true);

    dbms_output.put_line(v_clob);

end;


--контроллер - отмена записи

create or replace function lazorenko_al.json_cancel(
    p_ticket_id number,
    p_patient_id number,
    p_hospital_id number
)
return clob
as

    v_result integer;
    v_response lazorenko_al.t_record;
    v_json json_object_t := json_object_t();
    v_json_response json_array_t := json_array_t();
    v_return_clob clob;

begin

    v_response := lazorenko_al.service_for_cancel(
        p_ticket_id => p_ticket_id,
        p_patient_id => p_patient_id,
        p_hospital_id => p_hospital_id,
        out_fail => v_result
    );

    v_json.put('code', v_result);

    if v_response.patient_id is not null then
    declare
        v_object json_object_t := json_object_t();
    begin
        v_object.put('record_id', v_response.record_id);
        v_object.put('record_stat_id', v_response.record_stat_id);
        v_object.put('ticket_id', v_response.ticket_id);
        v_object.put('patient_id', v_response.patient_id);

        v_json_response.append(v_object);
    end;
    end if;

    v_json.put('response', v_json_response);

    v_return_clob := v_json.to_Clob();

    return v_return_clob;

end;


--его примеение

declare

    v_clob clob;

begin

    v_clob := lazorenko_al.json_cancel(33, 3, 4);

    dbms_output.put_line(v_clob);

end;