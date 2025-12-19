SELECT
    name AS "Objet",
    type AS "Type d'objet",
    referenced_name AS "Dépend de",
    referenced_type AS "Type référencé"
FROM user_dependencies
ORDER BY name;
