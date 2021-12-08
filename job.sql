
--Таблица для получаемых докторов

create table LAZORENKO_AL.doctors_from_another_sys (doctor_fas_id number generated by default as identity
                    (start with 1 maxvalue 999999999999999 minvalue 1 nocycle nocache noorder) primary key,
                    id_doctor number,
                    id_hospital number,
                    id_speciality number,
                    lname varchar2(100),
                    fname varchar2(100),
                    mname varchar2(100)
                    );



--процедура для merge

 create or replace procedure lazorenko_al.merge_doctors(
v_item in lazorenko_al.t_doctor
)
as
    begin
        merge into lazorenko_al.doctors_from_another_sys a
        using (
        select 1 as id_doctor, 2 as id_hospital, 3 as Lname, 4 as fname, 5 as mname from dual
        ) b
        on (
        a.id_doctor = b.id_doctor
        )
    when not matched then
        insert (id_doctor, id_hospital, lname, fname, mname)
        values (v_item.doctor_id, v_item.hospital_id, v_item.name, v_item.fname, v_item.petronymic)
    when matched then update set a.id_hospital=b.id_hospital;
    end;

--итоговая процедура

create or replace procedure lazorenko_al.insert_incomming_doctors
as

    v_result integer;
    v_response lazorenko_al.t_arr_doctor := lazorenko_al.t_arr_doctor();

begin

    v_response := lazorenko_al.service_for_doctors(
        out_result => v_result
    );

    dbms_output.put_line(v_result);

    if v_response.count>0 then
    for i in v_response.first..v_response.last
    loop
        declare
            v_item lazorenko_al.t_doctor := v_response(i);
        begin
               lazorenko_al.merge_doctors(v_item);
        end;
    end loop;
    end if;

    --dbms_output.put_line(v_response.COUNT);
end;


begin
    lazorenko_al.insert_incomming_doctors();
    commit;
end;




--создание задачи
begin

    sys.dbms_scheduler.create_job(

        job_name        => 'lazorenko_al.job_cache_doctor',
        start_date      => to_timestamp_tz('2021/12/08 17:40:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzh:tzm'),
        repeat_interval => 'FREQ=HOURLY;INTERVAL=1;',
        end_date        => null,
        job_class       => 'DEFAULT_JOB_CLASS',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'begin lazorenko_al.insert_incomming_doctors(); end;',
        comments        => 'Кэширование'

    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_doctor',
        attribute => 'RESTARTABLE',
        value     => false
    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_doctor',
        attribute => 'RESTART_ON_RECOVERY',
        value     => false
    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_doctor',
        attribute => 'RESTART_ON_FAILURE',
        value     => false
    );

    sys.dbms_scheduler.set_attribute_null(
        name      => 'lazorenko_al.job_cache_doctor',
        attribute => 'MAX_FAILURES'
    );

    sys.dbms_scheduler.set_attribute_null(
        name      => 'lazorenko_al.job_cache_doctor',
        attribute => 'MAX_RUNS'
    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_doctor',
        attribute => 'LOGGING_LEVEL',
        value     => sys.dbms_scheduler.logging_full
    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_doctor',
        attribute => 'JOB_PRIORITY',
        value     => 3
    );

    sys.dbms_scheduler.set_attribute_null(
        name      => 'lazorenko_al.job_cache_doctor',
        attribute => 'SCHEDULE_LIMIT'
    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_doctor',
        attribute => 'AUTO_DROP',
        value     => false
    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_doctor',
        attribute => 'STORE_OUTPUT',
        value     => true
    );

end;
/

------------------------------------------------------------------------------------------------------------------------
--Таблица для получаемых больниц
create table LAZORENKO_AL.hospital_from_another_sys (hospital_fas_id number generated by default as identity
                    (start with 1 maxvalue 999999999999999 minvalue 1 nocycle nocache noorder) primary key,
                    id_hospital number,
                    name varchar2(100),
                    address varchar2(100),
                    id_town number
                    );

--процедура для merge

 create or replace procedure lazorenko_al.merge_hospitals(
v_item in lazorenko_al.t_hospitals
)
as
    begin
        merge into lazorenko_al.hospital_from_another_sys a
        using (
        select 1 as id_hospital, 2 as name, 3 as address, 4 as id_town from dual
        ) b
        on (a.id_hospital = b.id_hospital
        )
    when not matched then
        insert (id_hospital, name, address, id_town, "check")
        values (v_item.id_hospital, v_item.name, v_item.address, v_item.id_town, 1)
    when matched then update set a.id_town=b.id_town;
    end;

--итоговая процедура

create or replace procedure lazorenko_al.insert_incomming_hospitals
as

    v_result integer;
    v_response lazorenko_al.t_arr_hospitals := lazorenko_al.t_arr_hospitals();

begin

    v_response := lazorenko_al.service_for_hospitals(
        out_result => v_result
    );

    dbms_output.put_line(v_result);

    if v_response.count>0 then
    for i in v_response.first..v_response.last
    loop
        declare
            v_item lazorenko_al.t_hospitals := v_response(i);
        begin
               lazorenko_al.merge_hospitals(v_item);
        end;
    end loop;
    end if;

    --dbms_output.put_line(v_response.COUNT);
end;


begin
    lazorenko_al.insert_incomming_hospitals();
    commit;
end;




--создание задачи
begin

    sys.dbms_scheduler.create_job(

        job_name        => 'lazorenko_al.job_cache_hospital',

        start_date      => to_timestamp_tz('2021/12/08 17:40:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzh:tzm'),

        repeat_interval => 'FREQ=HOURLY;INTERVAL=1;',

        end_date        => null,

        job_class       => 'DEFAULT_JOB_CLASS',

        job_type        => 'PLSQL_BLOCK',

        job_action      => 'begin lazorenko_al.insert_incomming_hospitals(); end;',

        comments        => 'Кэширование'

    );
    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_hospital',
        attribute => 'RESTARTABLE',
        value     => false
    );
    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_hospital',
        attribute => 'RESTART_ON_RECOVERY',
        value     => false
    );
    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_hospital',
        attribute => 'RESTART_ON_FAILURE',
        value     => false
    );
    sys.dbms_scheduler.set_attribute_null(
        name      => 'lazorenko_al.job_cache_hospital',
        attribute => 'MAX_FAILURES'
    );
    sys.dbms_scheduler.set_attribute_null(
        name      => 'lazorenko_al.job_cache_hospital',
        attribute => 'MAX_RUNS'
    );
    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_hospital',
        attribute => 'LOGGING_LEVEL',
        value     => sys.dbms_scheduler.logging_full
    );
    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_hospital',
        attribute => 'JOB_PRIORITY',
        value     => 3
    );
    sys.dbms_scheduler.set_attribute_null(
        name      => 'lazorenko_al.job_cache_hospital',
        attribute => 'SCHEDULE_LIMIT'
    );
    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_hospital',
        attribute => 'AUTO_DROP',
        value     => false
    );
    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_hospital',
        attribute => 'STORE_OUTPUT',
        value     => true
    );

end;





------------------------------------------------------------------------------------------------------------------------

--Таблица для получаемых специальностей

create table LAZORENKO_AL.specs_from_another_sys (spec_fas_id number generated by default as identity
                    (start with 1 maxvalue 999999999999999 minvalue 1 nocycle nocache noorder) primary key,
                    id_specialty number,
                    name varchar2(100),
                    id_hospital number
                    );

--процедура для merge

 create or replace procedure lazorenko_al.merge_specs(
v_item in lazorenko_al.t_new_specs
)
as
    begin
        merge into lazorenko_al.specs_from_another_sys a
        using (
        select 1 as id_specialty, 2 as name, 3 as id_hospital from dual
        ) b
        on (
        a.id_specialty = b.id_specialty
        )
    when not matched then
        insert (id_specialty, name, id_hospital)
        values (v_item.id_specialty, v_item.name, v_item.id_hospital)
    when matched then update set a.id_hospital=b.id_hospital;
    end;

--итоговая процедура

create or replace procedure lazorenko_al.insert_incomming_specs
as

    v_result integer;
    v_response lazorenko_al.t_arr_new_specs := lazorenko_al.t_arr_new_specs();

begin

    v_response := lazorenko_al.service_for_specs(
        out_result => v_result
    );

    dbms_output.put_line(v_result);

    if v_response.count>0 then
    for i in v_response.first..v_response.last
    loop
        declare
            v_item lazorenko_al.t_new_specs := v_response(i);
        begin
               lazorenko_al.merge_specs(v_item);
        end;
    end loop;
    end if;

    --dbms_output.put_line(v_response.COUNT);
end;


begin
    lazorenko_al.insert_incomming_specs();
    commit;
end;




--создание задачи
begin

    sys.dbms_scheduler.create_job(

        job_name        => 'lazorenko_al.job_cache_specs',

        start_date      => to_timestamp_tz('2021/12/08 17:40:00.000000 +07:00','yyyy/mm/dd hh24:mi:ss.ff tzh:tzm'),

        repeat_interval => 'FREQ=HOURLY;INTERVAL=1;',

        end_date        => null,

        job_class       => 'DEFAULT_JOB_CLASS',

        job_type        => 'PLSQL_BLOCK',

        job_action      => 'begin lazorenko_al.insert_incomming_specs(); end;',

        comments        => 'Кэширование'

    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_specs',
        attribute => 'RESTARTABLE',
        value     => false
    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_specs',
        attribute => 'RESTART_ON_RECOVERY',
        value     => false
    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_specs',
        attribute => 'RESTART_ON_FAILURE',
        value     => false
    );

    sys.dbms_scheduler.set_attribute_null(
        name      => 'lazorenko_al.job_cache_specs',
        attribute => 'MAX_FAILURES'
    );

    sys.dbms_scheduler.set_attribute_null(
        name      => 'lazorenko_al.job_cache_specs',
        attribute => 'MAX_RUNS'
    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_specs',
        attribute => 'LOGGING_LEVEL',
        value     => sys.dbms_scheduler.logging_full
    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_specs',
        attribute => 'JOB_PRIORITY',
        value     => 3
    );

    sys.dbms_scheduler.set_attribute_null(
        name      => 'lazorenko_al.job_cache_specs',
        attribute => 'SCHEDULE_LIMIT'
    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_specs',
        attribute => 'AUTO_DROP',
        value     => false
    );

    sys.dbms_scheduler.set_attribute(
        name      => 'lazorenko_al.job_cache_specs',
        attribute => 'STORE_OUTPUT',
        value     => true
    );

end;

