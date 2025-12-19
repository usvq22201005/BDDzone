-- VUES CLIENT : réalisé par Yusuf DUMLUPINAR

-- Voir les articles dans le panier
CREATE OR REPLACE VIEW Vue_Client_Panier AS
SELECT
    sa.ClientId,
    p.ProduitId,
    p.Nom AS NomProduit,
    sa.Quantite,
    sa.Prix
FROM SouhaiteAcheter sa
JOIN Produit p ON sa.ProduitId = p.ProduitId
WHERE sa.ClientId = SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER');

-- Voir les articles de sa dernière recommandation
CREATE OR REPLACE VIEW V_Client_Recommandation_Recente AS
SELECT
    r.ClientId,
    rp.ProduitId,
    p.Nom AS NomProduit,
    r.DateHeure
FROM Recommandation r
JOIN RecommandationProduit rp
    ON r.RecommandationId = rp.RecommandationId
JOIN Produit p
    ON p.ProduitId = rp.ProduitId
WHERE r.ClientId = SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')
AND r.DateHeure = (
    SELECT MAX(r2.DateHeure)
    FROM Recommandation r2
    WHERE r2.ClientId = r.ClientId
);

-- Voir la liste de tous les articles qui ont été recommandés et quand
CREATE OR REPLACE VIEW Vue_Client_Histo_Reco AS
SELECT
    r.ClientId,
    r.RecommandationId,
    p.ProduitId,
    p.Nom AS NomProduit,
    r.DateHeure
FROM Recommandation r
JOIN RecommandationProduit rp ON r.RecommandationId = rp.RecommandationId
JOIN Produit p ON rp.ProduitId = p.ProduitId
WHERE r.ClientId = SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER');

-- Voir les dépenses totales
CREATE OR REPLACE VIEW Vue_Client_Depenses_Totales AS
SELECT
    ClientId,
    SUM(PrixTotal) AS DepensesTotales
FROM Commande
WHERE ClientId = SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')
GROUP BY ClientId;

-- Voir la liste de ses favoris
CREATE OR REPLACE VIEW Vue_Client_Favoris AS
SELECT
    f.ClientId,
    csc.CategorieId,
    c.Nom AS NomCategorie,
    csc.SousCategorieId,
    sc.Nom AS NomSousCategorie
FROM Favori f
JOIN CategorieSousCategorie csc ON f.CategorieSousCategorieId = csc.CSCId
LEFT JOIN Categorie c ON csc.CategorieId = c.CategorieId
LEFT JOIN SousCategorie sc ON csc.SousCategorieId = sc.SousCategorieId
WHERE f.ClientId = SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER');

-- Voir les produits les mieux notés
CREATE VIEW Vue_Produits_Mieux_Notes AS
SELECT
    p.ProduitId,
    p.Nom AS NomProduit,
    AVG(np.Note) AS NoteMoyenne
FROM Produit p
JOIN NoteProduit np
    ON p.ProduitId = np.ProduitId
GROUP BY p.ProduitId, p.Nom;

-- VUES FOURNISSEUR réalisées par Aurore GIROD

-- Voir les volumes de ventes pour ses articles

CREATE OR REPLACE VIEW V_Fournisseur_VolumesVentes AS
SELECT
    f.FournisseurId,
    p.ProduitId,
    p.Nom AS NomProduit,
    SUM(pc.Quantite) AS QuantiteVendue
FROM Fournisseur f,
     Produit p,
     ProduitCommande pc,
     Commande c
WHERE p.FournisseurId = f.FournisseurId
  AND pc.ProduitId = p.ProduitId
  AND c.CommandeId = pc.CommandeId
  AND f.FournisseurId = SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')
GROUP BY
    f.FournisseurId,
    p.ProduitId,
    p.Nom;


-- Voir son chiffre d’affaires

CREATE OR REPLACE VIEW V_Fournisseur_ChiffreAffaire AS
SELECT
    f.FournisseurId,
    SUM(pc.Prix) AS ChiffreAffaire
FROM Fournisseur f,
     Produit p,
     ProduitCommande pc,
     Commande c
WHERE p.FournisseurId = f.FournisseurId
  AND pc.ProduitId = p.ProduitId
  AND c.CommandeId = pc.CommandeId
  AND f.FournisseurId = SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')
GROUP BY f.FournisseurId;



-- VUES GENERALES réalisées par Aurore GIROD

-- # Vues d’information générale : 

-- Voir les produits qui ont eu le plus de ventes globales

CREATE OR REPLACE VIEW V_Produits_PlusVendues_Global AS
SELECT
    p.ProduitId,
    p.Nom,
    SUM(pc.Quantite) AS QuantiteTotaleVendue
FROM Produit p,
     ProduitCommande pc
WHERE p.ProduitId = pc.ProduitId
GROUP BY
    p.ProduitId,
    p.Nom
ORDER BY QuantiteTotaleVendue DESC;

-- Chiffre d’affaire par fournisseur

CREATE OR REPLACE VIEW V_CA_ParFournisseur AS
SELECT
    f.FournisseurId,
    f.Nom,
    SUM(pc.Prix) AS ChiffreAffaires
FROM Fournisseur f,
     Produit p,
     ProduitCommande pc
WHERE f.FournisseurId = p.FournisseurId
  AND p.ProduitId = pc.ProduitId
GROUP BY
    f.FournisseurId,
    f.Nom;

-- Chiffre d’affaire total

CREATE OR REPLACE VIEW V_CA_Total AS
SELECT SUM(pc.Prix) AS ChiffreAffairesTotal
FROM ProduitCommande pc;


-- Chiffre d’affaire total entre deux dates données

CREATE OR REPLACE FUNCTION ChiffreAffairesEntreDates(pDateDebut DATE, pDateFin DATE) RETURN SYS_REFCURSOR AS
    l_cursor SYS_REFCURSOR;
    l_debut DATE;
    l_fin DATE;
BEGIN
    IF pDateDebut <= pDateFin THEN
        l_debut := pDateDebut;
        l_fin := pDateFin;
    ELSE
        l_debut := pDateFin;
        l_fin := pDateDebut;
    END IF;

    OPEN l_cursor FOR
    SELECT
        SUM(pc.Prix) AS ChiffreAffairesTotal
    FROM ProduitCommande pc,
         Commande c
    WHERE pc.CommandeId = c.CommandeId
      AND c.DateCommande BETWEEN l_debut AND l_fin;

    RETURN l_cursor;
END;
/


-- Clients ayant acheté le plus d’objets dans les derniers 30 jours

CREATE OR REPLACE VIEW V_Clients_Actifs_30J AS
SELECT c.ClientId, COUNT(pc.ProduitId) AS NbProduitsAchetes
FROM Commande c, ProduitCommande pc
WHERE c.CommandeId = pc.CommandeId
  AND c.DateCommande >= SYSDATE - 30
GROUP BY c.ClientId
ORDER BY NbProduitsAchetes DESC;
