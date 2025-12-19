SELECT sequence_name
FROM user_sequences;
-- Gestion des identifiants numériques (tous les ID servant de clés primaires) :

CREATE SEQUENCE seq_client START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER trg_client_id
BEFORE INSERT ON Client
FOR EACH ROW
BEGIN
    IF :NEW.ClientId IS NULL THEN
        SELECT seq_client.NEXTVAL INTO :NEW.ClientId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_fournisseur START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER trg_fournisseur_id
BEFORE INSERT ON Fournisseur
FOR EACH ROW
BEGIN
    IF :NEW.FournisseurId IS NULL THEN
        SELECT seq_fournisseur.NEXTVAL INTO :NEW.FournisseurId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_categorie START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER trg_categorie_id
BEFORE INSERT ON Categorie
FOR EACH ROW
BEGIN
    IF :NEW.CategorieId IS NULL THEN
        SELECT seq_categorie.NEXTVAL INTO :NEW.CategorieId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_souscategorie START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER trg_souscategorie_id
BEFORE INSERT ON SousCategorie
FOR EACH ROW
BEGIN
    IF :NEW.SousCategorieId IS NULL THEN
        SELECT seq_souscategorie.NEXTVAL INTO :NEW.SousCategorieId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_csc START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER trg_csc_id
BEFORE INSERT ON CategorieSousCategorie
FOR EACH ROW
BEGIN
    IF :NEW.CSCId IS NULL THEN
        SELECT seq_csc.NEXTVAL INTO :NEW.CSCId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_produit START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER trg_produit_id
BEFORE INSERT ON Produit
FOR EACH ROW
BEGIN
    IF :NEW.ProduitId IS NULL THEN
        SELECT seq_produit.NEXTVAL INTO :NEW.ProduitId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_commande START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER trg_commande_id
BEFORE INSERT ON Commande
FOR EACH ROW
BEGIN
    IF :NEW.CommandeId IS NULL THEN
        SELECT seq_commande.NEXTVAL INTO :NEW.CommandeId FROM dual;
    END IF;
END;
/

CREATE SEQUENCE seq_recommandation START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE OR REPLACE TRIGGER trg_recommandation_id
BEFORE INSERT ON Recommandation
FOR EACH ROW
BEGIN
    IF :NEW.RecommandationId IS NULL THEN
        SELECT seq_recommandation.NEXTVAL INTO :NEW.RecommandationId FROM dual;
    END IF;
END;
/