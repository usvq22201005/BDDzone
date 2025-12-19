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
