/*********************************************
 * Modele (IP2)
 *********************************************/

 include "main_IP.mod";

 /** Donnees **/
 int nbTypes = ...;
 int nbPeriodes = ...;
 range types = 1..nbTypes;
 range periodes = 1..nbPeriodes;
 int capacite = ...;
 int demande[types][periodes] = ...;
 float alpha[types] = ...;
 float beta[types] = ...;
 float coutProd[periodes] = ...;
 float coutStock[periodes] = ...;
 float coutFixe[periodes] = ...;
 
 /** Calcul des nombres maximum de casseroles stockees en fonction des donnees **/
 // Borne max stock par type (plus précis que IP1)
 int BigM_k[k in types][t in periodes] = sum(p in periodes : p > t) demande[k][p];
 
 /** Variables **/
 dvar float+ x[types][periodes]; 
 dvar float+ s[types][periodes]; 
 dvar boolean y[periodes];       
 
 
 /** Objectif **/
 minimize
 // Coût total : production + stockage + coûts fixes
  sum(t in periodes) (
    (sum(k in types) (x[k][t] * alpha[k] * coutProd[t] + s[k][t] * beta[k] * coutStock[t]))
    + coutFixe[t] * y[t]
  );
 
 /** Contraintes **/
 subject to {

  forall(t in periodes)
    ct_capacite:
      sum(k in types) x[k][t] <= capacite; // Limite de capacité

  forall(k in types)
    ct_flux_init:
      x[k][1] - s[k][1] == demande[k][1]; // Équilibre flux (début)

  forall(k in types, t in periodes : t > 1)
    ct_flux_suivants:
      s[k][t-1] + x[k][t] - s[k][t] == demande[k][t]; // Équilibre flux (suite)


  forall(t in periodes, k in types)
    ct_gardiennage_type:
      s[k][t] <= BigM_k[k][t] * y[t]; // Force y à 1 pour chaque type (contrainte forte)
}