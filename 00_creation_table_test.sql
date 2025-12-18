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

--6.	Fournisseur (FournisseurId, Nom, Pays, NoteFournisseur) 
create table Fournisseur(
    FournisseurId number(5), 
    Nom varchar(20),
    Pays varchar(30),
    NoteFournisseur number(2),
    constraint PK_Fournisseur primary key (FournisseurId)
);

--7.	Categorie (CategorieId, Nom, DateAjout) 
create table Categorie(
    CategorieId number(5),
    Nom varchar(20),
    DateAjout DATE,
    constraint PK_Categorie primary key(CategorieId)
);

--8.	SousCategorie (SousCategorieId, CategorieId, Nom, DateAjout) 
create table SousCategorie(
    SousCategorieId number(5),
    CategorieId number(5),
    Nom varchar(20),
    DateAjout DATE,
    constraint PK_SousCategorie primary key (SousCategorieId),
    constraint FK_SC_Categorie
        foreign key (CategorieId)
        references Categorie(CategorieId)    
);

--9.	CategorieSousCategorie (CSCId, CategorieId, SousCategorieId)
create table CategorieSousCategorie(
    CSCId number(5),
    CategorieId number(5),
    SousCategorieId number(5),
    constraint PK_CSC primary key (CSCId),
    constraint FK_CSC_Categorie foreign key (CategorieId)
        references Categorie(CategorieId),
    constraint FK_CSC_SousCategorie foreign key (SousCategorieId)
        references SousCategorie(SousCategorieId)
);

--2.	Produit (ProduitId, FournisseurId, CategorieId,
-- SousCategorieId, Nom, Prix) 
create table Produit (
    ProduitId number(6),
    FournisseurId number(5),
    CategorieId number(5),
    SousCategorieId number(5),
    Nom varchar(50),
    Prix number(10,2),  -- Valeur max=99999999.99
    constraint PK_Produit primary key (ProduitId),
    constraint FK_Produit_Fournisseur
        foreign key (FournisseurId)
        references Fournisseur(FournisseurId),
    constraint FK_Produit_Categorie
        foreign key (CategorieId)
        references Categorie(CategorieId),
    constraint FK_Produit_SousCategorie
        foreign key (SousCategorieId)
        references SousCategorie(SousCategorieId)
);

--3.	Commande (CommandeId, ClientId, 
--DateCommande, PrixTotal)
create table Commande(
    CommandeId number (5),
    ClientId number(5),
    DateCommande DATE,
    PrixTotal number(10,2),
    constraint PK_Commande primary key (CommandeId),
    --clée etrangères :
    constraint FK_Commande_Client
        foreign key (ClientId)
        references Client(ClientId)
);

--4.	ProduitCommande (CommandeId, ProduitId,
--Quantite, Prix) 
create table ProduitCommande(
        CommandeId number(5),
        ProduitId number(6),
        Quantite number(5),
        Prix number(10,2),
        constraint PK_ProduitCommande primary key (CommandeId, ProduitId),
        --clée etrengères :
        constraint FK_PC_Commande
        foreign key (CommandeId)
        references Commande(CommandeId),
        constraint FK_PC_Produit
        foreign key (ProduitId)
        references Produit(ProduitId)
);  

--5.	SouhaiteAcheter (ClientId, ProduitId, Quantite, Prix) 
create table SouhaiteAcheter(
    ClientId number(5),
    ProduitId number(6),
    Quantite number(5),
    Prix number(10,2),
    constraint PK_SouhaiteAcheter primary key (ClientId, ProduitId),
    constraint FK_SA_Client
        foreign key (ClientId)
        references Client(ClientId),
    constraint FK_SA_Produit
        foreign key (ProduitId)
        references Produit(ProduitId)
);

--10.	CentreDInteret (ClientId, CategorieId,SousCategorieId)  
create table CentreDInteret(
    ClientId number(5),
    CategorieId number(5),
    SousCategorieId number(5),
    constraint PK_CentreInteret primary key (ClientId, CategorieId, SousCategorieId),
    constraint FK_CI_Client
        foreign key (ClientId)
        references Client(ClientId),
    constraint FK_CI_Categorie
        foreign key (CategorieId)
        references Categorie(CategorieId),
    constraint FK_CI_SousCategorie
        foreign key (SousCategorieId)
        references SousCategorie(SousCategorieId)
);

--11.	Favori (ClientId, CSCId)
create table Favori(
    ClientId number(5), 
    CategorieId number(5),
    SousCategorieId number(5),
    constraint PK_Favori primary key (ClientId, CategorieId, SousCategorieId),
    constraint FK_F_Client
        foreign key (ClientId)
        references Client(ClientId),
    constraint FK_F_Categorie
        foreign key (CategorieId)
        references Categorie(CategorieId),
    constraint FK_F_SousCategorie
        foreign key (SousCategorieId)
        references SousCategorie(SousCategorieId)
);

--12.	NoteProduit (ClientId, ProduitId, Note) 
create table NoteProduit(
    ClientId number(5),
    ProduitId number(6),
    Note number(2),
    constraint PK_NoteProduit primary key (ClientId, ProduitId),
    constraint FK_Note_Client
        foreign key (ClientId)
        references Client(ClientId),
    constraint FK_Note_Produit
        foreign key (ProduitId)
        references Produit(ProduitId)
);

--13.	Recommandation (RecommandationId, ClientId, CSCId, DateHeure)
create table Recommandation (
    RecommandationId number(10),
    ClientId number(5), 
    CSCId number(5),
    DateHeure DATE,
    constraint PK_Recommandation primary key (RecommandationId),
    constraint FK_Reco_Client foreign key(ClientId)
        references Client(ClientId),
    constraint FK_Reco_CSC foreign key(CSCId)
        references CategorieSousCategorie(CSCId)
);

--14.	RecommandationProduit (RecommandationId, ProduitId)
create table RecommandationProduit(
    RecommandationId number(10), 
    ProduitId number(6),
    constraint PK_RecommandationProduit primary key (RecommandationId, ProduitId),
    constraint FK_RP_Recommandation
        foreign key (RecommandationId)
        references Recommandation(RecommandationId),
    constraint FK_RP_Produit
        foreign key (ProduitId)
        references Produit(ProduitId)
);
