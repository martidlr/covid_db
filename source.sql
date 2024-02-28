DROP TABLE IF EXISTS sources.vaccination_centers;

CREATE TABLE sources.vaccination_centers (
    gid INT,
    nom VARCHAR(250),
    arrete_pref_numero  VARCHAR(250) ,
    xy_precis  VARCHAR(250) ,
    id_adr  VARCHAR(250) ,
    adr_num  VARCHAR(250) ,
    adr_voie  VARCHAR(250) ,
    com_cp  VARCHAR(250) ,
    com_insee  VARCHAR(250) ,
    com_nom  VARCHAR(250) ,
    lat_coor1  VARCHAR(250) ,
    long_coor1  VARCHAR(250) ,
    structure_siren  VARCHAR(250) ,
    structure_type  VARCHAR(250) ,
    structure_rais  VARCHAR(250) ,
    structure_num  VARCHAR(250) ,
    structure_voie  VARCHAR(250) ,
    structure_cp  VARCHAR(250) ,
    structure_insee  VARCHAR(250) ,
    structure_com  VARCHAR(250) ,
    _userid_creation  VARCHAR(250) ,
    _userid_modification  VARCHAR(250) ,
    _edit_datemaj VARCHAR(250) ,
    lieu_accessibilite  VARCHAR(250) ,
    rdv_lundi  VARCHAR(250) ,
    rdv_mardi  VARCHAR(250) ,
    rdv_mercredi  VARCHAR(250) ,
    rdv_jeudi  VARCHAR(250) ,
    rdv_vendredi  VARCHAR(250) ,
    rdv_samedi  VARCHAR(250) ,
    rdv_dimanche  VARCHAR(250) ,
    rdv  VARCHAR(250) ,
    date_fermeture  DATE ,
    date_ouverture  DATE ,
    rdv_site_web  VARCHAR(1000) ,
    rdv_tel  VARCHAR(250) ,
    rdv_tel2  VARCHAR(250) ,
    rdv_modalites  VARCHAR(1000) ,
    rdv_consultation_prevaccination  VARCHAR(250) ,
    centre_svi_repondeur  VARCHAR(250) ,
    centre_fermeture  VARCHAR(250) ,
    reserve_professionels_sante  VARCHAR(250) ,
    centre_type  VARCHAR(250) ,
    PRIMARY KEY (gid)
);

COPY sources.vaccination_centers(
    gid ,
    nom ,
    arrete_pref_numero ,
    xy_precis ,
    id_adr ,
    adr_num ,
    adr_voie ,
    com_cp ,
    com_insee ,
    com_nom ,
    lat_coor1 ,
    long_coor1 ,
    structure_siren ,
    structure_type ,
    structure_rais ,
    structure_num ,
    structure_voie ,
    structure_cp ,
    structure_insee ,
    structure_com ,
    _userid_creation ,
    _userid_modification ,
    _edit_datemaj ,
    lieu_accessibilite ,
    rdv_lundi ,
    rdv_mardi ,
    rdv_mercredi ,
    rdv_jeudi ,
    rdv_vendredi ,
    rdv_samedi ,
    rdv_dimanche ,
    rdv ,
    date_fermeture ,
    date_ouverture ,
    rdv_site_web ,
    rdv_tel ,
    rdv_tel2 ,
    rdv_modalites ,
    rdv_consultation_prevaccination ,
    centre_svi_repondeur ,
    centre_fermeture ,
    reserve_professionels_sante ,
    centre_type
)
FROM '/Users/martindelrieu/Downloads/cvdb/centres-vaccination.csv'
DELIMITER ';'
CSV HEADER;

DROP TABLE IF EXISTS sources.vaccinations_vs_appointments_by_center_by_week;

CREATE TABLE sources.vaccinations_vs_appointments_by_center_by_week (
    id_centre          INT,
    date_debut_semaine DATE,
    code_region        INT,
    nom_region         VARCHAR(250),
    code_departement   VARCHAR(250),
    nom_departement    VARCHAR(250),
    commune_insee      VARCHAR(250),
    nom_centre         VARCHAR(250),
    nombre_ucd         INT,
    doses_allouees     INT,
    rdv_pris           INT
);

COPY sources.vaccinations_vs_appointments_by_center_by_week(
    id_centre ,
    date_debut_semaine ,
    code_region ,
    nom_region ,
    code_departement ,
    nom_departement ,
    commune_insee ,
    nom_centre ,
    nombre_ucd ,
    doses_allouees ,
    rdv_pris
)
FROM '/Users/martindelrieu/Downloads/cvdb/allocations-vs-rdv.csv'
DELIMITER ','
CSV HEADER
ENCODING 'latin-1';

DROP TABLE IF EXISTS sources.appointments_by_center_by_week;

CREATE TABLE sources.appointments_by_center_by_week (
    code_region INT ,
    region VARCHAR(250) ,
    departement VARCHAR(250) ,
    id_centre VARCHAR(250) ,
    nom_centre VARCHAR(250) ,
    rang_vaccinal INT ,
    date_debut_semaine DATE,
    nb INT ,
    nb_rdv_cnam INT ,
    nb_rdv_rappel INT
);

COPY sources.appointments_by_center_by_week(
    code_region ,
    region ,
    departement ,
    id_centre ,
    nom_centre ,
    rang_vaccinal ,
    date_debut_semaine ,
    nb ,
    nb_rdv_cnam ,
    nb_rdv_rappel
)
FROM '/Users/martindelrieu/Downloads/cvdb/2021-12-02-prise-rdv-par-centre.csv'
DELIMITER ','
CSV HEADER
ENCODING 'latin-1';

DROP TABLE IF EXISTS sources.stocks;

CREATE TABLE sources.stocks (
    code_departement VARCHAR(250) ,
    departement VARCHAR(250) ,
    raison_sociale VARCHAR(250) ,
    libelle_pui VARCHAR(250) ,
    finess VARCHAR(250) ,
    type_de_vaccin VARCHAR(250) ,
    nb_ucd INT ,
    nb_doses INT ,
    date DATE
);

COPY sources.stocks(
    code_departement ,
    departement ,
    raison_sociale ,
    libelle_pui ,
    finess ,
    type_de_vaccin ,
    nb_ucd ,
    nb_doses ,
    date
)
FROM '/Users/martindelrieu/Downloads/cvdb/stocks-es-par-es.csv'
DELIMITER ','
CSV HEADER
ENCODING 'latin-1';

