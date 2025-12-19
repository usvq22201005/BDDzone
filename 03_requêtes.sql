/*
 Pour me faciliter l'existence dans la construction des 27 requêtes
 j'ai fait des vues intermédiaires ... beaucoup de vues.
 la plus importante V_Vente_Client surtout pour les dernières requêtes.
- Arnaud
*/

/*                  Panier et Favoris (1)
 Requête n°1 Quels sont les produits que souhaite acheter un client donné
  qui appartiennent 
à des catégories données ? Ou à ses favoris ? 
 Qui sont déjà stockés dans son pays ?
*/
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
-- pour cela on crée la vue favori 
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





/*                              Panier et Favoris (2)                  
Requête n°2 Pour chaque client, quelles (sous-)catégories présentes dans ses souhait d'achat n’ont
jamais été recommandées
*/
CREATE VIEW V_Recommandation_Produit AS
select
  r.ClientId,
  rp.ProduitId,
  p.nom as nom_produit,
  cat.nom as categorie,
  cat.categorieid,
  sc.souscategorieid ,
  r.DateHeure as DateReco
from Recommandation r
join RecommandationProduit rp ON r.RecommandationId = rp.RecommandationId
join Produit p on rp.produitid= p.produitid
join Categorie cat on cat.categorieid = p.categorieid 
join souscategorie sc on p.souscategorieid = sc.souscategorieid;

-- les catégories présentes dans ses souhait d'achat et qui n’ont
--jamais été recommandées

select SAC.categorie
from V_SouhaitAchat_Client SAC
where categorieId not in 
( 
select REC.categorieId
from V_Recommandation_Produit REC
where REC.clientid =2
); 

-- Les sous categorie présentent l'inconvenient de pouvoir être 'null'
-- le 'not in' ne suffit pas...



/*                      Produits (1)
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
 -- j'uttilise row_num car fetch first 3 n'existe pas sur toute les versions d'ORACLE...
-- il faut le mettre après que l'aggregat soit fait sinon les trois lignes  sont prise indépendamment de la moyenne.
-- https://use-the-index-luke.com/sql/partial-results/top-n-queries




/*                              Produits (2)
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

/*                      Produits (3)
-- Requête n°5 (variante de la précédente...)
-- Quel est le produit qui a rapporté le plus d’argent à un fournisseur donné sur
-- une période donnée ?
*/
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



/*                    Produits (4)
-- Requête n°6 : Produits recommandés et achetés dans les 30 jours suivant recommandation

-- Pour les requêtes qui portent sur les clients et les commandes d'articles
-- mais aussi sur leur recommendation et celle cie à quelle date : 
-- on crée la vue Vente_Client  
*/

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
  -- on obtient les clients qui ont acheter suite à une recommendation
  select REC.clientid, VC.datecommande, VC.nom
  from V_recommandation_Produit REC
  join V_Vente_Client VC on REC.clientid=VC.clientid
  and  REC.produitid=VC.produitid -- on veut le même client ET le même produit recommandé/vendu
  -- grâce aux vues la requête est assez simple
  -- il suffit de mettre la restriction dans les 30 jours suivant la recommandation 
  where VC.datecommande between REC.DateReco-1  and REC.DateReco+30;



  /*                            Produits (5)
  Requête n°7 Quels sont les 3 produits les plus recommandés (toutes catégories
  confondues) sur le dernier mois 
 */


  select * from(
  select count(*) as nb_reco,produitid,rec.nom_produit
  from V_recommandation_Produit REC 
  group by REC.produitid, rec.nom_produit
  order by count(*) DESC)
  where rownum <=3;-- je commence à m'habituer à faire des top 3...


/*                          Produits (8)
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



/*                    Catégories et Sous-catégories (1)
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


/*              Catégories et Sous-catégories (2)
--Requête n°10
Quelles sont les 3 catégories dont le plus de produits ont été vendus ce dernier mois  ?
Encore un top3... 
*/

select * 
from(
select cat.nom, sum(V.quantite) as nb_vente 
from V_Vente_Fournisseur V
join produit p on
V.produitid = p.produitid
join categorie cat on cat.categorieid=p.categorieid

group by cat.nom
order by nb_vente
) where rownum <=3;


/*                     Catégories et Sous-catégories (3)
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
round((QClientCat.qte_cat/QClient.client_total)*100,2) as pourcentage
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
/*
 pour une période donnée et un client donné il faut rajouter des where
dans les deux tables temporaire. 
*/




/*                     Catégories et Sous-catégories (4)
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


/*                    Catégories et Sous-catégories (5)
--Requête n°13
Quels clients ont acheté tous les produits d’une sous-catégorie donnée,
et quel pourcentage des produits de cette sous-catégorie ont-ils noté ?
*/
-- nombre de produit distincts dans une sous categorie :
create view SC_allproduit as
select count(distinct p.produitid) as nb_produit ,SC.souscategorieid
from souscategorie SC join
produit p on SC.souscategorieid 
= p.souscategorieid 
group by SC.souscategorieid;

-- nombre de produits distinct acheté par sous categorie/client
create view CL_achatSC as
select count(distinct produitid)as nb_achat,VC.clientid,VC.souscategorieid
from V_Vente_Client VC
group by VC.clientid,VC.souscategorieid ;

-- On la requête finale (n°13):
select CL_achatSC.nb_achat as nb_achat, CL_achatSC.clientid as clientid,
CL_achatSC.souscategorieid as SousCategorieId,SC_allproduit.nb_produit
from
CL_achatSC join SC_allproduit
on CL_achatSC.souscategorieid=SC_allproduit.souscategorieid

-- finalement on vérifie que le client à acheté pour une SC donne
-- autant de produit distincts qu'il y en a dans la SC.
where CL_achatSC.nb_achat = SC_allproduit.nb_produit ;


/*                   Catégories et Sous-catégories (6)
--Requête n°14
Quelles (sous-)catégories ont été ajoutées sur une période donnée  ?

*/
create view C_PERIOD as
select * from 
categorie cat
where cat.dateajout between TO_DATE('2025-01-01','YYYY-MM-DD')
AND TO_DATE('2025-12-31','YYYY-MM-DD');
-- enfin des requêtes qui ne me prennent pas 1h à écrire...
create view SC_PERIOD as
select * from 
souscategorie SC
where SC.dateajout between TO_DATE('2025-01-01','YYYY-MM-DD')
AND TO_DATE('2025-12-31','YYYY-MM-DD') ;

--pour avoir les 2 (categories et sous categories) :
select SCP.nom as Nom,SCP.Dateajout as Dateajout from SC_PERIOD SCP 
UNION ALL 
select CP.Nom as Nom, CP.Dateajout as Dateajout from C_PERIOD CP ;




/*                           Clients (1)
--Requête n°15 
Quels sont les clients ayant des centres d’intérêt similaires à un client donné ? 

disons similarité = au moins une sous-catégorie commune

*/ 
--select * from CentreDInteret Ci1 ;


select Ci1.clientid as c1,Ci2.clientid as c2,
count(distinct Ci2.souscategorieid) as nb_commun -- nb sous categorie en commun
from
-- autojointure comme au CC1 l'année dernière (ca a fait mal)
-- dur à faire sans visualiser au fur et à mesure avec SQL developper :
CentreDInteret Ci1 join CentreDInteret Ci2
on Ci1.clientid != Ci2.clientid 
and Ci1.souscategorieid = Ci2.souscategorieid -- 
group by Ci1.clientid,Ci2.clientid -- couples du produit cartésien
;

/*                           Clients (2)
Requête n°16 Quels sont les clients pour lesquels nous avons recommandé
 une sous-catégorie au moins 3 fois au cours des 6 derniers mois, 
mais qui n’ont jamais acheté de produit dans cette sous-catégorie 
après ces recommandations ?

ON NE PEUX PAS reuttiliser la VUE V_Recommandation_Produit 
car on cherche le nombre de recommandation pour une categorie/souscategorie
et non le nombre de recommendation par produit.
*/ 
-- On cherche le nombre de categorie.souscategorie recommendéess dans la table recommendation...
create view V_Recommandation as
select R.Recommandationid,R.clientid, CSC.CSCid,R.Dateheure,categorieid,souscategorieid
from recommandation R
join CategorieSousCategorie CSC
on R.CSCID =CSC.CSCID
;

-- on compte les recommandation apr client : 
select V.clientid, V.categorieid, V.souscategorieid, count(*) as nb_reco
from V_Recommandation V
where DateHeure >= add_months(sysdate, -6) -- sur les 6 dernier mois
group by V.clientid, V.categorieid, V.souscategorieid
having count(*) >= 3 
-- Plus complexe par sûr que cela marche après tests...
-- on veut que le client n'ai pas commandé malgré 3(ou+) recommandaitons
and clientid not in 
(
select VC.clientid
from V_Vente_Client VC
where datecommande >= add_months(sysdate, -6)
and VC.souscategorieid = V.souscategorieid
);-- Dans les test aucun client ne correspond à ces critères...

--select * from V_Vente_Client VC;

--on veut les clients dans cette liste qui ne sont pas dans la liste de vente
-- de cette sous categorie après cette recommendation



/*                         Clients (3)
Requête n°17  Quels sont les 5 clients ayant dépensé 
le plus sur les douze derniers mois et quel pourcentage des produits 
qu’ils ont achetés leur ont été recommandés ?
*/
create view V_top5depense as
select *
from(
select clientid,sum(quantite*prix) as depense
from V_Vente_Client VC
group by clientid
order by depense DESC )
where rownum <=5;


/*
select * --clientid
from V_Recommandation_Produit; */

/*                          Clients (4)
Requête n°18
Quels sont les 5 clients qui ont le plus grand écart 
entre la note moyenne qu’ils laissent et la note moyenne des produits qu’ils achètent ?
*/
create view note_laisse as
select CL.clientid,avg(NP.note) as moy_note
from client CL join NoteProduit NP
on CL.clientid = NP.clientid
group by CL.clientid
;

-- on peux uttiliser aussi l'attribut noteproduit de la table produit qui est la note moyenne du produit
create view note_moy as 
select NP.produitid,avg(NP.note) as moy_prod
from NoteProduit NP
group by NP.produitid
;


-- et enfin la requête FINALE : 5 clients qui ont le plus grand écart 
--entre la note moyenne qu’ils laissent et la note moyenne des produits qu’ils achètent 
select * from (
select pac.clientid, nl.moy_note as note_moy_client,pac.produitid,
nm.moy_prod, 
ABS(nl.moy_note - nm.moy_prod) as diff
from produit_achete_client pac 
join note_laisse nl
on pac.clientid = nl.clientid 
join note_moy nm on pac.produitid =
nm.produitid 
order by diff DESC
)
where rownum <= 5; -- 5 clients



/*                          Clients (5)
Requête n°19
Quels clients ont reçu une recommandation 
contenant au moins un produit qu’ils avaient déjà acheté ?

select * from V_Recommandation_Produit VR ;
select *
from V_Vente_Client VC ;

*/
select clientid from client
where exists (
select VC.clientid,VC.produitid as prot_acheté_reco, VR.Datereco
from V_Vente_Client VC 
join V_Recommandation_Produit VR
on VC.clientid = VR.clientid
and VC.produitid = VR.produitid 
);






/*                           Fournisseurs (1)
Requête n°20 Quel est le total des ventes d’un fournisseur donné sur une période donnée ?

La vue V_Vente_Fournisseur d'impose
select * from V_Vente_Fournisseur ;-- pour visualiser
*/


select nom_fourn,sum(quantite) as total_vente
from V_Vente_Fournisseur 
where datecommande between to_date('2025-01-01','YYYY-MM-DD')
and to_date('2025-12-30','YYYY-MM-DD')
group by nom_fourn
;

/*                          Fournisseurs (2)
Requête n°21 Quels fournisseurs ont **vendu** des produits uniquement dans leur propre pays ?
    
*/
select VF.fournisseurid,VF.commandeid, VF.produitid, F.Pays

from V_Vente_Fournisseur VF
join fournisseur F
on F.fournisseurid= VF.fournisseurid
join commande co on co.commandeid = VF.commandeid
join client cl on co.clientid = cl.clientid

where F.pays= cl.pays
;


/*                          Fournisseurs (3)
Requête n°22 Quels sont les fournisseurs les mieux notés ?
*/
-- il y une certaine baisse de difficultée dans les requêtes...
select * 
from fournisseur
order by NoteFournisseur DESC ;

/*               Ventes et Chiffre d’affaires (1)
Requête n°23 Quel est le total des ventes du site entier sur une période donnée ?
*/



select sum(prixtotal)as total_vente 

from commande
where datecommande between to_date('2025-01-01','YYYY-MM-DD') and to_date('2025-12-30','YYYY-MM-DD');

/*                     Ventes et Chiffre d’affaires (2)
Requêtes n°24 Pour chaque catégorie, quel **est le pourcentage du chiffre d’affaires total** 
qu’elle représente la semaine passée, en classant par parts décroissantes ?

Encore un pourcentage cela ressemble à la requête n°11

On a besoin de 
prix vendu par categorie (ici somme sans multiplier par quantite)
car pour les ventes clients on regarde les vente de produit en quantite =1
divisé par chiffre d'affaire total puis multiplié par 100

*/ --select * from V_Vente_CLient VC;-- vue importante

-- requête difficile car ile me fallait rajouter la colonne total_vente en parapllèle de la somme
-- des vente de chaque categorie...
select VC.categorieid,(sum(VC.prix)) as cat_vente, temp.total_vente as site_vente,
round(((sum(VC.prix))/temp.total_vente)*100,2) as pourcentage_CA
from
V_Vente_CLient VC 

cross join -- permet de joidnre la colonne  total des ventes même si il n'y a pas de valeur commune...
(
select sum(prixtotal) as total_vente 
from commande
where datecommande between to_date('2025-01-01','YYYY-MM-DD') and to_date('2025-12-30','YYYY-MM-DD')
) temp
where datecommande between to_date('2025-01-01','YYYY-MM-DD') 
and to_date('2025-12-30','YYYY-MM-DD')
group by VC.categorieid,temp.total_vente;





/*                           Notes et Avis (1)
Requêtes n°25 Quelle est la moyenne des notes laissées par un client donné ? Ainsi que le
nombre d’avis qu’il a laissés  ?
*/

CREATE VIEW V_Note AS -- On reuttilise la vue : V_Note (déja cree pour la requête n°3)
select
  n.ClientId,
  n.ProduitId,
  p.nom as nom_produit,
  n.Note
from NoteProduit n
join Produit p on p.produitid=n.produitid;

select round(avg(Note),2),count(note) as nb_avis
from V_Note
group by clientid ;

/*                           Notes et Avis (2)
Requêtes n°26 Quelle est la moyenne des notes attribuées par des clients à des produits que
nous leur avons recommandés ? Quelle est la moyenne pour ceux qui ne leur
ont pas été recommandés ?
*/

CREATE VIEW V_Recommandation_Produit AS
select
  r.ClientId,
  rp.ProduitId,
  p.nom as nom_produit,
  cat.nom as categorie,
  cat.categorieid,
  sc.souscategorieid ,
  r.DateHeure as DateReco
from Recommandation r
join RecommandationProduit rp ON r.RecommandationId = rp.RecommandationId
join Produit p on rp.produitid= p.produitid
join Categorie cat on cat.categorieid = p.categorieid 
join souscategorie sc on p.souscategorieid = sc.souscategorieid; -- vue V_Recommandation_Produit reuttilisée

-- Requête délicate car la jointure peux DEMULTIPLIER le nombre de note d'un produit par
-- le nobmre de recommendation faite sur ce même produit.
-- si je fais une jointure sans réfléchir entre V_recommendation_Produit et V_Note....
select VRP.clientid,
round(avg(VN.note),2) as moyenne_note -- (2) puis on fait la moyenne
from 
(
select distinct clientid, produitid -- (1)on prend les couples uniques
from V_Recommandation_Produit
) VRP
join V_Note VN
on VN.produitid = VRP.produitid
and  VN.clientid = VRP.clientid
group by VRP.clientid ;



/*                           Centres d’intérêt

Requêtes n°27 Quels sont les centres d’intérêt les plus fréquents parmi tous les clients
(catégories ou sous-catégories confondues) ?
*/

select C1.categorieid as CSC_interêt, Cat.nom as nom,
count(distinct C1.clientid) as nb_client

from CentreDInteret  C1
join categorie Cat on C1.categorieid = Cat.categorieid
group by  C1.categorieid,Cat.nom 

union all -- renommer les colonnes pour les colonnes Cat.nom et SCat.nom match

select C2.souscategorieid as CSC_interêt, SCat.nom as nom, 
count(distinct C2.clientid) as nb_client

from CentreDInteret C2 
join souscategorie SCat on C2.souscategorieid=SCat.souscategorieid
group by C2.souscategorieid ,SCat.nom

;
