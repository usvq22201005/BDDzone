-- Insert via GPT pour gagner du temps
-- et tester au plus vite les requêtes
-- correction dans les requêtes 
-- seront nécéssaire si le schéma
-- est modifié

-- 1️⃣ Référentiels de base (fondation)
insert into Client(ClientId, NomUtilisateur, Nom, Prenom, Adresse, Pays, aLocal)
values (1, 'nrod01', 'Dupont', 'Nicolas', '1 rue de Paris', 'France', 1);

insert into Client(ClientId, NomUtilisateur, Nom, Prenom, Adresse, Pays, aLocal)
values (2, 'lmartin', 'Martin', 'Lucie', '12 rue Lyon', 'France', 0);


insert into Fournisseur(FournisseurId, Nom, Pays, NoteFournisseur)
values (1, 'FournisseurA', 'France', 5);

insert into Fournisseur(FournisseurId, Nom, Pays, NoteFournisseur)
values (2, 'FournisseurB', 'Allemagne', 4);

-- Categories
insert into Categorie(CategorieId, Nom, DateAjout)
values (1, 'Informatique', sysdate);

insert into SousCategorie(SousCategorieId, CategorieId, Nom, DateAjout)
values (1, 1, 'Ordinateurs', sysdate);

insert into SousCategorie(SousCategorieId, CategorieId, Nom, DateAjout)
values (2, 1, 'Accessoires', sysdate);
--________________________________________________________________________________________________________________________________________________
--________________________________________________________________________________________________________________________________________________
-- CategorieSousCategorie
insert into CategorieSousCategorie(CSCId, CategorieId, SousCategorieId)
values (1, 1, 1);

insert into CategorieSousCategorie(CSCId, CategorieId, SousCategorieId)
values (2, 1, 2);

-- PRODUITS
insert into Produit(ProduitId, FournisseurId, CategorieId, SousCategorieId, Nom, Prix, NoteProduit)
values (1, 1, 1, 1, 'PC Portable', 1200, 5);

insert into Produit(ProduitId, FournisseurId, CategorieId, SousCategorieId, Nom, Prix, NoteProduit)
values (2, 2, 1, 2, 'Souris Gamer', 50, 4);

-- 6️⃣ Commandes et ProduitsCommandes
insert into Commande(CommandeId, ClientId, DateCommande, PrixTotal)
values (1, 1, sysdate, 1250);

insert into ProduitCommande(CommandeId, ProduitId, Quantite, Prix)
values (1, 1, 1, 1200);

insert into ProduitCommande(CommandeId, ProduitId, Quantite, Prix)
values (1, 2, 1, 50);

-- 7️⃣ Centres d’intérêt et Favoris
insert into CentreDInteret(ClientId, CategorieId, SousCategorieId)
values (1, 1, 1);

insert into Favori(ClientId, CategorieId, SousCategorieId)
values (1, 1, 2);

--  8️⃣ Notes et Recommandations
insert into NoteProduit(ClientId, ProduitId, Note)
values (1, 1, 5);

insert into Recommandation(RecommandationId, ClientId, CSCId, DateHeure)
values (1, 1, 1, sysdate);

insert into RecommandationProduit(RecommandationId, ProduitId)
values (1, 1);

