-- VUES CLIENT : réalisé par Yusuf DUMLUPINAR

-- Voir les articles dans le panier
CREATE VIEW Vue_Client_Panier AS
SELECT
    sa.ClientId,
    p.ProduitId,
    p.Nom AS NomProduit,
    sa.Quantite,
    sa.Prix
FROM SouhaiteAcheter sa
JOIN Produit p
    ON sa.ProduitId = p.ProduitId;

-- Voir les articles recommandés
CREATE VIEW Vue_Client_Articles_Recommandes AS
SELECT
    r.ClientId,
    rp.ProduitId,
    p.Nom AS NomProduit,
    r.DateHeure
FROM Recommandation r
JOIN RecommandationProduit rp
    ON r.RecommandationId = rp.RecommandationId
JOIN Produit p
    ON rp.ProduitId = p.ProduitId;

-- Voir la liste de tous les articles qui ont été recommandés et quand
CREATE VIEW Vue_Client_Historique_Recommandations AS
SELECT
    r.ClientId,
    r.RecommandationId,
    p.ProduitId,
    p.Nom AS NomProduit,
    r.DateHeure
FROM Recommandation r
JOIN RecommandationProduit rp
    ON r.RecommandationId = rp.RecommandationId
JOIN Produit p
    ON rp.ProduitId = p.ProduitId;

-- Voir les dépenses totales
CREATE VIEW Vue_Client_Depenses_Totales AS
SELECT
    ClientId,
    SUM(PrixTotal) AS DepensesTotales
FROM Commande
GROUP BY ClientId;


-- Voir la liste de ses favoris
CREATE VIEW Vue_Client_Favoris AS
SELECT
    f.ClientId,
    f.CategorieId,
    c.Nom AS NomCategorie,
    f.SousCategorieId,
    sc.Nom AS NomSousCategorie
FROM Favori f
LEFT JOIN Categorie c
    ON f.CategorieId = c.CategorieId
LEFT JOIN SousCategorie sc
    ON f.SousCategorieId = sc.SousCategorieId;

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

