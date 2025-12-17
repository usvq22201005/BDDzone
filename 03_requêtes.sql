-- Pour me faciliter l'existence dans la construction des requêtes
-- j'ai crée des vues intermédiaires ... 


-- Requête n°1 Quels sont les produits que **souhaite acheter** 
--un client donné qui appartiennent 
--à des **catégories données ?** Ou à ses favoris ? 
-- Qui sont déjà stockés dans son pays ?

CREATE VIEW V_SouhaitAchat_Client as
select SA.clientId, P.nom as nom_produit,
P.Prix, CAT.nom as categorie,
cat.categorieId
from SouhaiteAcheter SA
join Produit P on SA.ProduitId= P.ProduitId
join Categorie CAT on CAT.categorieId = P.categorieId
;
-- On peux uttiliser la vue pour voir si les produit 
--qu'un client souhaite acheter appartiennent à une catégorie donnée :
select nom_produit
from V_SouhaitAchat_Client
where categorie like 'Informatique' 
and clientid = 2 ;

-- Ou si ces produits appartiennent à une catégorie favorite du client...

-- mais pour cela on crée la vue favori (utile plus tard)
CREATE VIEW V_FavoriClient as
select C.ClientId, C.nomutilisateur, Cat.Nom as CategorieFavorite,
Cat.CategorieId
from (Client C 
join Favori F 
on C.ClientId = F.ClientId) 
join  Categorie Cat
 on F.CategorieId = Cat.CategorieId 
;

-- Voyons si les produits mis en souhait appartiennent à une catégorie favorite du client :
select SAC.nom_produit
from V_SouhaitAchat_Client SAC
where SAC.clientId = 2
and exists( -- vérifie qu'une ligne dans Favori a le même clientId et CategorieId
  select *
    from V_FavoriClient VF -- Vue définie précédemment (contient CLientId et categorieId)
    where VF.ClientId = SAC.ClientId
      and VF.CategorieId = SAC.CategorieId
);






--Requête n°2 Pour chaque client, quelles (sous-)catégories présentes dans ses souhait d'achat n’ont
--jamais été recommandées

CREATE VIEW V_Recommandation AS
select
  r.ClientId,
  rp.ProduitId,
  p.nom as nom_produit,
  cat.nom as categorie,
  cat.categorieid,
  r.DateHeure
from Recommandation r
join RecommandationProduit rp ON r.RecommandationId = rp.RecommandationId
join Produit p on rp.produitid= p.produitid
join Categorie cat on cat.categorieid = p.categorieid 
;

-- les catégories présentes dans ses souhait d'achat et qui n’ont
--jamais été recommandées

select SAC.categorie
from V_SouhaitAchat_Client SAC
where categorieId not in 
( 
select REC.categorieId
from V_Recommandation REC
where REC.clientid =2
); 

-- Les sous categorie présentent l'inconvenient de pouvoir être 'null'
-- le 'not in' ne suffit pas...

/*
-- Requêtes n°3 Quels sont les 3 produits actuellement les mieux notés par les utilisateurs sur
--tout le site ? Et dans une catégorie ou sous-catégorie particulière ?
*/

-- on peux créer une vue des notes/produits...
CREATE VIEW V_Note AS
select
  n.ClientId,
  n.ProduitId,
  p.nom as nom_produit,
  n.Note
from NoteProduit n
join Produit p on p.produitid=n.produitid;

--les 3 produits actuellement les mieux notés

select * 
from (
  select avg(v.note) as note_moyenne,v.nom_produit
  from V_Note v
  group by v.ProduitId,v.nom_produit 
  order by avg(v.note) DESC
  )
where rownum <= 3 ;
 -- j'uttilise row_num aprceque fetch first 3 existe pas sur toute les versions d'ORACLE...
-- il faut le mettre après que l'aggregat soit fait sinon les trois lignes  sont prise indépendamment de la moyenne.
-- https://use-the-index-luke.com/sql/partial-results/top-n-queries

/*
-- Requêtes n°4 : Quels sont les 3 produits les plus vendus par un fournisseur donné sur une
période donnée ?
*/

CREATE VIEW V_Vente_Fournisseur as 
select pc.commandeid,p.produitid,c.datecommande, p.nom,pc.prix,pc.quantite 
from commande c join produitcommande pc
on c.commandeid = pc.commandeid
join produit p on pc.produitid =p.produitid
-- heureusement un produit n'a qu'un seul fournisseur d'apres le schema...
join fournisseur f on p.fournisseurid = f.fournisseurid ;

-- Bon déja il faut obtenir les 3 produits les plus vendus :
--on s'inspire de la requête précédente :
select * 
from ( 
  select sum() nb_vente
  from V_Vente_Client vc
  group by vc.produitid
  order by nb_vente DESC)
where rownum <= 3 ;
