-- Insert via GPT pour gagner du temps
-- et tester au plus vite les requêtes
-- correction dans les requêtes 
-- seront nécéssaire si le schéma
-- est modifié

-- 1️⃣ Référentiels de base (fondation)
insert into Client(ClientId, NomUtilisateur, Nom, Prenom, Adresse, Pays, aLocal) 
values (1, 'jdoe', 'Doe', 'John', '1 rue A', 'FR', 1);
insert into Client(ClientId, NomUtilisateur, Nom, Prenom, Adresse, Pays, aLocal) 
values (2, 'asmith', 'Smith', 'Alice', '2 rue B', 'FR', 0);

insert into Fournisseur(ClientId, ProduitId, Quantite, Prix) values (1, 'Sony', 'JP', 5);
insert into Fournisseur(ClientId, ProduitId, Quantite, Prix) values (2, 'Dell', 'US', 4);

insert into Categorie(CategorieId,Nom,DateAjout) 
values (1, 'Informatique', sysdate);
insert into Categorie(CategorieId,Nom,DateAjout) 
values (2, 'Audio', sysdate);

insert into SousCategorie(SousCategorieId,Nom,DateAjout) values (1, 'PC Portable', sysdate);
insert into SousCategorie(SousCategorieId,Nom,DateAjout) values (2, 'Casque', sysdate);

-- 2️⃣ Lien catégorie ↔ sous-catégorie (CSC = vérité)
insert into CategorieSousCategorie(CSCId, CategorieId, SousCategorieId) values (1, 1, 1); -- Informatique / PC
insert into CategorieSousCategorie(CSCId, CategorieId, SousCategorieId) values (2, 2, 2); -- Audio / Casque

-- 3️⃣ Produits + stock
-- insert into Produit values (1, 2, 1, 1, 'Laptop Dell X', 899.99, 4);
insert into Produit(ProduitId, FournisseurId, CategorieId,
SousCategorieId, Nom, Prix, NoteProduit(ClientId, ProduitId, Note)) 
values (2, 1, 2, 2, 'Casque Sony Z', 199.99, 5);

insert into Stock values (1, 'FR', 1);
insert into Stock values (2, 'FR', 1);

-- 4️⃣ Commandes & lignes de commande
insert into Commande(CommandeId,ClientId,DateCommande,PrixTotal)
 values (1, 1, sysdate, 1099.98);

insert into ProduitCommande(CommandeId,ProduitId,Quantite,Prix) 
values (1, 1, 1, 899.99);
insert into ProduitCommande(CommandeId,ProduitId,Quantite,Prix) 
values (1, 2, 1, 199.99);


-- 5️⃣ Intention, favoris, notes
insert into SouhaiteAcheter(ClientId,ProduitId,Quantite,Prix)
 values (2, 2, 1, 199.99);

insert into CentreDInteret(ClientId, CSCId)
 values (1, 1);
insert into Favori values (1, 2);

insert into NoteProduit(ClientId, ProduitId, Note) values (1, 1, 4);
insert into NoteProduit(ClientId, ProduitId, Note) values (1, 2, 5);

-- 6️⃣ Recommandations

insert into Recommandation(RecommandationId, ClientId, CSCId, DateHeure)
 values (1, 1, 2, sysdate);
insert into RecommandationProduit values (1, 2);

--7️⃣ Commit (ne pas oublier…)
commit;
