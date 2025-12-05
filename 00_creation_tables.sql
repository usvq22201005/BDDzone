--1.Client (ClientId, NomUtilisateur, Nom, Prenom,
-- Adresse, Pays, Local) 

create table client(
    ClientId number 5,
    NomUtilisateur varchar(50),
    Prenom varchar(50),
    Adresse varchar(50),
    Pays varchar(15),
    aLocal number 1
);
-- 2.	Produit (ProduitId, FournisseurId, CategorieId,
-- SousCategorieId, Nom, Prix, NoteProduit) 
create table produit (
    ProduitId ,
    FournisseurId,
    CategorieId,
    SousCategorieId,

);
--3.	Commande (CommandeId, ClientId, 
--DateCommande, PrixTotal)
create table Commande(
    CommandeId number 2,
    CLientId number 5,

    ) ;
--4.	ProduitCommande (CommandeId, ProduitId,
--Quantite, Prix) 
create table ProduitCommande(
        CommandeId number 10
        Quantite,
        Prix ,
)   
--5.	SouhaiteAcheter (ClientId, ProduitId, Quantite, Prix) 

--6.	Fournisseur (FournisseurId, Nom, Pays, NoteFournisseur) 

--7.	Pays (NomPays, ProduitId) 

--8.	Categorie (CategorieId, Nom, DateAjout) 

--9.	SousCategorie (SousCategorieId, CategorieId, Nom, DateAjout) 

--10.	CategorieSousCategorie (CSCId, CategorieId, SousCategorieId)

--11.	CentreDInteret (ClientId, CSCId)  

--12.	Favori (ClientId, CSCId)

--13.	NoteProduit (ClientId, ProduitId, Note) 

--14.	Recommandation (RecommandationId, ClientId, CSCId, DateHeure)

--15.	RecommandationProduit (RecommandationId, ProduitId)
