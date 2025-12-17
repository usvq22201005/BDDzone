-- TEST 4
SELECT *
FROM CategorieSousCategorie CSC
JOIN SousCategorie SC
  ON CSC.CategorieId = SC.CategorieId; commit ;