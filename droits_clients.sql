-- Droit CLIENT : Réalisé par Yusuf DUMLUPINAR

-- Création du role client 
CREATE ROLE role_client;

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


-- Les Client ont accées au catalogue des produits 
GRANT SELECT
ON Produit
TO role_client;