select * from client ;
select table_name from user_tables ;
select * from commande ;
select * from SouhaiteAcheter ;
select * from produitcommande ;
select * from categorie ;
select * from produit ;
select * from RecommandationProduit ;

CREATE VIEW V_Vente_Client AS
select
  pc.CommandeId,
  cli.nomutilisateur ,
  p.ProduitId,
  p.nom,
  p.SousCategorieId,
  sc.CategorieId,
  pc.Quantite,
  pc.Prix,
  co.DateCommande
from ProduitCommande pc
join Commande co ON pc.CommandeId = co.CommandeId
join  Client cli ON co.clientId = cli.clientId 
join Produit p ON pc.ProduitId = p.ProduitId
join SousCategorie sc ON p.SousCategorieId = sc.SousCategorieId ;

select * from favori ;
select * from SouhaiteAcheter