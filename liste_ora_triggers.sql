-- Liste tous les triggers définis classés par table


SELECT
    ut.table_name as "Nom de table",
    ut.trigger_name as "Nom de trigger",
    ut.triggering_event as "Evénement de déclenchement",
    ut.trigger_type as "Type de trigger",
    ut.status as "Statut",
    ut.description as "Description",
    ut.trigger_body as "Corps du trigger"
FROM user_triggers ut
ORDER BY
    ut.table_name,
    ut.trigger_name;

