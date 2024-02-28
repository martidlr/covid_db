-- Primary key tests.

select
    surrogate_key,
    count(*)
from staging.stg_vaccinations_vs_appointments_by_center_by_week
group by 1
having count(*) > 1;

select
    surrogate_key,
    count(*)
from staging.stg_appointments_by_center_by_week
group by 1
having count(*) > 1;

select
    surrogate_key,
    count(*)
from staging.stg_stocks
group by 1
having count(*) > 1;


-- Foreign key and non-null tests on center_gid.

select *
from staging.stg_vaccinations_vs_appointments_by_center_by_week
where coalesce(center_gid, 0) not in (
    select distinct gid
    from staging.stg_vaccination_centers
);

-- We find anomalies, that we will remove in the marts.appointments_by_center_by_week.
select *
from staging.stg_appointments_by_center_by_week
where coalesce(center_gid, '') not in (
    select distinct cast(gid as varchar)
    from staging.stg_vaccination_centers
);
