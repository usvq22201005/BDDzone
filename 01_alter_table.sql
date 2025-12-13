--1 Produit → Fournisseur, Categorie, SousCategorie
alter table Produit
add constraint FK_Produit_Fournisseur
foreign key (FournisseurId) references Fournisseur(FournisseurId);

alter table Produit
add constraint FK_Produit_Categorie
foreign key (CategorieId) references Categorie(CategorieId);

alter table Produit
add constraint FK_Produit_SousCategorie
foreign key (SousCategorieId) references SousCategorie(SousCategorieId);


--2 Commande → Client
alter table Commande
add constraint FK_Commande_Client
foreign key (ClientId) references Client(ClientId);


-- 3 -- ProduitCommande → Commande, Produit
alter table ProduitCommande
add constraint FK_PC_Commande
foreign key (CommandeId) references Commande(CommandeId);

alter table ProduitCommande
add constraint FK_PC_Produit
foreign key (ProduitId) references Produit(ProduitId);


-- 4 -- SouhaiteAcheter → Client, Produit
alter table SouhaiteAcheter
add constraint FK_SA_Client
foreign key (ClientId) references Client(ClientId);

alter table SouhaiteAcheter
add constraint FK_SA_Produit
foreign key (ProduitId) references Produit(ProduitId);


-- 5 --  Stock → Produit
alter table Stock
add constraint FK_Stock_Produit
foreign key (ProduitId) references Produit(ProduitId);


-- 6 -- SousCategorie → Categorie
--alter table SousCategorie

-- Colonne categorieId syupprimmee
-- FK_SousCategorie_Categorie
--add constraint FK_SousCategorie_Categorie
--foreign key (CategorieId) references Categorie(CategorieId);


-- 7 --  CategorieSousCategorie → Categorie, SousCategorie
alter table CategorieSousCategorie
add constraint FK_CSC_Categorie
foreign key (CategorieId) references Categorie(CategorieId);

alter table CategorieSousCategorie
add constraint FK_CSC_SousCategorie
foreign key (SousCategorieId) references SousCategorie(SousCategorieId);


-- 8 --  CentreDInteret → Client, CSC
alter table CentreDInteret
add constraint FK_CDI_Client
foreign key (ClientId) references Client(ClientId);

alter table CentreDInteret
add constraint FK_CDI_CSC
foreign key (CSCId) references CategorieSousCategorie(CSCId);


-- 9 -- Favori → Client, CSC
alter table Favori
add constraint FK_Favori_Client
foreign key (ClientId) references Client(ClientId);

alter table Favori
add constraint FK_Favori_CSC
foreign key (CSCId) references CategorieSousCategorie(CSCId);


-- 10 --  NoteProduit → Client, Produit
alter table NoteProduit
add constraint FK_NP_Client
foreign key (ClientId) references Client(ClientId);

alter table NoteProduit
add constraint FK_NP_Produit
foreign key (ProduitId) references Produit(ProduitId);


-- 11 -- Recommandation → Client, CSC
alter table Recommandation
add constraint FK_Reco_Client
foreign key (ClientId) references Client(ClientId);

alter table Recommandation
add constraint FK_Reco_CSC
foreign key (CSCId) references CategorieSousCategorie(CSCId);


-- 12 --  RecommandationProduit → Recommandation, Produit
alter table RecommandationProduit
add constraint FK_RP_Recommandation
foreign key (RecommandationId) references Recommandation(RecommandationId);

alter table RecommandationProduit
add constraint FK_RP_Produit
foreign key (ProduitId) references Produit(ProduitId);
