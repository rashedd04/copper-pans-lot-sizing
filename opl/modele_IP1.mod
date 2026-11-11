/*********************************************
 * Modele (IP1)
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
// Somme des demandes futures (borne max pour le stock)
 int BigM[t in periodes] = sum(p in periodes : p > t, k in types) demande[k][p];
 
 
 /** Variables **/
 dvar float+ x[types][periodes]; // Quantité produite
 dvar float+ s[types][periodes]; // Quantité stockée
 dvar boolean y[periodes];       // 1 si stock utilisé, 0 sinon
 
 
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
       sum(k in types) x[k][t] <= capacite; // Limite de capacité de prod


   forall(k in types)
     ct_flux_init:
       x[k][1] - s[k][1] == demande[k][1]; // Équilibre flux (période 1)

   forall(k in types, t in periodes : t > 1)
     ct_flux_suivants:
       s[k][t-1] + x[k][t] - s[k][t] == demande[k][t]; // Équilibre flux (périodes suivantes)
       

   forall(t in periodes)
     ct_gardiennage_global:
       sum(k in types) s[k][t] <= BigM[t] * y[t]; // Force y à 1 si le stock > 0
}