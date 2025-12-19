SELECT
    (SELECT COUNT(*) FROM user_tables) AS "Nombre de tables",
    (SELECT COUNT(*) FROM user_constraints) AS "Nombre de contraintes",
    (SELECT COUNT(*) FROM user_triggers) AS "Nombre de triggers",
    (SELECT COUNT(*) FROM user_views) AS "Nombre de vues"
FROM dual;

