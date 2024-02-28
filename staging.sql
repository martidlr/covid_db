DROP TABLE IF EXISTS staging.stg_vaccination_centers;

CREATE TABLE staging.stg_vaccination_centers AS (
      select
        -- Identification infos.
        gid,
        nom,
        left(com_cp, 2) as departement,

        -- Infos about center availability and
        -- appointment booking.
        date_ouverture as opening_date,
        date_fermeture as closing_date,
        -- TODO: parse these fields to know the exact opening hours of each day.
        --  Also, use jinja to iterate over a loop and make this code DRY.
        coalesce(
            rdv_lundi != 'fermé',
            -- We make the hypothesis that if null it's true.
            true
        ) as is_open_on_monday,
        coalesce(
            rdv_mardi != 'fermé',
            -- We make the hypothesis that if null it's true.
            true
        ) as is_open_on_tuesday,
        coalesce(
            rdv_mercredi != 'fermé',
            -- We make the hypothesis that if null it's true.
            true
        ) as is_open_on_wednesday,
        coalesce(
            rdv_jeudi != 'fermé',
            -- We make the hypothesis that if null it's true.
            true
        ) as is_open_on_thursday,
        coalesce(
            rdv_vendredi != 'fermé',
            -- We make the hypothesis that if null it's true.
            true
        ) as is_open_on_friday,
        coalesce(
            rdv_samedi != 'fermé',
            -- We make the hypothesis that if null it's true.
            true
        ) as is_open_on_saturday,
        coalesce(
            rdv_dimanche != 'fermé',
            -- We make the hypothesis that if null it's true.
            true
        ) as is_open_on_sunday,
        coalesce(
            rdv_site_web like '%doctolib%',
            false
        ) as is_with_doctolib,
        rdv_tel is not null as has_phone,

        -- Infos to check data freshness.
        cast(_edit_datemaj as timestamp) as updated_at
    from sources.vaccination_centers
    -- We remove fake centers.
    where cast(gid as varchar) not like '9900%'
);

DROP TABLE IF EXISTS staging.stg_vaccinations_vs_appointments_by_center_by_week;

CREATE TABLE staging.stg_vaccinations_vs_appointments_by_center_by_week AS (
    select
        id_centre as center_gid,
        date_debut_semaine as week,
        concat(
            id_centre,
            date_debut_semaine
        ) as surrogate_key,
        doses_allouees as nb_allocated_doses,
        rdv_pris as nb_booked_appointments
    from cvdb.sources.vaccinations_vs_appointments_by_center_by_week
);

DROP TABLE IF EXISTS staging.stg_appointments_by_center_by_week;

CREATE TABLE staging.stg_appointments_by_center_by_week AS (
    select
        id_centre as center_gid,
        date_debut_semaine as week,
        concat(
            id_centre,
            date_debut_semaine
        ) as surrogate_key,
        -- We make the hypothesis that for our use cases, we don't need to
        -- know the vaccination rank.
        sum(nb) as nb_booked_appointments
    from cvdb.sources.appointments_by_center_by_week
    group by 1, 2, 3
);

DROP TABLE IF EXISTS staging.stg_stocks;

CREATE TABLE staging.stg_stocks AS (
    select *
    from (
        select
            raison_sociale as storage_center_name,
            finess as storage_center_id,
            type_de_vaccin as vaccine_type,
            concat(
                finess,
                type_de_vaccin
            ) as surrogate_key,
            code_departement as departement,
            nb_doses,
            date as update_date,
            -- Only a few centers x vaccine types have 2 dates, so we only
            -- keep the last one for each.
            rank() over (
                partition by concat(
                    finess,
                    type_de_vaccin
                )
                order by date desc
            ) as rank
        from cvdb.sources.stocks
    ) as sub
    where rank = 1
);
