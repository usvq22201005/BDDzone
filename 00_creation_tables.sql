--1.Client (ClientId, NomUtilisateur, Nom, Prenom,
-- Adresse, Pays, Local)


create table client(
    ClientId number(5),
    NomUtilisateur varchar(50),
    Nom varchar(50),
    Prenom varchar(50),
    Adresse varchar(50),
    Pays varchar(15),
    aLocal number(1),

    constraint PK_Client primary key (ClientId) -- on evite les doublons...
);
-- 2.	Produit (ProduitId, FournisseurId, CategorieId,
-- SousCategorieId, Nom, Prix, NoteProduit) 
create table Produit (
    ProduitId number(6),
    FournisseurId number(5),
    CategorieId number(5),
    SousCategorieId number(5),
    Nom varchar(50),
    Prix number(10,2),  -- Valeur max=99999999.99
    NoteProduit number(2),
    constraint PK_Produit primary key (ProduitId)


);
--3.	Commande (CommandeId, ClientId, 
--DateCommande, PrixTotal)
create table Commande(
    CommandeId number (5),
    ClientId number(5),
    DateCommande DATE,
    PrixTotal number(10,2),
    constraint PK_Commande primary key (CommandeId)
);
--4.	ProduitCommande (CommandeId, ProduitId,
--Quantite, Prix) 
create table ProduitCommande(
        CommandeId number(5),
        ProduitId number(6),
        Quantite number(5),
        Prix number(10,2),
        constraint PK_ProduitCommande primary key (CommandeId, ProduitId)
);  
--5.	SouhaiteAcheter (ClientId, ProduitId, Quantite, Prix) 
create table SouhaiteAcheter(
    ClientId number(5),
    ProduitId number(6),
    Quantite number(5),
    Prix number(10,2),
    constraint PK_SouhaiteAcheter primary key (ClientId, ProduitId)
);
--6.	Fournisseur (FournisseurId, Nom, Pays, NoteFournisseur) 
create table Fournisseur(
    FournisseurId number(5), 
    Nom varchar(20),
    Pays varchar(30),
    NoteFournisseur number(2),
    constraint PK_Fournisseur primary key (FournisseurId)
);
--XX.	Stock (ProduitId, Pays, Disponible)
create table Stock (
    ProduitId number(6),
    Pays varchar(20),
    Disponible number(1),
    constraint PK_Stock primary key (ProduitId, Pays)
);
--7.	Categorie (CategorieId, Nom, DateAjout) 
create table Categorie(
    CategorieId number(5),
    Nom varchar(20),
    DateAjout DATE,
    constraint PK_Categorie primary key(CategorieId) );

--8.	SousCategorie (SousCategorieId, _____, Nom, DateAjout) 
create table SousCategorie(
    SousCategorieId number(5),
    -- !!! Schéma relationnel faux
    Nom varchar(20),
    DateAjout DATE,
    constraint PK_SousCategorie primary key (SousCategorieId)    
);

--9.	CategorieSousCategorie (CSCId, CategorieId, SousCategorieId)
create table CategorieSousCategorie(
    CSCId number(5),
    CategorieId number(5),
    SousCategorieId number(5),
    constraint PK_CSC primary key (CSCId)
);
--10.	CentreDInteret (ClientId, CSCId)  
create table CentreDInteret(
    ClientId number(5),
    CSCId number(5),
    constraint PK_CentreInteret primary key (ClientId, CSCId)
);
--11.	Favori (ClientId, CSCId)
create table Favori(
    ClientId number(5), 
    CSCId number(5),
    constraint PK_Favori primary key (ClientId, CSCId)
);
--12.	NoteProduit (ClientId, ProduitId, Note) 
create table NoteProduit(
    ClientId number(5),
    ProduitId number(6),
    Note number(2),
    constraint PK_NoteProduit primary key (ClientId, ProduitId)
);


--13.	Recommandation (RecommandationId, ClientId, CSCId, DateHeure)
create table Recommandation (
    RecommandationId number(10),
    ClientId number(5), 
    CSCId number(5),
    DateHeure DATE,
    constraint PK_Recommandation primary key (RecommandationId)
);

--14.	RecommandationProduit (RecommandationId, ProduitId)
create table RecommandationProduit(
    RecommandationId number(10), 
    ProduitId number(6),
    constraint PK_RecommandationProduit primary key (RecommandationId, ProduitId)
);