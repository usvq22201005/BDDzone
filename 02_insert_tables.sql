    -- Insert via GPT pour gagner du temps
-- et tester au plus vite les requêtes
-- correction dans les requêtes 
-- seront nécéssaire si le schéma
-- est modifié

-- 1️⃣ Référentiels de base (fondation)
insert into Client(ClientId, NomUtilisateur, Nom, Prenom, Adresse, Pays, aLocal)
values (1, 'nrod01', 'Dupont', 'Nicolas', '1 rue de Paris', 'FR', 1);
insert into Client(ClientId, NomUtilisateur, Nom, Prenom, Adresse, Pays, aLocal)
values (2, 'lmartin', 'Martin', 'Lucie', '12 rue Lyon', 'FR', 0);


insert into Fournisseur(FournisseurId, Nom, Pays, NoteFournisseur)
values (1, 'FournisseurA', 'FR', 5);
insert into Fournisseur(FournisseurId, Nom, Pays, NoteFournisseur)
values (2, 'FournisseurB', 'DE', 4);

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
insert into Produit(ProduitId, FournisseurId, CategorieId, SousCategorieId, Nom, Prix,NoteProduit)
values (1, 1, 1, 1, 'PC Portable', 1200,5);
insert into Produit(ProduitId, FournisseurId, CategorieId, SousCategorieId, Nom, Prix,NoteProduit)
values (2, 2, 1, 2, 'Souris Gamer', 50,3.5);
insert into Produit(ProduitId, FournisseurId, CategorieId, SousCategorieId, Nom, Prix,NoteProduit)
values (3, 2, 1, 2, 'Casque Gamer', 70,2.5);

-- 6️⃣ Commandes et ProduitsCommandes
insert into Commande(CommandeId, ClientId, DateCommande, PrixTotal)
values (1, 1, sysdate, 1250);
insert into Commande(CommandeId, ClientId, DateCommande, PrixTotal)
values (2, 2, sysdate, 50);
insert into Commande(CommandeId, ClientId, DateCommande, PrixTotal)
values (3, 2, sysdate, 70);


insert into ProduitCommande(CommandeId, ProduitId, Quantite, Prix)
values (1, 1, 1, 1200);
insert into ProduitCommande(CommandeId, ProduitId, Quantite, Prix)
values (1, 2, 1, 50);
insert into ProduitCommande(CommandeId, ProduitId, Quantite, Prix)
values (2, 2, 1, 50);
insert into ProduitCommande(CommandeId, ProduitId, Quantite, Prix)
values (3, 3, 1, 70);


-- 7️⃣ Centres d’intérêt et Favoris
insert into CentreDInteret(ClientId, CategorieId, SousCategorieId)
values (1, 1, 1);
insert into CentreDInteret(ClientId, CategorieId, SousCategorieId)
values (2, 1, 2);
insert into CentreDInteret(ClientId, CategorieId, SousCategorieId)
values (2, 1, 1);


insert into Favori(ClientId, CategorieId, SousCategorieId)
values (2, 1, 1);
insert into Favori(ClientId, CategorieId, SousCategorieId)
values (2, 1, 2);
--  8️⃣ Notes et Recommandations
insert into NoteProduit(ClientId, ProduitId, Note)
values (1, 1, 5);
insert into NoteProduit(ClientId, ProduitId, Note)
values (1, 2, 1);
insert into NoteProduit(ClientId, ProduitId, Note)
values (1, 3, 4);
insert into NoteProduit(ClientId, ProduitId, Note)
values (2, 1, 5);
insert into NoteProduit(ClientId, ProduitId, Note)
values (2, 2, 2);
insert into NoteProduit(ClientId, ProduitId, Note)
values (2, 3, 3);

insert into Recommandation(RecommandationId, ClientId, CSCId, DateHeure)
values (1, 1, 1, sysdate);
insert into Recommandation(RecommandationId, ClientId, CSCId, DateHeure)
values (2, 2, 2, sysdate);
insert into Recommandation(RecommandationId, ClientId, CSCId, DateHeure)
values (3, 1, 1, sysdate);
insert into Recommandation(RecommandationId, ClientId, CSCId, DateHeure)
values (4, 1, 1, sysdate);
insert into Recommandation(RecommandationId, ClientId, CSCId, DateHeure)
values (5, 1, 1, sysdate);

insert into RecommandationProduit(RecommandationId, ProduitId)
values (1, 1);
insert into RecommandationProduit(RecommandationId, ProduitId)
values (2, 2);
insert into RecommandationProduit(RecommandationId, ProduitId)
values (3, 1);
insert into RecommandationProduit(RecommandationId, ProduitId)
values (4, 1);
insert into RecommandationProduit(RecommandationId, ProduitId)
values (5, 1);
-- Insertion souhait de lmartin
insert into SouhaiteAcheter(ClientId, ProduitId, Quantite, Prix) 
values (2,1,1,1200);
