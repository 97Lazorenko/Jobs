/*
 PARSING
 */

create or replace type lazorenko_al.t_doctor as object(
    doctor_id number,
    hospital_id number,
    name varchar(100),
    fname varchar(50),
    petronymic varchar2(50)
);

create or replace type lazorenko_al.t_arr_doctor as table of lazorenko_al.t_doctor;



--сервис доктора
create or replace function lazorenko_al.service_for_doctors(
    out_result out number
)
return lazorenko_al.t_arr_doctor
as

    v_result integer;
    v_clob clob;
    v_response lazorenko_al.t_arr_doctor := lazorenko_al.t_arr_doctor();

begin

    v_clob := lazorenko_al.pkg_doctor_repository.repository(
        out_result => v_result
    );


    select lazorenko_al.t_doctor(
        doctor_id => r.id_doctor,
        hospital_id => r.id_hospital,
        name => r.lname,
        fname => r.fname,
        petronymic => r.mname
    )
    bulk collect into v_response
    from json_table(v_clob, '$' columns(
        nested path '$[*]' columns(
            id_doctor number path '$.id_doctor',
            id_hospital number path '$.id_hospital',
            lname varchar2(100) path '$.lname',
            fname varchar2(100) path '$.fname',
            mname varchar2(100) path '$.mname'
    ))) r;

    out_result := v_result;

    return v_response;

end;
/


--его применение

declare

    v_result integer;
    v_response lazorenko_al.t_arr_doctor := lazorenko_al.t_arr_doctor();

begin

    v_response := lazorenko_al.service_for_doctors(
        out_result => v_result
    );

    if v_response.count>0 then
    for i in v_response.first..v_response.last
    loop
        declare
            v_item lazorenko_al.t_doctor := v_response(i);
        begin
            dbms_output.put_line('id врача: '||v_item.doctor_id ||'  '||'id больницы: '||v_item.hospital_id||'  '||'ФИО: '|| v_item.name|| ' '||v_item.fname||' '||v_item.petronymic);
        end;
    end loop;
    end if;

end;


--сервис больницы
create or replace function lazorenko_al.service_for_hospitals(
    out_result out number
)
return lazorenko_al.t_arr_hospitals
as

    v_result integer;
    v_clob clob;
    v_response lazorenko_al.t_arr_hospitals := lazorenko_al.t_arr_hospitals();

begin

    v_clob := lazorenko_al.pkg_hospital_repository.repository_hospitals(
        out_result => v_result
    );


    select lazorenko_al.t_hospitals(
        id_hospital => r.id_hospital,
        name => r.name,
        address => r.address,
        id_town => r.id_town
    )
    bulk collect into v_response
    from json_table(v_clob, '$' columns(
        nested path '$[*]' columns(
            id_hospital number path '$.id_hospital',
            name varchar2(100) path '$.name',
            address varchar2(100) path '$.address',
            id_town number path '$.id_town'
    ))) r;

    out_result := v_result;

    return v_response;

end;

--его применение

declare

    v_result integer;
    v_response lazorenko_al.t_arr_hospitals := lazorenko_al.t_arr_hospitals();

begin

    v_response := lazorenko_al.service_for_hospitals(
        out_result => v_result
    );

    if v_response.count>0 then
    for i in v_response.first..v_response.last
    loop
        declare
            v_item lazorenko_al.t_hospitals := v_response(i);
        begin
            dbms_output.put_line('id больницы: '||v_item.id_hospital ||'  '||'название больницы: '||v_item.name||'  '||'адрес: '|| v_item.address|| ';  id города:'||v_item.id_town);
        end;
    end loop;
    end if;

end;



--сервис специальностей

create or replace function lazorenko_al.service_for_specs(
    out_result out number
)
return lazorenko_al.t_arr_new_specs
as

    v_result integer;
    v_clob clob;
    v_response lazorenko_al.t_arr_new_specs := lazorenko_al.t_arr_new_specs();

begin

    v_clob := lazorenko_al.pkg_specs_repository.repository_specs(
        out_result => v_result
    );


    select lazorenko_al.t_new_specs(
        id_specialty => r.id_specialty,
        name => r.name,
        id_hospital => r.id_hospital
    )
    bulk collect into v_response
    from json_table(v_clob, '$' columns(
        nested path '$[*]' columns(
            id_specialty number path '$.id_specialty',
            name varchar2(100) path '$.name',
            id_hospital number path '$.id_hospital'
    ))) r;

    out_result := v_result;

    return v_response;

end;



declare

    v_result integer;
    v_response lazorenko_al.t_arr_new_specs := lazorenko_al.t_arr_new_specs();

begin

    v_response := lazorenko_al.service_for_specs(
        out_result => v_result
    );

    if v_response.count>0 then
    for i in v_response.first..v_response.last
    loop
        declare
            v_item lazorenko_al.t_new_specs := v_response(i);
        begin
            dbms_output.put_line('id специальности: '||v_item.id_hospital ||'  '||'название специальности: '||v_item.name||'  '||'id больницы:'||v_item.id_hospital);
        end;
    end loop;
    end if;

end;