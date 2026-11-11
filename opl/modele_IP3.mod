/*********************************************
 * Modele (IP3)
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
 execute {
   // TODO
 }
 
 /** Variables **/
 dvar float+ x[types][periodes]; 
 dvar float+ s[types][periodes]; 
 dvar boolean y[periodes];
 dvar float+ w[types][periodes][periodes]; // Variable étendue : prod du type k en t pour satisfaire la demande en p
 /** Objectif **/
 minimize
  sum(t in periodes) (
    (sum(k in types) (x[k][t] * alpha[k] * coutProd[t] + s[k][t] * beta[k] * coutStock[t]))
    + coutFixe[t] * y[t]
  );
 
 /** Contraintes **/
 subject to {

  forall(t in periodes)
    ct_capacite:
      sum(k in types) x[k][t] <= capacite;

  forall(k in types)
    ct_flux_init:
      x[k][1] - s[k][1] == demande[k][1];

  forall(k in types, t in periodes : t > 1)
    ct_flux_suivants:
      s[k][t-1] + x[k][t] - s[k][t] == demande[k][t];


  forall(k in types, t in periodes)
    ct_lien_prod:
      x[k][t] == sum(p in periodes : p >= t) w[k][t][p]; // Lien : Prod totale = somme des destinations

  forall(k in types, p in periodes)
    ct_satisfaction_demande:
      sum(t in periodes : t <= p) w[k][t][p] == demande[k][p]; // Demande satisfaite par prod passée


  
  forall(t in periodes, k in types, p in periodes : p > t)
    ct_gardiennage_fort:
    // Contrainte forte : force y=1 si du stock traverse la période t
      sum(tau in periodes : tau <= t) w[k][tau][p] <= demande[k][p] * y[t];
      
 }