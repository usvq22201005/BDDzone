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
select CL.ClientId, CL.nomutilisateur, Cat.Nom as CategorieFavorite,
Cat.CategorieId
from (Client CL 
join Favori F 
on CL.ClientId = F.ClientId) 
join  Categorie Cat
 on F.CategorieId = Cat.CategorieId 
;

-- Voyons si les produits mis en souhait par un client appartiennent à une catégorie favorite du client :
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
  r.DateHeure as DateReco
from Recommandation r
join RecommandationProduit rp ON r.RecommandationId = rp.RecommandationId
join Produit p on rp.produitid= p.produitid
join Categorie cat on cat.categorieid = p.categorieid ;

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
 -- j'uttilise row_num aprceque fetch first 3 n'existe pas sur toute les versions d'ORACLE...
-- il faut le mettre après que l'aggregat soit fait sinon les trois lignes  sont prise indépendamment de la moyenne.
-- https://use-the-index-luke.com/sql/partial-results/top-n-queries




/*
-- Requêtes n°4 : Quels sont les 3 produits les plus vendus par un fournisseur donné sur une
période donnée ?
*/

CREATE VIEW V_Vente_Fournisseur as 
select pc.commandeid,p.produitid,co.datecommande, p.nom,pc.prix,pc.quantite,f.fournisseurid,f.nom as nom_fourn
from commande co join produitcommande pc
on co.commandeid = pc.commandeid
join produit p on pc.produitid =p.produitid
-- un produit n'a qu'un seul fournisseur, l'inverse est faux.
join fournisseur f on p.fournisseurid = f.fournisseurid ;

-- Bon déja il faut obtenir les 3 produits les plus vendus :

create view V_top3ventes as 
select * 
from ( 
  select sum(vf.quantite) as nb_vente,vf.nom as nom_produit, vf.produitid,vf.fournisseurid
  from V_Vente_Fournisseur vf
  -- puis ensuite appliquer une restriction sur la période et le fournisseur...
  -- a retirer si on veut le top3 des ventes en général
  where vf.fournisseurid= 2
  and vf.datecommande between TO_DATE('2025-12-01','YYYY-MM-DD') and TO_DATE('2025-12-26','YYYY-MM-DD')
  -- -- ------------------------------------
  group by vf.produitid, vf.nom, vf.fournisseurid
  order by sum(vf.quantite) DESC) 
where rownum <= 3 ; 

-- Requête n°5 (variante de la précédente...)
-- Quel est le produit qui a rapporté le plus d’argent à un fournisseur donné sur
-- une période donnée ?

select *
from ( 
  select sum(vf.prix*vf.quantite) as Gain_Produit,vf.nom as nom_produit, vf.produitid,vf.fournisseurid
  from V_Vente_Fournisseur vf
  
  -- a retirer si on veut le top3 des ventes en général indépendamment du fournisseur et de la date de commande.
  where vf.fournisseurid= 2
  and vf.datecommande between TO_DATE('2025-12-01','YYYY-MM-DD') and TO_DATE('2025-12-26','YYYY-MM-DD')
  -- -- ------------------------------------
  group by vf.produitid, vf.nom, vf.fournisseurid
  order by sum(vf.prix*vf.quantite) DESC) 
  where rownum = 1;--j'ai essayé avec MAX mais seul rownum permet d'extraire le nom du produit avec le montant.
  -- ducoup au final c'est vraiment presque la même requête.




-- Requête n°6 : Produits recommandés et achetés dans les 30 jours
-- Pour les requêtes qui portent sur les clients et les commandes d'articles
-- mais aussi sur leur recommendation et celle cie à quelle date : 
-- la MEGA vue Vente_Client !!! 

CREATE VIEW V_Vente_Client AS
select
  pc.CommandeId,
  cli.clientid,
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

  -- on va pouvoir aussi reuttiliser la vue des recommendations :
  -- 
  select REC.clientid, VC.datecommande, VC.nom
  from V_recommandation REC
  join V_Vente_Client VC on REC.clientid=VC.clientid
  and  REC.produitid=VC.produitid -- on veut le même client ET le même produit recommandé/vendu
  -- grâce aux vues la requête est assez simple
  -- il suffit de mettre la restriction dans les 30 jours suivant la recommandation 
  where VC.datecommande between REC.DateReco-1  and REC.DateReco+30;

  
-- Requête n°7 Quels sont les 3 produits les plus recommandés (toutes catégories
-- confondues) sur le dernier mois 
  select * from(
  select count(*) as nb_reco,produitid,rec.nom_produit
  from V_recommandation REC 
  group by REC.produitid, rec.nom_produit
  order by count(*) DESC)
  where rownum <=3;-- je commence à m'habituer à faire des top 3...


/*
--Requête n°8 
Quels sont les produits les plus achetés par les clients qui ne veulent acheter
que local ? Et pour un pays en particulier ?
*/
-- ressemble beaucoup aux requête précédentes... notamment la n°4 mais en uttilisant cette fois VC
select *
from (select sum(VC.quantite) as nb_achete,VC.produitid,CL.aLocal
from v_vente_client VC
join client CL on CL.clientid= VC.clientid
join Produit P on P.produitid = VC.produitid -- chercher infos fournisseur du produit, jointure nécéssaire
join fournisseur F on F.fournisseurid = P.fournisseurid
where CL.aLocal =1 and F.pays='France' -- pour un pays en particulier... à retirer pour elargir.
group by VC.produitid,CL.aLocal
order by nb_achete DESC);
--where rownum <= 3; optionnel pour obtenir le top3



/*                                                Catégories et Sous-catégories
--Requête n°9
Quelle est la catégorie dont les articles sont les mieux notés en moyenne  ?
*/

-- ON va reutiliser V_Notes qu'on va joindre avec categorie..
create view V_Note_Categorie as
select V.clientid, V.produitid, V.nom_produit,V.note, cat.nom
from V_Note V
join produit p on p.produitid = V.produitid
join categorie cat on cat.categorieid=p.categorieid 
;
-- puis on fait l'aggregat
select * from (
select avg(V2.note) as note_moy, V2.nom
from V_Note_Categorie V2
group by V2.nom
order by note_moy DESC
)
where rownum <=1 ; -- pour obtenir LA categorie ayant la meilleure moyenne de notes...


/*
--Requête n°10
Quelles sont les 3 catégories dont le plus de produits ont été vendus ce dernier mois  ?
Encore un top3... 
*/

select * from(

select cat.nom, sum(V.quantite) as nb_vente 
from V_Vente_Fournisseur V
join produit p on
V.produitid = p.produitid
join categorie cat on cat.categorieid=p.categorieid

group by cat.nom
order by nb_vente
) where rownum <=3;


/*
--Requête n°11
Quels pourcentages représentent chaque catégorie achetée par un client donné dans
ses achats totaux sur une période donnée ?

Requête très difficile car il faut extraire les pourcentages
sinon le nombre d'achat par categorie est plus simple  à écrire
et se trouve dans la table temporaire QClientCat.
*/

-- pour faire cette requête je me suis aidé de la vue ci dessous sinon c'est vraiment 
-- dur de visualiser les jointures...
--select * from V_Vente_Client VC;  

select QClientCat.clientid as clientid,QClientCat.nom as categorie, 

(QClientCat.qte_cat/QClient.client_total)*100 as pourcentage

from 
(
select cat.nom,VC.nomutilisateur, VC.clientid, sum(VC.quantite) as qte_cat
from V_Vente_Client VC 
join categorie cat on
VC.categorieid = cat.categorieid
group by (cat.categorieid,VC.clientid,cat.nom,VC.nomutilisateur)
)QClientCat

join 
(
select VC.clientid,sum(VC.quantite) as client_total
from V_Vente_Client VC
group by VC.clientid
) QClient

on QClientCat.clientid= QClient.clientid 
; -- pfiou
-- pour une période donnée et un client donné il faut rajouter des where
-- dans les deux tables temporaire mais je risque de pas avoir le temps...

/*
--Requête n°12
12) Pour un client donné, quelles sont les catégories 
dont il a acheté au moins trois produits appartenant à des sous-catégories différentes ?


*/
-- La VUE V_Vente_Client est essentielle
-- car elle contient déja les sous categorie achetées
-- ce qui epargne des jointures en plus à écrire.
select * from V_Vente_Client ;

create view V_NB_SousCatAchete_ParCat as
select VC.clientid,count(distinct souscategorieid) as nb_souscat,VC.categorieid
from V_Vente_Client VC 
group by VC.clientid,VC.categorieid -- on groupe client ET par categorie
-- on obtient ainsi le nombre de souscategorie distincte achete PAR Categorie/client...
;

-- on identifie les client "explorateurs" qui pour une categorie donné
-- compte 3 achat de souscategorie distinctes...
select V.clientid, V.categorieid,V.nb_souscat as nb_ScAchete
from V_NB_SousCatAchete_ParCat V
where V.nb_souscat >=2 ;-- pour tester j'ai mis 2 souscategorie/produits distincte achete.
-- la requête demande 3,


/*
--Requête n°13
Quels clients ont acheté tous les produits d’une sous-catégorie donnée,
et quel pourcentage des produits de cette sous-catégorie ont-ils noté ?
*/
-- on réutilise vue précédente :
create view SC_allproduit as
select count(distinct p.produitid)
from souscategorie SC join
produit p on SC.souscategorieid 
= p.souscategorieid
