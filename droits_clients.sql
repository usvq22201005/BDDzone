-- Droit CLIENT : Réalisé par Yusuf DUMLUPINAR et AURORE GIROD

-- Création des rôles 
CREATE ROLE role_client;
CREATE ROLE role_fournisseur;
CREATE ROLE role_admin;

-- Les Clients On tout les droit sur le Panier
GRANT SELECT, INSERT, UPDATE, DELETE
ON Vue_Client_Panier
TO role_client;

-- Les CLients peuevent seulement lire les arctilcles recommandés
GRANT SELECT
ON Vue_Client_Articles_Recommandes
TO role_client;

-- Les Clients peuvent seuelement lire l'Historique des recommandations
GRANT SELECT
ON Vue_Client_Historique_Recommandations
TO role_client;

-- Les Clients peuvent seuelement lire les dépenses
GRANT SELECT
ON Vue_Client_Depenses_Totales
TO role_client;

-- Les Clients on tout les droits sur les Favoris
GRANT SELECT, INSERT, DELETE
ON Vue_Client_Favoris
TO role_client;

-- les Clients peuevent seulement lire les articles les mieux notés
GRANT SELECT
ON Vue_Produits_Mieux_Notes
TO role_client;


-- Les Client ont accès au catalogue des produits 
GRANT SELECT
ON Produit
TO role_client;

-- Les Fournisseur n'ont droit que de lecture sur leurs vues
GRANT SELECT ON V_Fournisseur_VolumesVente TO role_fournisseur;
GRANT SELECT ON V_Fournisseur_CA TO role_fournisseur;
GRANT SELECT ON V_Produits_PlusVendus TO role_fournisseur;

-- Les Administrateur ont simplement tous les droits (ATTENTION il faut donc bien choisir qui est Administrateur)
GRANT SELECT ON ALL TABLES TO role_admin;
GRANT SELECT ON ALL VIEWS TO role_admin;

Script à exécuter pour voir les vues en tant que fournisseur/client :

BEGIN
  DBMS_SESSION.SET_IDENTIFIER(ClientId/FournisseurId);
END;
/
