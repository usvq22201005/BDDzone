
SELECT
  VC.ProduitId,
  CL.aLocal,
  SUM(VC.Quantite) AS nb_achetes
FROM V_Vente_Client VC
JOIN Client CL
  ON CL.ClientId = VC.ClientId
JOIN Produit P
  ON P.ProduitId = VC.ProduitId
JOIN Fournisseur F
  ON F.FournisseurId = P.FournisseurId
-- WHERE F.Pays = 'France'   optionnel : retire si tu veux tous pays
GROUP BY VC.ProduitId, CL.aLocal
ORDER BY CL.aLocal DESC, nb_achetes DESC;