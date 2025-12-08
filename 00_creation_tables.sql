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
    CommandeId number (5),
    ClientId number(5),
    DateCommande DATE
    ) ;
--4.	ProduitCommande (CommandeId, ProduitId,
--Quantite, Prix) 
create table ProduitCommande(
        CommandeId number(6)
        Quantite number(5),
        Prix number(4),
)   
--5.	SouhaiteAcheter(ClientId, ProduitId, Quantite, Prix) 
create table SouhaiteAcheter(
    Clientid number(5),
    ProduitId number(6),
    Quantite number(5),
    Prix(4)
)
--6.	Fournisseur (FournisseurId, Nom, Pays, NoteFournisseur) 
create table (FournisseurId, 
    Nom varchar(20),
    Pays varchar(30),
    NoteFournisseur number(2)
  )
--7.	Pays (NomPays, ProduitId) 
create table Pays (
     NomPays varchar(20),
     ProduitId number(2)
     )
--8.	Categorie (CategorieId, Nom, DateAjout) 
create table Categorie(
    CategorieId number(5),
    Nom varchar(20),
    DateAjout DATE
)
--9.	SousCategorie (SousCategorieId, CategorieId, Nom, DateAjout) 
create table SousCategorie(
    SousCategorieId number(5),
    CategorieId number(5),
    Nom varchar(20),
    DateAjout DATE
)
--10.	CategorieSousCategorie (CSCId, CategorieId, SousCategorieId)
create table CategorieSousCategorie(
    CSCId number(5),
    CategorieId number(5),
    SousCategorieId number(5)
)
--11.	CentreDInteret (ClientId, CSCId)  
create table CentreDInteret(
    ClientId,
    CSCId
    )
--12.	Favori (ClientId, CSCId)

--13.	NoteProduit (ClientId, ProduitId, Note) 

--14.	Recommandation (RecommandationId, ClientId, CSCId, DateHeure)

--15.	RecommandationProduit (RecommandationId, ProduitId)
