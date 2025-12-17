begin
  for t in (select table_name from user_tables) loop
    execute immediate 'drop table ' || t.table_name || ' cascade constraints';
  end loop;
end;