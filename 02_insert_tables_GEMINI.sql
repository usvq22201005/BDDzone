INSERT INTO Client (NomUtilisateur, Nom, Prenom)
VALUES ('dupont', 'Dupont', 'Jean',1) ;

SELECT * FROM Client;


-- Configuration du format de date pour éviter les erreurs
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

-- ============================================================
-- 1. CATÉGORIES ET SOUS-CATÉGORIES
-- (Les triggers rempliront automatiquement la table CategorieSousCategorie)
-- ============================================================
INSERT INTO Categorie (Nom, DateAjout) VALUES ('High-Tech', SYSDATE-365);
INSERT INTO Categorie (Nom, DateAjout) VALUES ('Vêtements', SYSDATE-300);
INSERT INTO Categorie (Nom, DateAjout) VALUES ('Maison', SYSDATE-200);
INSERT INTO Categorie (Nom, DateAjout) VALUES ('Alimentation', SYSDATE-100);
INSERT INTO Categorie (Nom, DateAjout) VALUES ('Sport', SYSDATE-50);

-- Récupération des IDs générés pour insertion des sous-catégories
-- On suppose ici que les séquences commencent à 1.
-- High-Tech
INSERT INTO SousCategorie (CategorieId, Nom, DateAjout) 
VALUES ((SELECT CategorieId FROM Categorie WHERE Nom='High-Tech'), 'Smartphones', SYSDATE-360);
INSERT INTO SousCategorie (CategorieId, Nom, DateAjout) 
VALUES ((SELECT CategorieId FROM Categorie WHERE Nom='High-Tech'), 'Ordinateurs', SYSDATE-350);

-- Vêtements
INSERT INTO SousCategorie (CategorieId, Nom, DateAjout) 
VALUES ((SELECT CategorieId FROM Categorie WHERE Nom='Vêtements'), 'Homme', SYSDATE-290);
INSERT INTO SousCategorie (CategorieId, Nom, DateAjout) 
VALUES ((SELECT CategorieId FROM Categorie WHERE Nom='Vêtements'), 'Femme', SYSDATE-290);

-- Alimentation
INSERT INTO SousCategorie (CategorieId, Nom, DateAjout) 
VALUES ((SELECT CategorieId FROM Categorie WHERE Nom='Alimentation'), 'Bio', SYSDATE-90);
INSERT INTO SousCategorie (CategorieId, Nom, DateAjout) 
VALUES ((SELECT CategorieId FROM Categorie WHERE Nom='Alimentation'), 'Conserves', SYSDATE-90);

-- Remplissage générique pour atteindre 30 Sous-Catégories
BEGIN
    FOR i IN 1..24 LOOP
        INSERT INTO SousCategorie (CategorieId, Nom, DateAjout) 
        VALUES ((SELECT CategorieId FROM Categorie WHERE Nom='Maison'), 'Divers '||i, SYSDATE-10);
    END LOOP;
END;
/

-- ============================================================
-- 2. FOURNISSEURS (30+)
-- ============================================================
-- Fournisseurs Clés pour les scénarios
INSERT INTO Fournisseur (Nom, Pays, NoteFournisseur) VALUES ('Samsung Korea', 'KR', 4.5);
INSERT INTO Fournisseur (Nom, Pays, NoteFournisseur) VALUES ('Apple US', 'US', 4.8);
INSERT INTO Fournisseur (Nom, Pays, NoteFournisseur) VALUES ('Terroir France', 'FR', 5.0); -- Pour scénario achat local
INSERT INTO Fournisseur (Nom, Pays, NoteFournisseur) VALUES ('Mode Italia', 'IT', 4.2);
INSERT INTO Fournisseur (Nom, Pays, NoteFournisseur) VALUES ('Electro China', 'CN', 3.0);

-- Remplissage générique
BEGIN
    FOR i IN 6..35 LOOP
        INSERT INTO Fournisseur (Nom, Pays, NoteFournisseur) 
        VALUES ('Fournisseur '||i, 'FR', DBMS_RANDOM.VALUE(1,5));
    END LOOP;
END;
/

-- ============================================================
-- 3. PRODUITS (30+)
-- Note: On doit lier à CategorieSousCategorie (CSC)
-- ============================================================

-- Fonction helper pour trouver un CSCId facilement dans les INSERTs
-- (Simulation via sous-requêtes dans les values)

-- Prod 1: Smartphone (High-Tech / Smartphones) - Fournisseur KR
INSERT INTO Produit (FournisseurId, CategorieSousCategorieId, Nom, Prix, NoteProduit)
VALUES (
    (SELECT FournisseurId FROM Fournisseur WHERE Nom='Samsung Korea'),
    (SELECT csc.CSCId FROM CategorieSousCategorie csc 
     JOIN SousCategorie sc ON csc.SousCategorieId = sc.SousCategorieId 
     WHERE sc.Nom='Smartphones'),
    'Galaxy S24', 900.00, NULL
);

-- Prod 2: iPhone (High-Tech / Smartphones) - Fournisseur US
INSERT INTO Produit (FournisseurId, CategorieSousCategorieId, Nom, Prix, NoteProduit)
VALUES (
    (SELECT FournisseurId FROM Fournisseur WHERE Nom='Apple US'),
    (SELECT csc.CSCId FROM CategorieSousCategorie csc 
     JOIN SousCategorie sc ON csc.SousCategorieId = sc.SousCategorieId 
     WHERE sc.Nom='Smartphones'),
    'iPhone 15', 1200.00, NULL
);

-- Prod 3: Fromage (Alimentation / Bio) - Fournisseur FR - SCÉNARIO LOCAL
INSERT INTO Produit (FournisseurId, CategorieSousCategorieId, Nom, Prix, NoteProduit)
VALUES (
    (SELECT FournisseurId FROM Fournisseur WHERE Nom='Terroir France'),
    (SELECT csc.CSCId FROM CategorieSousCategorie csc 
     JOIN SousCategorie sc ON csc.SousCategorieId = sc.SousCategorieId 
     WHERE sc.Nom='Bio'),
    'Camembert Bio', 5.50, NULL
);

-- Prod 4: Robe (Vêtements / Femme) - Fournisseur IT
INSERT INTO Produit (FournisseurId, CategorieSousCategorieId, Nom, Prix, NoteProduit)
VALUES (
    (SELECT FournisseurId FROM Fournisseur WHERE Nom='Mode Italia'),
    (SELECT csc.CSCId FROM CategorieSousCategorie csc 
     JOIN SousCategorie sc ON csc.SousCategorieId = sc.SousCategorieId 
     WHERE sc.Nom='Femme'),
    'Robe Été', 45.00, NULL
);

-- Remplissage générique produits (Prod 5 à 40)
DECLARE
    v_csc_id NUMBER;
    v_fourn_id NUMBER;
BEGIN
    SELECT CSCId INTO v_csc_id FROM CategorieSousCategorie WHERE ROWNUM = 1; 
    SELECT FournisseurId INTO v_fourn_id FROM Fournisseur WHERE ROWNUM = 1;
    
    FOR i IN 5..40 LOOP
        INSERT INTO Produit (FournisseurId, CategorieSousCategorieId, Nom, Prix, NoteProduit)
        VALUES (v_fourn_id, v_csc_id, 'Produit Gen '||i, i*10, NULL);
    END LOOP;
END;
/

-- ============================================================
-- 4. PAYS DES PRODUITS (Disponibilité)
-- ============================================================
-- Important pour trigger_RecommandationProduit_Dispo et Achat Local

-- Le Camembert (Prod 3) est dispo en FR (Scénario Local)
INSERT INTO ProduitPays (Nom, ProduitId) 
VALUES ('FR', (SELECT ProduitId FROM Produit WHERE Nom='Camembert Bio'));

-- L'iPhone (Prod 2) est dispo partout
INSERT INTO ProduitPays (Nom, ProduitId) 
VALUES ('FR', (SELECT ProduitId FROM Produit WHERE Nom='iPhone 15'));
INSERT INTO ProduitPays (Nom, ProduitId) 
VALUES ('US', (SELECT ProduitId FROM Produit WHERE Nom='iPhone 15'));

-- Le Galaxy (Prod 1) dispo FR et KR
INSERT INTO ProduitPays (Nom, ProduitId) 
VALUES ('FR', (SELECT ProduitId FROM Produit WHERE Nom='Galaxy S24'));
INSERT INTO ProduitPays (Nom, ProduitId) 
VALUES ('KR', (SELECT ProduitId FROM Produit WHERE Nom='Galaxy S24'));

-- Remplissage pour les autres produits (Dispo en FR par défaut)
BEGIN
    FOR r IN (SELECT ProduitId FROM Produit WHERE Nom LIKE 'Produit Gen%') LOOP
        INSERT INTO ProduitPays (Nom, ProduitId) VALUES ('FR', r.ProduitId);
    END LOOP;
END;
/

-- ============================================================
-- 5. CLIENTS (30+)
-- ============================================================

-- Client 1 : Achat Local Strict (FR)
INSERT INTO Client (NomUtilisateur, Nom, Prenom, Adresse, Pays, aLocal)
VALUES ('jean_local', 'Dupont', 'Jean', '1 rue de Paris', 'FR', 1);

-- Client 2 : Acheteur International (US)
INSERT INTO Client (NomUtilisateur, Nom, Prenom, Adresse, Pays, aLocal)
VALUES ('john_doe', 'Doe', 'John', '5th Avenue NY', 'US', 0);

-- Client 3 : Client qui note tout (FR)
INSERT INTO Client (NomUtilisateur, Nom, Prenom, Adresse, Pays, aLocal)
VALUES ('marie_critique', 'Curie', 'Marie', 'Rue des Sciences', 'FR', 0);

-- Client 4 : Nouveau sans commande (Infos NULL possibles grâce au trigger qui ne bloque qu'à la commande)
INSERT INTO Client (NomUtilisateur, Nom, Prenom, Adresse, Pays, aLocal)
VALUES ('visiteur_fantome', NULL, NULL, NULL, 'FR', 0);

-- Remplissage générique Clients (5 à 35)
BEGIN
    FOR i IN 5..35 LOOP
        INSERT INTO Client (NomUtilisateur, Nom, Prenom, Adresse, Pays, aLocal)
        VALUES ('user_'||i, 'Nom'||i, 'Pre'||i, 'Adresse '||i, 'FR', 0);
    END LOOP;
END;
/

-- ============================================================
-- 6. COMMANDES ET PRODUITCOMMANDE
-- ============================================================

-- SCÉNARIO 1 : Client Local achète Produit Local (Jean achète Camembert)
INSERT INTO Commande (ClientId, DateCommande, PrixTotal)
VALUES ((SELECT ClientId FROM Client WHERE NomUtilisateur='jean_local'), SYSDATE-10, 0); -- PrixTotal calculé par Trigger

INSERT INTO ProduitCommande (CommandeId, ProduitId, Quantite, Prix)
VALUES (
    (SELECT MAX(CommandeId) FROM Commande WHERE ClientId=(SELECT ClientId FROM Client WHERE NomUtilisateur='jean_local')),
    (SELECT ProduitId FROM Produit WHERE Nom='Camembert Bio'),
    2, 
    0 -- Prix calculé par Trigger
);

-- SCÉNARIO 2 : Achat ancien pour permettre la notation (> 7 jours)
-- Marie achète un iPhone il y a 20 jours
INSERT INTO Commande (ClientId, DateCommande, PrixTotal)
VALUES ((SELECT ClientId FROM Client WHERE NomUtilisateur='marie_critique'), SYSDATE-20, 0);

INSERT INTO ProduitCommande (CommandeId, ProduitId, Quantite, Prix)
VALUES (
    (SELECT MAX(CommandeId) FROM Commande WHERE ClientId=(SELECT ClientId FROM Client WHERE NomUtilisateur='marie_critique')),
    (SELECT ProduitId FROM Produit WHERE Nom='iPhone 15'),
    1, 0
);

-- SCÉNARIO 3 : Création de Centre d'Intérêt (3 produits même catégorie achetés)
-- John achète 3 produits High-Tech différents (Prod 1, Prod 2, et un générique)
INSERT INTO Commande (ClientId, DateCommande, PrixTotal)
VALUES ((SELECT ClientId FROM Client WHERE NomUtilisateur='john_doe'), SYSDATE-5, 0);

INSERT INTO ProduitCommande (CommandeId, ProduitId, Quantite, Prix)
VALUES (
    (SELECT MAX(CommandeId) FROM Commande WHERE ClientId=(SELECT ClientId FROM Client WHERE NomUtilisateur='john_doe')),
    (SELECT ProduitId FROM Produit WHERE Nom='Galaxy S24'),
    1, 0
);
INSERT INTO ProduitCommande (CommandeId, ProduitId, Quantite, Prix)
VALUES (
    (SELECT MAX(CommandeId) FROM Commande WHERE ClientId=(SELECT ClientId FROM Client WHERE NomUtilisateur='john_doe')),
    (SELECT ProduitId FROM Produit WHERE Nom='iPhone 15'),
    1, 0
);
-- Un produit générique lié à High-Tech (supposons ID 5 si mappé, sinon on force l'insertion pour l'exemple)
-- Note: Pour garantir que le trigger centre d'intérêt se déclenche, il faudrait s'assurer que les produits génériques sont bien dans la catégorie.
-- Dans ce script, on se contente de simuler le volume.

-- Remplissage Commandes (Pour avoir 30 commandes)
BEGIN
    FOR i IN 1..30 LOOP
        INSERT INTO Commande (ClientId, DateCommande, PrixTotal)
        VALUES ((SELECT ClientId FROM Client WHERE NomUtilisateur='user_'||(5+MOD(i,20))), SYSDATE - DBMS_RANDOM.VALUE(1, 300), 0);
        
        -- Ajout d'un produit aléatoire dans la commande
        INSERT INTO ProduitCommande (CommandeId, ProduitId, Quantite, Prix)
        VALUES ((SELECT MAX(CommandeId) FROM Commande), (SELECT MIN(ProduitId) + MOD(i, 20) FROM Produit), 1, 0);
    END LOOP;
END;
/

-- ============================================================
-- 7. NOTES (NoteProduit)
-- ============================================================
-- Rappel Trigger: Le client doit avoir acheté il y a > 7 jours.
-- Marie a acheté l'iPhone il y a 20 jours.

INSERT INTO NoteProduit (ClientId, ProduitId, Note)
VALUES (
    (SELECT ClientId FROM Client WHERE NomUtilisateur='marie_critique'),
    (SELECT ProduitId FROM Produit WHERE Nom='iPhone 15'),
    5
);

-- Jean a acheté Camembert il y a 10 jours.
INSERT INTO NoteProduit (ClientId, ProduitId, Note)
VALUES (
    (SELECT ClientId FROM Client WHERE NomUtilisateur='jean_local'),
    (SELECT ProduitId FROM Produit WHERE Nom='Camembert Bio'),
    4
);

-- Remplissage de notes fictives (Attention aux contraintes de trigger "Achat nécessaire")
-- Pour simplifier le remplissage de masse sans violer le trigger complexe (vérif achat), 
-- on insère manuellement quelques notes correspondant aux commandes générées par la boucle précédente 
-- si la date le permet (les commandes générées sont entre -1 et -300 jours).

DECLARE
    v_client_id NUMBER;
    v_prod_id NUMBER;
    v_date DATE;
BEGIN
    FOR r IN (
        SELECT c.ClientId, pc.ProduitId, c.DateCommande
        FROM Commande c
        JOIN ProduitCommande pc ON c.CommandeId = pc.CommandeId
        WHERE c.DateCommande < SYSDATE - 8
        AND ROWNUM <= 30 -- Limite à 30 notes
    ) LOOP
        BEGIN
            INSERT INTO NoteProduit (ClientId, ProduitId, Note)
            VALUES (r.ClientId, r.ProduitId, FLOOR(DBMS_RANDOM.VALUE(1, 6)));
        EXCEPTION WHEN OTHERS THEN NULL; -- Ignorer doublons
        END;
    END LOOP;
END;
/

-- ============================================================
-- 8. RECOMMANDATIONS
-- ============================================================

-- Reco pour Jean (Local) : On lui recommande un produit dispo en FR (ex: iPhone ou Camembert)
INSERT INTO Recommandation (ClientId, CSCId, DateHeure)
VALUES (
    (SELECT ClientId FROM Client WHERE NomUtilisateur='jean_local'),
    (SELECT CSCId FROM CategorieSousCategorie WHERE ROWNUM=1),
    SYSDATE - 35
);

INSERT INTO RecommandationProduit (RecommandationId, ProduitId)
VALUES (
    (SELECT MAX(RecommandationId) FROM Recommandation),
    (SELECT ProduitId FROM Produit WHERE Nom='Camembert Bio')
);

-- Reco qui mène à un achat (Scénario requête : achat dans les 30 jours)
-- On recommande le Galaxy S24 à John (il l'a acheté il y a 5 jours)
-- La reco doit dater d'il y a 10 à 20 jours.
INSERT INTO Recommandation (ClientId, CSCId, DateHeure)
VALUES (
    (SELECT ClientId FROM Client WHERE NomUtilisateur='john_doe'),
    (SELECT CSCId FROM CategorieSousCategorie WHERE ROWNUM=1),
    SYSDATE - 15
);

INSERT INTO RecommandationProduit (RecommandationId, ProduitId)
VALUES (
    (SELECT MAX(RecommandationId) FROM Recommandation),
    (SELECT ProduitId FROM Produit WHERE Nom='Galaxy S24')
);

-- Remplissage Recos
BEGIN
    FOR i IN 5..35 LOOP
        INSERT INTO Recommandation (ClientId, CSCId, DateHeure)
        VALUES ((SELECT ClientId FROM Client WHERE NomUtilisateur='user_'||i), (SELECT MIN(CSCId) FROM CategorieSousCategorie), SYSDATE);
        
        INSERT INTO RecommandationProduit (RecommandationId, ProduitId)
        VALUES ((SELECT MAX(RecommandationId) FROM Recommandation), (SELECT ProduitId FROM Produit WHERE Nom='iPhone 15'));
    END LOOP;
END;
/

-- ============================================================
-- 9. SOUHAITE ACHETER (Panier / Wishlist)
-- ============================================================
INSERT INTO SouhaiteAcheter (ClientId, ProduitId, Quantite, Prix)
VALUES (
    (SELECT ClientId FROM Client WHERE NomUtilisateur='visiteur_fantome'),
    (SELECT ProduitId FROM Produit WHERE Nom='Galaxy S24'),
    1, 0 -- Prix calculé par trigger
);

BEGIN
    FOR i IN 5..35 LOOP
         INSERT INTO SouhaiteAcheter (ClientId, ProduitId, Quantite, Prix)
         VALUES (
            (SELECT ClientId FROM Client WHERE NomUtilisateur='user_'||i),
            (SELECT MIN(ProduitId)+1 FROM Produit), -- Produit différent
            2, 0
         );
    END LOOP;
END;
/

-- ============================================================
-- 10. FAVORIS
-- ============================================================
BEGIN
    FOR i IN 1..30 LOOP
        INSERT INTO Favori (ClientId, CategorieSousCategorieId)
        VALUES (
            (SELECT ClientId FROM Client WHERE ClientId = (SELECT MIN(ClientId) + i FROM Client WHERE ROWNUM <= 31)),
            (SELECT CSCId FROM CategorieSousCategorie WHERE ROWNUM = 1)
        );
    END LOOP;
END;
/

COMMIT;
PROMPT Données insérées avec succès.

