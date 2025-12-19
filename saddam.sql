BEGIN
   FOR r IN (SELECT table_name FROM user_tables) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE ' || r.table_name || ' CASCADE CONSTRAINTS';
   END LOOP;
END;
/

BEGIN
   FOR r IN (SELECT sequence_name FROM user_sequences) LOOP
      EXECUTE IMMEDIATE 'DROP SEQUENCE ' || r.sequence_name;
   END LOOP;
END;
/

-- Pour les procÃ©dures et fonctions
BEGIN
   FOR r IN (SELECT object_name, object_type FROM user_objects WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'VIEW')) LOOP
      EXECUTE IMMEDIATE 'DROP ' || r.object_type || ' ' || r.object_name;
   END LOOP;
END;
/

PURGE RECYCLEBIN;