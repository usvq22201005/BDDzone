-- Liste tous les triggers définis classés par table


SELECT
    ut.table_name AS "Nom de table",
    ut.triggering_event AS "Evénement de déclenchement",
    ut.trigger_type AS "Type de trigger",
    ut.status AS "Statut",
    ut.description AS "Description",
    ut.trigger_body AS "Corps du trigger"
FROM user_triggers ut
ORDER BY
    ut.table_name,
    ut.trigger_name;


