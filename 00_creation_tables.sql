--1.Client (ClientId, NomUtilisateur, Nom, Prenom,
-- Adresse, Pays, Local) 

create table client(
    ClientId number(5),
    NomUtilisateur varchar(50),
    Nom varchar(50),
    Prenom varchar(50),
    Adresse varchar(50),
    Pays varchar(15),
    aLocal number(1)
);
-- 2.	Produit (ProduitId, FournisseurId, CategorieId,
-- SousCategorieId, Nom, Prix, NoteProduit) 
create table Produit (
    ProduitId number(6),
    FournisseurId number(5),
    CategorieId number(5),
    SousCategorieId number(5)

);
--3.	Commande (CommandeId, ClientId, 
--DateCommande, PrixTotal)
create table Commande(
    CommandeId number (5),
    ClientId number(5),
    DateCommande DATE,
    PrixTotal(4)
);
--4.	ProduitCommande (CommandeId, ProduitId,
--Quantite, Prix) 
create table ProduitCommande(
        ClientId number(5),
        ProduitId number(6),
        Quantite number(5),
        Prix number(4)
);  
--5.	SouhaiteAcheter (ClientId, ProduitId, Quantite, Prix) 
create table SouhaiteAcheter(
    ClientId number(5),
    ProduitId number(6),
    Quantite number(5),
    Prix(4)
);
--6.	Fournisseur (FournisseurId, Nom, Pays, NoteFournisseur) 
create table Fournisseur(
    FournisseurId number(5), 
    Nom varchar(20),
    Pays varchar(30),
    NoteFournisseur number(2)
);
--7.	Stock (ProduitId, Pays, Disponible)
create table Stock ( ProduitId, Pays, Disponible
    ProduitId number(6),
    Pays varchar(20),
    Disponible number(1)
);
--8.	Categorie (CategorieId, Nom, DateAjout) 
create table Categorie(
    CategorieId number(5),
    Nom varchar(20),
    DateAjout DATE
);
--9.	SousCategorie (SousCategorieId, CategorieId, Nom, DateAjout) 
create table SousCategorie(
    SousCategorieId number(5),
    CategorieId number(5),
    Nom varchar(20),
    DateAjout DATE
);
--!!!!!! Ajout
--10.	CategorieSousCategorie (CSCId, CategorieId, SousCategorieId)
create table CategorieSousCategorie(
    CSCId number(5),
    CategorieId number(5),
    SousCategorieId number(5)
);
--11.	CentreDInteret (ClientId, CSCId)  
create table CentreDInteret(
    ClientId number(5),
    CSCId number(5)
);
--12.	Favori (ClientId, CSCId)
create table Favori(
    ClientId number(5), 
    CSCId number(5)
);
--13.	NoteProduit (ClientId, ProduitId, Note) 
create table NoteProduit(
    ClientId number(5),
    ProduitId number(6),
    Note number(2)
);


--14.	Recommandation (RecommandationId, ClientId, CSCId, DateHeure)
create table Recommandation (
    RecommandationId number(10),
    ClientId number(5), 
    CSCId number(5),
    DateHeure DATE
);

--15.	RecommandationProduit (RecommandationId, ProduitId)
create table RecommandationProduit(
    RecommandationId number(10), 
    ProduitId number(6)
);