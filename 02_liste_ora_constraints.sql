SET LINESIZE 200
SET PAGESIZE 100
COLUMN table_name FORMAT A25
COLUMN constraint_name FORMAT A30
COLUMN constraint_type FORMAT A20
COLUMN columns FORMAT A40
COLUMN condition FORMAT A50
COLUMN references FORMAT A40

SELECT
    c.table_name,
    c.constraint_name,
    CASE c.constraint_type
        WHEN 'P' THEN 'PRIMARY KEY'
        WHEN 'R' THEN 'FOREIGN KEY'
        WHEN 'U' THEN 'UNIQUE'
        WHEN 'C' THEN 'CHECK'
        ELSE c.constraint_type
    END AS constraint_type,

    /* Colonnes concernées */
    LISTAGG(cc.column_name, ', ')
        WITHIN GROUP (ORDER BY cc.position) AS columns,

    /* Condition (pour CHECK) */
    c.search_condition AS condition,

    /* Référence (pour FOREIGN KEY) */
    CASE
        WHEN c.constraint_type = 'R' THEN
            (SELECT r.table_name
             FROM user_constraints r
             WHERE r.constraint_name = c.r_constraint_name)
        ELSE NULL
    END AS references

FROM user_constraints c
LEFT JOIN user_cons_columns cc
    ON c.constraint_name = cc.constraint_name

GROUP BY
    c.table_name,
    c.constraint_name,
    c.constraint_type,
    c.search_condition,
    c.r_constraint_name

ORDER BY
    c.table_name,
    constraint_type;
