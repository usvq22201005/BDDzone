-- Pour me faciliter l'existence
-- je créer des vues : 

CREATE VIEW V_Vente AS
SELECT
  pc.CommandeId,
  c.ClientId,
  p.ProduitId,
  p.SousCategorieId,
  sc.CategorieId,
  pc.Quantite,
  pc.Prix,
  co.DateCommande
FROM ProduitCommande pc
JOIN Commande co ON pc.CommandeId = co.CommandeId
JOIN Produit p ON pc.ProduitId = p.ProduitId
JOIN SousCategorie sc ON p.SousCategorieId = sc.SousCategorieId;

CREATE VIEW V_Recommandation AS
SELECT
  r.ClientId,
  rp.ProduitId,
  r.DateHeure
FROM Recommandation r
JOIN RecommandationProduit rp ON r.RecommandationId = rp.RecommandationId;

CREATE VIEW V_Note AS
SELECT
  n.ClientId,
  n.ProduitId,
  n.Note
FROM NoteProduit n;

CREATE VIEW V_FavoriClient
SELECT C.nomutilisateur,F., Cat.Nom
FROM (Client C JOIN Favori F 
ON C.ClientId = F.ClientId) 
JOIN Categorie Cat
 ON F.CategorieId = Cat.CategorieId  
 ;

-- Quels sont les **produits que souhaite acheter** 
--un client **donné** qui appartiennent 
--à des **catégories données ?** Ou à ses favoris ? Qui sont déjà stockés dans son pays ?

select  
from SouhaiteAcheter SA
join Produit P on SA.ProduitId= P.ProduitId
where SA.clientId = client  ;

--Pour chaque client, quelles (sous-)catégories présentes dans son panier n’ont
--jamais été recommandées

select S