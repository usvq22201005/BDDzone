/*                          REQUETES toutes faites par Arnaud (ct long)
 Pour me faciliter l'existence dans la construction des 27 requêtes
 j'ai fait des vues intermédiaires ... beaucoup de vues.
 la plus importante est V_Vente_Client surtout pour les dernières requêtes.

Le problème est que l'ajout de la table de correspondance CSC
à considérablement alourdi certaines requêtes surtout (R12,R15,R16, R17 et R27).
Les vues qui autrefois simplifiait l'écriture de ces requêtes ne servent 
qu'à visualiser les données.

Pour les requêtes fonctionnent il faut executer toutes les vues intermédiaires.
Bonne lecture !

- Arnaud 
*/

/*                  Panier et Favoris (1)
 Requête n°1 Quels sont les produits que souhaite acheter un client donné
  qui appartiennent 
à des catégories données ? Ou à ses favoris ? 
*/
DESC Produit;

create or replace view V_SouhaitAchat_Client as
select 
    sa.clientid,
    p.nom as nom_produit,
    p.prix,
    sc.nom as souscategorie,
    cat.nom as categorie,
    cat.categorieid
from souhaiteacheter sa
join produit p 
    on sa.produitid = p.produitid
join categoriesouscategorie csc
    on csc.cscid = p.categoriesouscategorieid
join souscategorie sc
    on sc.souscategorieid = csc.souscategorieid
join categorie cat
    on cat.categorieid = csc.categorieid;

-- On peux uttiliser la vue pour voir si les produit 
--qu'un client souhaite acheter appartiennent à une catégorie donnée :
select nom_produit
from V_SouhaitAchat_Client
where categorie like 'High-Tech' 
and clientid = 2 ;

-- Ou si ces produits appartiennent à une catégorie favorite du client...
-- pour cela on crée la vue favori 
create or replace view v_favoriclient as
select 
    cl.clientid,
    cl.nomutilisateur,
    cat.nom as categoriefavorite,
    cat.categorieid
from client cl
join favori f 
    on cl.clientid = f.clientid
join souscategorie sc
    on f.categoriesouscategorieid = sc.souscategorieid
join categorie cat
    on sc.categorieid = cat.categorieid;

desc favori;


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
CREATE or replace view V_Recommandation_Produit as
select
    r.clientid,
    rp.produitid,
    p.nom as nom_produit,
    cat.nom as categorie,
    cat.categorieid,
    sc.souscategorieid,
    r.dateheure as datereco
from recommandation r
join recommandationproduit rp 
    on r.recommandationid = rp.recommandationid
join produit p 
    on rp.produitid = p.produitid
join souscategorie sc 
    on p.categoriesouscategorieid = sc.souscategorieid
join categorie cat 
    on sc.categorieid = cat.categorieid;
;

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
create or replace view v_note as
select
    n.clientid,
    n.produitid,
    p.nom as nom_produit,
    n.note
from noteproduit n
join produit p 
    on p.produitid = n.produitid;


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
  cli.nomutilisateur,
  p.ProduitId,
  p.nom,
  p.CATEGORIESOUSCATEGORIEID,
  sc.CategorieId,
  pc.Quantite,
  pc.Prix,
  co.DateCommande
from ProduitCommande pc
join Commande co ON pc.CommandeId = co.CommandeId
join Client cli ON co.clientId = cli.clientId
join Produit p ON pc.ProduitId = p.ProduitId
join SousCategorie sc ON p.CATEGORIESOUSCATEGORIEID = sc.SousCategorieId;
;

  -- on va pouvoir aussi reuttiliser la vue des recommendations :
  -- on obtient les clients qui ont acheter suite à une recommendation
  select REC.clientid, VC.datecommande, VC.nom
  from V_recommandation_Produit REC
  join V_Vente_Client VC on REC.clientid=VC.clientid
  and  REC.produitid=VC.produitid -- on veut le même client ET le même produit recommandé/vendu
  -- grâce aux vues la requête est assez simple
  -- il suffit de mettre la restriction dans les 30 jours suivant la recommandation 
  where VC.datecommande between REC.DateReco-100  and REC.DateReco+100;



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

select * from client where aLocal = 1;
/*                          Produits (8)
--Requête n°8 
Quels sont les produits les plus achetés par les clients qui ne veulent acheter
que local ? Et pour un pays en particulier ?
*/
-- ressemble beaucoup aux requête précédentes... notamment la n°4 mais en uttilisant cette fois VC
select *
from (
    select 
        sum(vc.quantite) as nb_achete,
        vc.produitid,
        cl.alocal
    from v_vente_client vc
    join client cl on cl.clientid = vc.clientid
    join produit p on p.produitid = vc.produitid
    join produitpays pp on pp.produitid = p.produitid   -- join sur le produit
    where cl.alocal = 1
      and pp.nom = 'FR'  -- filtrer par pays du produit
    group by vc.produitid, cl.alocal
    order by nb_achete desc
)
-- optionnel: top 3
-- where rownum <= 3;

;
desc produitpays ; select * from produitpays ;


/*                    Catégories et Sous-catégories (1)
--Requête n°9
Quelle est la catégorie dont les articles sont les mieux notés en moyenne  ?
*/

-- ON va reutiliser V_Notes qu'on va joindre avec categorie..
create or replace view V_Note_Categorie as
select 
    V.clientid, 
    V.produitid, 
    V.nom_produit,
    V.note, 
    cat.nom as categorie
from V_Note V
join Produit p on p.produitid = V.produitid
join SousCategorie sc on p.CategorieSousCategorieId = sc.SousCategorieId
join Categorie cat on sc.CategorieId = cat.CategorieId;
;
-- puis on fait l'aggregat
select *
from (
    select avg(V2.note) as note_moy, V2.categorie
    from V_Note_Categorie V2
    group by V2.categorie
    order by note_moy desc
)
where rownum <= 1; -- pour obtenir LA categorie ayant la meilleure moyenne de notes...

