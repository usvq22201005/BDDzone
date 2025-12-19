-- Trigger et Procédures Centre d'interet : Réalisé par Yusuf DUMLUPINAR
-- Une sous-catégorie devient centre d’intérêt si le client :
    -- a acheté dans l’année ou
    -- a au moins 3 produits de cette sous-catégorie dans son panier.
CREATE OR REPLACE PROCEDURE Maj_Centre_Interet (
    p_ClientId NUMBER,
    p_SousCategorieId NUMBER,
    p_CategorieId NUMBER
) AS
    nb_panier NUMBER;
    nb_commande NUMBER;
BEGIN
    -- Produits dans le panier
    SELECT COUNT(*)
    INTO nb_panier
    FROM SouhaiteAcheter sa
    JOIN Produit p ON sa.ProduitId = p.ProduitId
    WHERE sa.ClientId = p_ClientId
      AND p.SousCategorieId = p_SousCategorieId;

    -- Produits achetés dans l’année
    SELECT COUNT(*)
    INTO nb_commande
    FROM Commande c
    JOIN ProduitCommande pc ON c.CommandeId = pc.CommandeId
    JOIN Produit p ON pc.ProduitId = p.ProduitId
    WHERE c.ClientId = p_ClientId
      AND p.SousCategorieId = p_SousCategorieId
      AND c.DateCommande >= ADD_MONTHS(SYSDATE, -12);

    IF nb_panier >= 3 OR nb_commande >= 1 THEN
        INSERT INTO CentreDInteret (ClientId, CategorieId, SousCategorieId)
        VALUES (p_ClientId, p_CategorieId, p_SousCategorieId);
    END IF;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        NULL;
END;
/

-- Trigger qui sera execute apres chaque insertion dans Panier Mettre à jour les centre d'interets
CREATE OR REPLACE TRIGGER TR_CentreInteret_Panier
AFTER INSERT ON SouhaiteAcheter
FOR EACH ROW
DECLARE
    v_cat NUMBER;
    v_scat NUMBER;
BEGIN
    SELECT CategorieId, SousCategorieId
    INTO v_cat, v_scat
    FROM Produit
    WHERE ProduitId = :NEW.ProduitId;

    Maj_Centre_Interet(:NEW.ClientId, v_scat, v_cat);
END;
/

-- Trigger qui sera execute apres chaque nouvelle commande pour Mettre à jour les centre d'interets
CREATE OR REPLACE TRIGGER TR_CentreInteret_Commande
AFTER INSERT ON ProduitCommande
FOR EACH ROW
DECLARE
    v_client NUMBER;
    v_cat NUMBER;
    v_scat NUMBER;
BEGIN
    SELECT ClientId INTO v_client
    FROM Commande
    WHERE CommandeId = :NEW.CommandeId;

    SELECT CategorieId, SousCategorieId
    INTO v_cat, v_scat
    FROM Produit
    WHERE ProduitId = :NEW.ProduitId;

    Maj_Centre_Interet(v_client, v_scat, v_cat);
END;
/


-- Trigger NOTES : Réalisé par Yusuf DUMLUPINAR
-- Un client peut donner à un produit qu’il a acheté il y a au moins une semaine une note entière entre 1 et 5.
CREATE OR REPLACE TRIGGER TR_Note_Verification
BEFORE INSERT OR UPDATE ON NoteProduit
FOR EACH ROW
DECLARE
    v_date DATE;
BEGIN
    SELECT c.DateCommande
    INTO v_date
    FROM Commande c
    JOIN ProduitCommande pc ON c.CommandeId = pc.CommandeId
    WHERE c.ClientId = :NEW.ClientId
      AND pc.ProduitId = :NEW.ProduitId
      AND ROWNUM = 1;

    IF SYSDATE - v_date < 7 THEN
        RAISE_APPLICATION_ERROR(-20001,
        'Le produit doit avoir été acheté il y a au moins 7 jours.');
    END IF;

    IF :NEW.Note < 1 OR :NEW.Note > 5 THEN
        RAISE_APPLICATION_ERROR(-20002,
        'La note doit être comprise entre 1 et 5.');
    END IF;
END;
/

-- La note d’un produit est la moyenne des notes que lui ont données des clients
CREATE OR REPLACE TRIGGER TR_Update_Note_Produit
AFTER INSERT OR UPDATE OR DELETE ON NoteProduit
FOR EACH ROW
BEGIN
    UPDATE Produit
    SET NoteProduit = (
        SELECT ROUND(AVG(Note),1)
        FROM NoteProduit
        WHERE ProduitId = :NEW.ProduitId
    )
    WHERE ProduitId = :NEW.ProduitId;
END;
/

-- La note d’un fournisseur est la moyenne des notes des produits qu’il vend
CREATE OR REPLACE TRIGGER TR_Update_Note_Fournisseur
AFTER UPDATE OF NoteProduit ON Produit
FOR EACH ROW
BEGIN
    UPDATE Fournisseur
    SET NoteFournisseur = (
        SELECT ROUND(AVG(Note),1)
        FROM Produit
        WHERE FournisseurId = :NEW.FournisseurId
    )
    WHERE FournisseurId = :NEW.FournisseurId;
END;
/


-- Trigger RECOMMANDATION : Réalisé par Yusuf DUMLUPINAR
-- Un produit qui n’est plus disponible nulle part ne peut pas être recommandé
CREATE OR REPLACE TRIGGER TR_Reco_Produit_Valide
BEFORE INSERT ON RecommandationProduit
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM Produit
    WHERE ProduitId = :NEW.ProduitId;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003,
        'Produit non disponible, recommandation impossible.');
    END IF;
END;
/

-- Une même recommandation ne peut pas contenir deux fois le même produit, et concerne au plus 3 produits.
CREATE OR REPLACE TRIGGER TR_Reco_Max_Produits
BEFORE INSERT ON RecommandationProduit
FOR EACH ROW
DECLARE
    nb NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO nb
    FROM RecommandationProduit
    WHERE RecommandationId = :NEW.RecommandationId;

    IF nb >= 3 THEN
        RAISE_APPLICATION_ERROR(-20004,
        'Une recommandation ne peut contenir plus de 3 produits.');
    END IF;
END;
/

-- Triggers Information Client réalisés par Aurore GIROD


--Un client n’a besoin de fournir son nom, son prénom et son adresse que s’il passe une commande.

CREATE OR REPLACE TRIGGER TR_VerifInfoClientCommande
BEFORE INSERT ON Commande
FOR EACH ROW
DECLARE
    cNom Client.Nom%TYPE;
    cPrenom Client.Prenom%TYPE;
    cAdresse Client.Adresse%TYPE;
BEGIN
    SELECT Nom, Prenom, Adresse
    INTO cNom, cPrenom, cAdresse
    FROM Client
    WHERE ClientId = :new.ClientId;

    IF cNom IS NULL OR cPrenom IS NULL OR cAdresse IS NULL THEN
        RAISE_APPLICATION_ERROR(-20005, 'Le client doit avoir un nom, un prénom et une adresse afin de passer commande.');
    END IF;
END;
/

    -- Le fait que le client n'ait pas besoin de fournir ces informations sans passer commande est géré par le fait que ces champs ne soient pas requis comme NOT NULL dans la création de la table Client.


-- Quand un client s’inscrit, par défaut, il voit tous les produits et pas uniquement les produits locaux dans ses recommandations.

CREATE OR REPLACE TRIGGER TR_ValeuraLocalParDefautClient
BEFORE INSERT ON Client
FOR EACH ROW
BEGIN
    IF :new.aLocal != 1 THEN --On tolère qu'un client soit inséré avec déjà comme préférence l'achat local
        :new.aLocal := 0;
    END IF;
END;
/

-- Un client n’achetant que local ne peut pas se faire recommander de produit qui n’est pas stocké dans son pays ou qui n’est pas d’un fournisseur de son pays.

CREATE OR REPLACE TRIGGER TR_VerifRecommandationLocale
BEFORE INSERT ON RecommandationProduit
FOR EACH ROW
DECLARE
    vClientPays Client.Pays%TYPE;
    vClientLocal Client.aLocal%TYPE;
    vProduitId Produit.FournisseurId%TYPE;
    vProduitPays VARCHAR2(2);
    vFournisseurPays Fournisseur.Pays%TYPE;
    vCount NUMBER;
BEGIN
    SELECT Pays, aLocal INTO vClientPays, vClientLocal
    FROM Client
    WHERE ClientId = (SELECT ClientId FROM Recommandation WHERE RecommandationId = :NEW.RecommandationId);

    IF vClientLocal = 1 THEN-- Si le client n'achète pas local, pas besoin de vérification, on ne vérifie que si =1
        SELECT FournisseurId INTO vProduitId FROM Produit WHERE ProduitId = :NEW.ProduitId;
        SELECT Pays INTO vFournisseurPays FROM Fournisseur WHERE FournisseurId = vProduitId;

        SELECT COUNT(*) INTO vCount
        FROM ProduitPays
        WHERE ProduitId = :NEW.ProduitId AND Nom = vClientPays;

        IF vFournisseurPays != vClientPays OR vCount = 0 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Produit non disponible localement pour ce client.');
        END IF;
    END IF;
END;
/



-- Triggers Produits, quantités et prix réalisés par Aurore GIROD

-- Le prix des produits ne peut pas être négatif.

    -- Vérifié dans la création des tables par CHECK (Prix >= 0)

-- La quantité de produits dans une commande ou un panier ne peut pas être négative.

    -- Vérifié dans la création des tables par CHECK (Quantité >= 0)

-- Le prix d'un article du panier doit correspondre au prix unitaire de l'article sur le site multiplié par sa quantité. 

CREATE OR REPLACE TRIGGER TR_CalcPrixSouhaiteAcheter
BEFORE INSERT OR UPDATE ON SouhaiteAcheter
FOR EACH ROW
DECLARE
    vPrixUnitaire Produit.Prix%TYPE;
BEGIN
    SELECT Prix
    INTO vPrixUnitaire
    FROM Produit
    WHERE ProduitId = :NEW.ProduitId;

    :NEW.Prix := :NEW.Quantite * vPrixUnitaire;
END;
/

-- On applique la même logique à la table ProduitCommande :

CREATE OR REPLACE TRIGGER TR_CalcPrixProduitCommande
BEFORE INSERT OR UPDATE ON ProduitCommande
FOR EACH ROW
DECLARE
    vPrixUnitaire Produit.Prix%TYPE;
BEGIN
    SELECT Prix
    INTO vPrixUnitaire
    FROM Produit
    WHERE ProduitId = :NEW.ProduitId;

    :NEW.Prix := :NEW.Quantite * vPrixUnitaire;
END;
/


-- Le montant total d’une commande doit être égal à la somme, pour chaque produit de la commande, du prix à l’unité du produit multiplié par la quantité commandée.

CREATE OR REPLACE TRIGGER TR_CalcPrixTotalCommande
AFTER INSERT OR UPDATE OR DELETE ON ProduitCommande
FOR EACH ROW
DECLARE
    vTotal Commande.PrixTotal%TYPE;
    vCommandeId ProduitCommande.CommandeId%TYPE;
BEGIN
    IF INSERTING OR UPDATING THEN
        vCommandeId := :NEW.CommandeId;
    ELSIF DELETING THEN
        vCommandeId := :OLD.CommandeId;
    END IF;

    SELECT NVL(SUM(Quantite * Prix), 0)
    INTO vTotal
    FROM ProduitCommande
    WHERE CommandeId = vCommandeId;

    UPDATE Commande
    SET PrixTotal = vTotal
    WHERE CommandeId = vCommandeId;
END;
/


-- Triggers de traçabilité des activités réalisés par Aurore GIROD

-- Une commande ou recommandation ne peut en aucun cas être supprimée.

CREATE OR REPLACE TRIGGER TR_SupprCommandeInterdite
BEFORE DELETE ON Commande
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20007, 'Suppression de commande interdite.');
END;
/

CREATE OR REPLACE TRIGGER TR_SupprRecInterdite
BEFORE DELETE ON Recommandation
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20008, 'Suppression de recommandation interdite.');
END;
/


-- Triggers de bon fonctionnement de notre base de données  réalisés par Aurore GIROD

-- Gestion de CategorieSousCategorie :

CREATE SEQUENCE CategorieSousCategorie_SEQ START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER TR_CSC_AjoutCategorie
AFTER INSERT ON Categorie
FOR EACH ROW
BEGIN
    INSERT INTO CategorieSousCategorie(CSCId, CategorieId, SousCategorieId)
    VALUES (CategorieSousCategorie_SEQ.NEXTVAL, :NEW.CategorieId, NULL);
END;
/

CREATE OR REPLACE TRIGGER TR_CSC_SupprCategorie
AFTER DELETE ON Categorie
FOR EACH ROW
BEGIN
    DELETE FROM CategorieSousCategorie
    WHERE CategorieId = :OLD.CategorieId;
END;
/


CREATE OR REPLACE TRIGGER TR_CSC_AjoutSousCategorie
AFTER INSERT ON SousCategorie
FOR EACH ROW
BEGIN
    INSERT INTO CategorieSousCategorie(CSCId, CategorieId, SousCategorieId)
    VALUES (CategorieSousCategorie_SEQ.NEXTVAL, :NEW.CategorieId, :NEW.SousCategorieId);
END;
/

CREATE OR REPLACE TRIGGER TR_CSC_SupprSousCategorie
AFTER DELETE ON SousCategorie
FOR EACH ROW
BEGIN
    DELETE FROM CategorieSousCategorie
    WHERE SousCategorieId = :OLD.SousCategorieId;
END;
/

CREATE OR REPLACE TRIGGER TR_CSC_UpdateSousCategorie
AFTER UPDATE OF CategorieId ON SousCategorie
FOR EACH ROW
BEGIN
    DELETE FROM CategorieSousCategorie
    WHERE SousCategorieId = :OLD.SousCategorieId;

    INSERT INTO CategorieSousCategorie(CSCId, CategorieId, SousCategorieId)
    VALUES (CategorieSousCategorie_SEQ.NEXTVAL, :NEW.CategorieId, :NEW.SousCategorieId);
END;
/


-- Gestion des identifiants numériques (tous les ID servant de clés primaires) :

CREATE SEQUENCE seq_client START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER TR_client_id
BEFORE INSERT ON Client
FOR EACH ROW
BEGIN
    IF :NEW.ClientId IS NULL THEN
        SELECT seq_client.NEXTVAL INTO :NEW.ClientId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_fournisseur START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER TR_fournisseur_id
BEFORE INSERT ON Fournisseur
FOR EACH ROW
BEGIN
    IF :NEW.FournisseurId IS NULL THEN
        SELECT seq_fournisseur.NEXTVAL INTO :NEW.FournisseurId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_categorie START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER TR_categorie_id
BEFORE INSERT ON Categorie
FOR EACH ROW
BEGIN
    IF :NEW.CategorieId IS NULL THEN
        SELECT seq_categorie.NEXTVAL INTO :NEW.CategorieId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_souscategorie START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER TR_souscategorie_id
BEFORE INSERT ON SousCategorie
FOR EACH ROW
BEGIN
    IF :NEW.SousCategorieId IS NULL THEN
        SELECT seq_souscategorie.NEXTVAL INTO :NEW.SousCategorieId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_csc START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER TR_csc_id
BEFORE INSERT ON CategorieSousCategorie
FOR EACH ROW
BEGIN
    IF :NEW.CSCId IS NULL THEN
        SELECT seq_csc.NEXTVAL INTO :NEW.CSCId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_produit START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER TR_produit_id
BEFORE INSERT ON Produit
FOR EACH ROW
BEGIN
    IF :NEW.ProduitId IS NULL THEN
        SELECT seq_produit.NEXTVAL INTO :NEW.ProduitId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_commande START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER TR_commande_id
BEFORE INSERT ON Commande
FOR EACH ROW
BEGIN
    IF :NEW.CommandeId IS NULL THEN
        SELECT seq_commande.NEXTVAL INTO :NEW.CommandeId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_recommandation START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER TR_recommandation_id
BEFORE INSERT ON Recommandation
FOR EACH ROW
BEGIN
    IF :NEW.RecommandationId IS NULL THEN
        SELECT seq_recommandation.NEXTVAL INTO :NEW.RecommandationId FROM dual;
    END IF;
END;
/


-- On interdit aussi l'édition des Id des tables :

CREATE OR REPLACE TRIGGER TR_ModifInt_ClientId
BEFORE UPDATE OF ClientId ON Client
FOR EACH ROW
BEGIN
    IF :OLD.ClientId <> :NEW.ClientId THEN
        RAISE_APPLICATION_ERROR(
            -20009,
            'Modification du ClientId interdite'
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TR_ModifInt_FournisseurId
BEFORE UPDATE OF FournisseurId ON Fournisseur
FOR EACH ROW
BEGIN
    IF :OLD.FournisseurId <> :NEW.FournisseurId THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'Modification du FournisseurId interdite'
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TR_ModifInt_CategorieId
BEFORE UPDATE OF CategorieId ON Categorie
FOR EACH ROW
BEGIN
    IF :OLD.CategorieId <> :NEW.CategorieId THEN
        RAISE_APPLICATION_ERROR(
            -20011,
            'Modification du CategorieId interdite'
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TR_ModifInt_SousCategorieId
BEFORE UPDATE OF SousCategorieId ON SousCategorie
FOR EACH ROW
BEGIN
    IF :OLD.SousCategorieId <> :NEW.SousCategorieId THEN
        RAISE_APPLICATION_ERROR(
            -20012,
            'Modification du SousCategorieId interdite'
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TR_ModifInt_CSCId
BEFORE UPDATE OF CSCId ON CategorieSousCategorie
FOR EACH ROW
BEGIN
    IF :OLD.CSCId <> :NEW.CSCId THEN
        RAISE_APPLICATION_ERROR(
            -20013,
            'Modification du CSCId interdite'
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TR_ModifInt_ProduitId
BEFORE UPDATE OF ProduitId ON Produit
FOR EACH ROW
BEGIN
    IF :OLD.ProduitId <> :NEW.ProduitId THEN
        RAISE_APPLICATION_ERROR(
            -20014,
            'Modification du ProduitId interdite'
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TR_ModifInt_CommandeId
BEFORE UPDATE OF CommandeId ON Commande
FOR EACH ROW
BEGIN
    IF :OLD.CommandeId <> :NEW.CommandeId THEN
        RAISE_APPLICATION_ERROR(
            -20015,
            'Modification du CommandeId interdite'
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TR_ModifInt_RecommandationId
BEFORE UPDATE OF RecommandationId ON Recommandation
FOR EACH ROW
BEGIN
    IF :OLD.RecommandationId <> :NEW.RecommandationId THEN
        RAISE_APPLICATION_ERROR(
            -20016,
            'Modification du RecommandationId interdite'
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TR_ModifInt_PC_PK
BEFORE UPDATE OF CommandeId, ProduitId ON ProduitCommande
FOR EACH ROW
BEGIN
    IF :OLD.CommandeId <> :NEW.CommandeId
       OR :OLD.ProduitId <> :NEW.ProduitId THEN
        RAISE_APPLICATION_ERROR(
            -20017,
            'Modification de la clé primaire ProduitCommande interdite'
        );
    END IF;
END;
/

