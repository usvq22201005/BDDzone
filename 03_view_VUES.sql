SELECT view_name
FROM user_views;

DROP VIEW V_VENTE_CLIENT ;
DROP VIEW  V_SOUHAITACHAT_CLIENT ;
DROP VIEW  V_RECOMMANDATION_PRODUIT ;
DROP VIEW V_vente_fournisseur :
DROP ALL VIEW ;
select * from fournisseur ;


-- Source - https://stackoverflow.com/a
-- Posted by Agricola
-- Retrieved 2025-12-18, License - CC BY-SA 3.0

begin
  for i in (select view_name from user_views) loop
    execute immediate 'drop view ' || i.view_name;
  end loop;
end;
/