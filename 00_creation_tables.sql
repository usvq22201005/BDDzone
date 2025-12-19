--1.Client (ClientId, NomUtilisateur, Nom, Prenom,
-- Adresse, Pays, Local)
create table Client(
    ClientId number(5) NOT NULL,
    NomUtilisateur varchar(50) NOT NULL,
    Nom varchar(50),
    Prenom varchar(50),
    Adresse varchar(100),
    Pays varchar(2), -- Utilisation de la norme ISO d'identification des pays par 2 caractères
    aLocal NUMBER(1) CHECK (aLocal IN (0,1)) NOT NULL,
    constraint PK_Client primary key (ClientId), -- on evite les doublons...
    constraint UNIQUE_Client_NomUtilisateur UNIQUE (NomUtilisateur) -- de même
);

--6.	Fournisseur (FournisseurId, Nom, Pays, NoteFournisseur) 
create table Fournisseur(
    FournisseurId number(5) NOT NULL, 
    Nom varchar(20) NOT NULL,
    Pays varchar(2) NOT NULL,
    NoteFournisseur number(2,1) CHECK (NoteFournisseur BETWEEN 1 AND 5),
    constraint PK_Fournisseur primary key (FournisseurId)
);

--7.	Categorie (CategorieId, Nom, DateAjout) 
create table Categorie(
    CategorieId number(5) NOT NULL,
    Nom varchar(20) NOT NULL,
    DateAjout DATE,
    constraint PK_Categorie primary key(CategorieId)
);

--8.	SousCategorie (SousCategorieId, CategorieId, Nom, DateAjout) 
create table SousCategorie(
    SousCategorieId number(5) NOT NULL,
    CategorieId number(5) NOT NULL,
    Nom varchar(20) NOT NULL,
    DateAjout DATE,
    constraint PK_SousCategorie primary key (SousCategorieId),
    constraint FK_SC_Categorie
        foreign key (CategorieId)
        references Categorie(CategorieId)    
);

--9.	CategorieSousCategorie (CSCId, CategorieId, SousCategorieId)
create table CategorieSousCategorie(
    CSCId number(5) NOT NULL,
    CategorieId number(5) NOT NULL,
    SousCategorieId number(5), -- peut être NULL
    constraint PK_CSC primary key (CSCId),
    constraint FK_CSC_Categorie foreign key (CategorieId)
        references Categorie(CategorieId),
    constraint FK_CSC_SousCategorie foreign key (SousCategorieId)
        references SousCategorie(SousCategorieId),
    constraint UNIQUE_CSC UNIQUE (CategorieId, SousCategorieId)
);

--2.	Produit (ProduitId, FournisseurId, CategorieId,
-- SousCategorieId, Nom, Prix, NoteProduit) 
create table Produit (
    ProduitId number(6) NOT NULL,
    FournisseurId number(5) NOT NULL,
    CategorieSousCategorieId number(5) NOT NULL,
    Nom varchar(50) NOT NULL,
    Prix number(10,2) CHECK (Prix >= 0) NOT NULL,-- Valeur max=99999999.99
    Noteproduit number(2,1) CHECK (NoteProduit BETWEEN 1 AND 5),
    constraint PK_Produit primary key (ProduitId),
    constraint FK_Produit_Fournisseur
        foreign key (FournisseurId)
        references Fournisseur(FournisseurId),
    constraint FK_Produit_CSC
        foreign key (CategorieSousCategorieId)
        references CategorieSousCategorie(CSCId)
);

--3.	Commande (CommandeId, ClientId, 
--DateCommande, PrixTotal)
create table Commande(
    CommandeId number (5) NOT NULL,
    ClientId number(5) NOT NULL,
    DateCommande DATE,
    PrixTotal number(10,2) CHECK (PrixTotal >= 0),
    constraint PK_Commande primary key (CommandeId),
    --clée etrangères :
    constraint FK_Commande_Client
        foreign key (ClientId)
        references Client(ClientId)
);

--4.	ProduitCommande (CommandeId, ProduitId,
--Quantite, Prix) 
create table ProduitCommande(
        CommandeId number(5) NOT NULL,
        ProduitId number(6) NOT NULL,
        Quantite number(5) CHECK (Quantite >= 0) NOT NULL,
        Prix number(10,2) CHECK (Prix >= 0) NOT NULL,
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
    ClientId number(5) NOT NULL,
    ProduitId number(6) NOT NULL,
    Quantite number(5) CHECK (Quantite >= 0) NOT NULL,
    Prix number(10,2) CHECK (Prix >= 0) NOT NULL,
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
    ClientId number(5) NOT NULL,
    CategorieSousCategorieId number(5) NOT NULL,
    constraint PK_CentreInteret primary key (ClientId, CategorieSousCategorieId),
    constraint FK_CI_Client
        foreign key (ClientId)
        references Client(ClientId),
    constraint FK_CI_CategorieSousCategorie
        foreign key (CategorieSousCategorieId)
        references CategorieSousCategorie(CSCId)
);

--11.	Favori (ClientId, CategorieId,SousCategorieId)
create table Favori(
    ClientId number(5) NOT NULL, 
    CategorieSousCategorieId number(5) NOT NULL,
    constraint PK_Favori primary key (ClientId, CategorieSousCategorieId),
    constraint FK_F_Client
        foreign key (ClientId)
        references Client(ClientId),
    constraint FK_F_CategorieSousCategorie
        foreign key (CategorieSousCategorieId)
        references CategorieSousCategorie(CSCId)
);

--12.	NoteProduit (ClientId, ProduitId, Note) 
create table NoteProduit(
    ClientId number(5) NOT NULL,
    ProduitId number(6) NOT NULL,
    Note number(1) CHECK (Note BETWEEN 1 AND 5) NOT NULL,
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
    RecommandationId number(10) NOT NULL,
    ClientId number(5) NOT NULL, 
    CSCId number(5) NOT NULL,
    DateHeure DATE,
    constraint PK_Recommandation primary key (RecommandationId),
    constraint FK_Reco_Client foreign key(ClientId)
        references Client(ClientId),
    constraint FK_Reco_CSC foreign key(CSCId)
        references CategorieSousCategorie(CSCId)
);

--14.	RecommandationProduit (RecommandationId, ProduitId)
create table RecommandationProduit(
    RecommandationId number(10) NOT NULL, 
    ProduitId number(6) NOT NULL,
    constraint PK_RecommandationProduit primary key (RecommandationId, ProduitId),
    constraint FK_RP_Recommandation
        foreign key (RecommandationId)
        references Recommandation(RecommandationId),
    constraint FK_RP_Produit
        foreign key (ProduitId)
        references Produit(ProduitId)
);

--15.	Pays (Nom, ProduitId)
create table ProduitPays (
    Nom varchar(2) NOT NULL,
    ProduitId number(6) NOT NULL,
    constraint FK_Pays_Produit
        foreign key (ProduitId)
        references Produit(ProduitId),
    constraint PK_ProduitPays primary key (Nom, ProduitId)
);
