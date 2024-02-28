DROP TABLE IF EXISTS marts.vaccination_centers;

CREATE TABLE marts.vaccination_centers AS (
    select
        *,
        case
            when
                -- If the center is with Doctolib but has a phone number, we consider
                -- that 80% of its appointments are booked via Doctolib, 20% via phone.
                is_with_doctolib
                and has_phone
                then 0.8
            when
                is_with_doctolib
                and not has_phone
                then 1
            else 0
        end as estimated_pct_appointments_from_doctolib
    from staging.stg_vaccination_centers
);

DROP TABLE IF EXISTS marts.open_vaccination_centers_by_day;

CREATE TABLE marts.open_vaccination_centers_by_day AS (
    select
        date_range.date,
        count(*) as nb_open_vaccination_centers,
        count(
            case
                when vaccination_centers.is_with_doctolib
                then vaccination_centers.gid
            end
        ) as nb_open_vaccination_centers_with_doctolib
    from (
        SELECT day::date as date
        FROM generate_series(
            timestamp '2020-08-30',
            current_date,
            '1 day'
        ) day
    ) as date_range
    left join marts.vaccination_centers
        on
            -- If no opening date, we make the hypothesis that this center
            -- was open since 2020-08-30 (first opening date in the data).
            date_range.date >= coalesce(vaccination_centers.opening_date, '2020-08-30')
            and date_range.date <= coalesce(vaccination_centers.closing_date, current_date)
    group by 1
);

DROP TABLE IF EXISTS marts.appointments_by_center_by_week;

CREATE TABLE marts.appointments_by_center_by_week AS (
    select
        -- Since we remove the center_gid that are not in marts.vaccination_centers,
        -- we can convert this column to integer.
        cast(appointments.center_gid as integer) as center_gid,
        appointments.week,
        appointments.surrogate_key,
        appointments.nb_booked_appointments,
        round(
            appointments.nb_booked_appointments
            * vaccination_centers.estimated_pct_appointments_from_doctolib,
            0
        ) as estimated_nb_booked_appointments_from_doctolib
    from staging.stg_appointments_by_center_by_week as appointments
    inner join marts.vaccination_centers
        on appointments.center_gid = cast(vaccination_centers.gid as varchar)
);

DROP TABLE IF EXISTS marts.vaccinations_vs_appointments_by_center_by_week;

CREATE TABLE marts.vaccinations_vs_appointments_by_center_by_week AS (
    select
        vacc_vs_app.center_gid,
        vacc_vs_app.week,
        -- To know, the quality of doses allocation in centers with Doctolib vs centers
        -- without Doctolib.
        vaccination_centers.is_with_doctolib,
        vacc_vs_app.nb_allocated_doses,
        vacc_vs_app.nb_booked_appointments,
        coalesce(
            vacc_vs_app.nb_allocated_doses < vacc_vs_app.nb_booked_appointments,
            false
        ) as is_missing_doses
    from staging.stg_vaccinations_vs_appointments_by_center_by_week as vacc_vs_app
    inner join marts.vaccination_centers
        on vacc_vs_app.center_gid = vaccination_centers.gid
);

DROP TABLE IF EXISTS marts.stocks;

CREATE TABLE marts.stocks AS (
    select *
    from staging.stg_stocks
);
